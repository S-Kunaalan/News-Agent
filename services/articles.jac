"""News aggregation and AI article-summary service for LankaPulse."""

import json;
import os;
import re;
import urllib.request as request;
import urllib.parse as parse;
import xml.etree.ElementTree as ET;
import from datetime { datetime, timezone }
import from email.utils { parsedate_to_datetime }
import from http { HTTPMethod }
import from jaclang.byllm.lib { Model }

glob:priv summary_llm: Model = Model(model_name="gpt-4o-mini");
glob:priv summary_calls: dict[str, list[float]] = {};

obj ArticleSummary {
    has bullets: list[str];
}
sem ArticleSummary.bullets = "Exactly three concise English bullet points. Each is one sentence, faithful only to the supplied headline and snippet, and contains no invented details.";

def:priv summarize_headline(title: str, snippet: str) -> ArticleSummary by summary_llm(temperature=0.2, max_tokens=220);
sem summarize_headline = "Create a short English-only news summary with exactly three bullet points, using only the supplied title and snippet. Never infer missing facts.";
sem summarize_headline.title = "The article headline.";
sem summarize_headline.snippet = "The publisher-provided short snippet. Do not add facts beyond it.";

node Article {
    has id: str,
        title: str,
        snippet: str,
        imageUrl: str,
        source: str,
        url: str,
        publishedAt: str,
        category: str,
        region: str,
        language: str;
}

node ArticleRefreshState {
    has last_refresh: str = "";
}

def clean_text(value: str) -> str {
    plain = re.sub(r"<[^>]+>", " ", value);
    return re.sub(r"\s+", " ", plain).strip()[:200];
}

def normalize_date(value: str) -> str {
    if not value { return datetime.now(timezone.utc).isoformat(); }
    try {
        parsed = datetime.fromisoformat(value.replace("Z", "+00:00"));
        if parsed.tzinfo is None { parsed = parsed.replace(tzinfo=timezone.utc); }
        return parsed.astimezone(timezone.utc).isoformat();
    } except Exception {}
    try {
        parsed = parsedate_to_datetime(value);
        if parsed.tzinfo is None { parsed = parsed.replace(tzinfo=timezone.utc); }
        return parsed.astimezone(timezone.utc).isoformat();
    } except Exception {
        return datetime.now(timezone.utc).isoformat();
    }
}

def fetch_url(url: str) -> bytes {
    req = request.Request(url, headers={"User-Agent": "LankaPulse/1.0"});
    response = request.urlopen(req, timeout=12);
    content: bytes = response.read();
    response.close();
    return content;
}

def rss_text(item_node: any, tag: str) -> str {
    found = item_node.find(tag);
    if not found { found = item_node.find("{*}" + tag); }
    if found and found.text { return found.text; }
    return "";
}

def fetch_rss_source(source: str, feed_url: str) -> list[dict] {
    import logging;
    logger = logging.getLogger("lankapulse.news");
    output: list[dict] = [];
    try {
        xml_data = fetch_url(feed_url);
        feed = ET.fromstring(xml_data);
        entries = feed.findall(".//item");
        if len(entries) == 0 { entries = feed.findall(".//{*}entry"); }
        for rss_item in entries {
            title = clean_text(rss_text(rss_item, "title"));
            link = rss_text(rss_item, "link");
            if not link {
                link_node = rss_item.find("{*}link");
                if link_node { link = link_node.attrib.get("href", ""); }
            }
            summary = clean_text(rss_text(rss_item, "description"));
            if not summary { summary = clean_text(rss_text(rss_item, "summary")); }
            published = rss_text(rss_item, "pubDate");
            if not published { published = rss_text(rss_item, "published"); }
            if not published { published = rss_text(rss_item, "updated"); }
            published = normalize_date(published);
            image_url = "";
            image_node: any = rss_item.find("{*}enclosure");
            if image_node { image_url = image_node.attrib.get("url", "") as str; }
            if title and link {
                output = output + [{"title": title, "snippet": summary[:200], "imageUrl": image_url,
                    "source": source, "url": link, "publishedAt": published,
                    "category": "Local", "region": "local", "language": "en"}];
            }
        }
    } except Exception as error {
        logger.warning("News source failed (%s): %s", source, str(error));
    }
    return output;
}

def fetch_guardian() -> list[dict] {
    import logging;
    logger = logging.getLogger("lankapulse.news");
    api_key = os.environ.get("GUARDIAN_API_KEY", "");
    if not api_key {
        logger.warning("News source skipped (The Guardian): GUARDIAN_API_KEY is not set");
        return [];
    }
    query = parse.urlencode({"q": "world news", "order-by": "newest", "page-size": "50",
        "show-fields": "trailText,thumbnail", "api-key": api_key});
    output: list[dict] = [];
    try {
        data = fetch_url("https://content.guardianapis.com/search?" + query);
        payload = json.loads(data.decode("utf-8"));
        results = payload["response"]["results"] as list[dict];
        for item in results {
            fields = item["fields"] as dict;
            title = clean_text(item["webTitle"] as str);
            link = item["webUrl"] as str;
            if title and link {
                snippet = clean_text(fields["trailText"] as str) if fields.get("trailText") else "";
                image_url = fields["thumbnail"] as str if fields.get("thumbnail") else "";
                output = output + [{"title": title, "snippet": snippet[:200], "imageUrl": image_url,
                    "source": "The Guardian", "url": link,
                    "publishedAt": normalize_date(item["webPublicationDate"] as str),
                    "category": "World", "region": "foreign", "language": "en"}];
            }
        }
    } except Exception as error {
        logger.warning("News source failed (The Guardian): %s", str(error));
    }
    return output;
}

def fetch_all_news() -> list[dict] {
    combined = fetch_rss_source("Ada Derana", "https://www.adaderana.lk/rss.php");
    combined = combined + fetch_rss_source("Newsfirst", "https://english.newsfirst.lk/rss?format=feed");
    combined = combined + fetch_rss_source("Daily Mirror Sri Lanka", "https://www.dailymirror.lk/RSS_Feeds/breaking-news/108");
    combined = combined + fetch_guardian();
    unique: list[dict] = [];
    seen_urls: list[str] = [];
    seen_titles: list[str] = [];
    for item in combined {
        url = (item["url"] as str).split("#")[0].rstrip("/").lower();
        title_key = re.sub(r"[^a-z0-9]+", " ", (item["title"] as str).lower()).strip();
        if url and url not in seen_urls and title_key not in seen_titles {
            item["id"] = url;
            item["url"] = url;
            item["snippet"] = (item["snippet"] as str)[:200];
            unique = unique + [item];
            seen_urls = seen_urls + [url];
            seen_titles = seen_titles + [title_key];
        }
    }
    return sorted(unique, key=lambda (item: dict) { item["publishedAt"] as str; }, reverse=True);
}

def:pub get_articles(region: str = "", category: str = "", q: str = "", page: int = 1, page_size: int = 20) -> dict {
    now = datetime.now(timezone.utc);
    cache_nodes = [root -->][?:ArticleRefreshState];
    last_refresh = "";
    if len(cache_nodes) > 0 { last_refresh = cache_nodes[0].last_refresh; }
    needs_refresh = True;
    if last_refresh {
        try {
            age_seconds = (now - datetime.fromisoformat(last_refresh)).total_seconds();
            needs_refresh = age_seconds >= 900;
        } except Exception { needs_refresh = True; }
    }
    existing = [root -->][?:Article];
    if needs_refresh {
        fetched = fetch_all_news();
        if len(fetched) > 0 {
            for item in fetched {
                already_stored = False;
                for old in existing { if old.url == (item["url"] as str) { already_stored = True; } }
                if not already_stored {
                    root ++> Article(id=item["id"] as str, title=item["title"] as str,
                        snippet=item["snippet"] as str, imageUrl=item["imageUrl"] as str,
                        source=item["source"] as str, url=item["url"] as str,
                        publishedAt=item["publishedAt"] as str, category=item["category"] as str,
                        region=item["region"] as str, language=item["language"] as str);
                }
            }
            if len(cache_nodes) > 0 { cache_nodes[0].last_refresh = now.isoformat(); }
            else { root ++> ArticleRefreshState(last_refresh=now.isoformat()); }
            last_refresh = now.isoformat();
            existing = [root -->][?:Article];
        }
    }
    filtered: list[Article] = [];
    region_key = region.strip().lower();
    category_key = category.strip().lower();
    query_key = q.strip().lower();
    for item in existing {
        matches = True;
        if region_key and item.region.lower() != region_key { matches = False; }
        if category_key and item.category.lower() != category_key { matches = False; }
        searchable = (item.title + " " + item.snippet + " " + item.source).lower();
        if query_key and query_key not in searchable { matches = False; }
        if matches { filtered = filtered + [item]; }
    }
    filtered = sorted(filtered, key=lambda (article: Article) { article.publishedAt; }, reverse=True);
    safe_page = max(1, page);
    safe_size = min(max(1, page_size), 100);
    start_index = (safe_page - 1) * safe_size;
    end_index = start_index + safe_size;
    return {"articles": filtered[start_index:end_index], "total": len(filtered), "page": safe_page,
        "page_size": safe_size, "has_more": end_index < len(filtered), "last_refresh": last_refresh};
}

@restspec(method=HTTPMethod.GET, path="/articles")
def:pub articles_rest(region: str = "", category: str = "", q: str = "", page: int = 1, page_size: int = 20) -> dict {
    return get_articles(region, category, q, page, page_size);
}

"""Generate exactly three concise English bullets from the supplied headline and snippet."""
@restspec(method=HTTPMethod.POST, path="/summarize")
def:pub summarize_article(title: str, snippet: str) -> dict {
    import from time { time }
    client_key = "anonymous";
    now_seconds = time();
    history = summary_calls[client_key] if client_key in summary_calls else [];
    recent = [t for t in history if now_seconds - t < 60.0];
    if len(recent) >= 5 {
        return {"error": "rate_limited", "message": "Please wait a minute before requesting another summary."};
    }
    summary_calls[client_key] = recent + [now_seconds];
    if len(title.strip()) == 0 and len(snippet.strip()) == 0 {
        return {"error": "empty_article", "message": "A headline or snippet is needed to summarize this story."};
    }
    try {
        result = summarize_headline(title[:300], snippet[:200]);
        bullets = result.bullets[:3];
        if len(bullets) != 3 {
            return {"error": "summary_unavailable", "message": "The summary could not be generated. Please try again."};
        }
        return {"bullets": bullets, "disclosure": "AI-generated summary based only on the headline and publisher snippet."};
    } except Exception as error {
        import logging;
        logging.getLogger("lankapulse.ai").warning("Article summary failed: %s", str(error));
        return {"error": "summary_unavailable", "message": "AI summaries are temporarily unavailable. Please try again later."};
    }
}

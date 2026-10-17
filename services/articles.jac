import json;
import os;
import re;
import urllib.request as request;
import urllib.parse as parse;
import xml.etree.ElementTree as ET;
import from datetime { datetime, timezone }
import from email.utils { parsedate_to_datetime }
import from http { HTTPMethod }
import from concurrent.futures { ThreadPoolExecutor }
import from jaclang.byllm.lib { Model }

# Accepts either variable name. Verify the model name exists in Google AI Studio.
glob:priv summary_llm: Model = Model(model_name="gemini/gemini-3.8-flash", api_key=os.environ.get("Gemini_API_Key", os.environ.get("MY_API_KEY", "")));
glob:priv summary_calls: dict[str, list[float]] = {};

# region = local/foreign. "category" is an optional hint; empty means detect from the text.
glob NEWS_SOURCES: list[dict] = [
    {"name":"Ada Derana", "url":"https://www.adaderana.lk/rss.php", "region":"local", "kind":"rss", "category":""},
    {"name":"EconomyNext", "url":"https://economynext.com/feed/", "region":"local", "kind":"rss", "category":"business"},
    {"name":"Sri Lanka Mirror", "url":"https://srilankamirror.com/feed/", "region":"local", "kind":"rss", "category":""},
    {"name":"BBC Asia", "url":"https://feeds.bbci.co.uk/news/world/asia/rss.xml", "region":"foreign", "kind":"rss", "category":""},
    {"name":"The Guardian", "url":"https://www.theguardian.com/world/rss", "region":"foreign", "kind":"rss", "category":""},
    {"name":"Al Jazeera", "url":"https://www.aljazeera.com/xml/rss/all.xml", "region":"foreign", "kind":"rss", "category":""},
    {"name":"BBC Sport", "url":"https://feeds.bbci.co.uk/sport/rss.xml", "region":"foreign", "kind":"rss", "category":"sports"},
    {"name":"BBC Business", "url":"https://feeds.bbci.co.uk/news/business/rss.xml", "region":"foreign", "kind":"rss", "category":"business"},
    {"name":"BBC Technology", "url":"https://feeds.bbci.co.uk/news/technology/rss.xml", "region":"foreign", "kind":"rss", "category":"tech"}
];

glob CATEGORY_KEYWORDS: dict = {
    "sports": ["cricket", "wicket", "match", "tournament", "football", "rugby", "olympic", "tennis", "league", "athlete", "t20", "odi", "stadium"],
    "business": ["economy", "economic", "inflation", "bank", "stocks", "shares", "budget", "tax", "export", "import", "trade", "imf", "rupee", "market", "tourism"],
    "tech": ["technology", "tech", "software", "app", "ai", "startup", "cyber", "digital", "internet", "robot", "smartphone"],
    "entertainment": ["film", "movie", "music", "singer", "actor", "actress", "concert", "festival", "celebrity", "cinema", "drama"]
};

obj ArticleSummary {
    has bullets: list[str];
}
sem ArticleSummary.bullets = "Exactly three concise English bullet points. Each is one sentence, faithful only to the supplied headline and snippet, and contains no invented details.";

def:priv summarize_headline(title: str, snippet: str) -> ArticleSummary by summary_llm(temperature=0.3, max_tokens=220);
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

node NewsFeedCache {
    has updated_at: str = "",
        last_good_at: str = "",
        source_status: dict = {},
        source_articles: dict = {},
        articles: list[dict] = [];
}

def clean_text(value: str) -> str {
    plain = re.sub(r"<[^>]+>", " ", value);
    return re.sub(r"\s+", " ", plain).strip()[:400];
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

def time_ago(iso: str) -> str {
    try {
        seconds = (datetime.now(timezone.utc) - datetime.fromisoformat(iso)).total_seconds();
        if seconds < 90 { return "Just now"; }
        if seconds < 3600 { return str(int(seconds // 60)) + " min ago"; }
        if seconds < 86400 {
            hours = int(seconds // 3600);
            return str(hours) + (" hr ago" if hours == 1 else " hrs ago");
        }
        days = int(seconds // 86400);
        return str(days) + (" day ago" if days == 1 else " days ago");
    } except Exception {
        return "Latest";
    }
}

def detect_category(title: str, snippet: str, hint: str) -> str {
    if hint { return hint; }
    text = (title + " " + snippet).lower();
    for (name, words) in CATEGORY_KEYWORDS.items() {
        for word in words {
            if re.search(r"\b" + word + r"\b", text) { return name; }
        }
    }
    return "general";
}

def fetch_url(url: str) -> bytes {
    req = request.Request(url, headers={"User-Agent":"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36 LankaPulse/1.0", "Accept":"application/rss+xml, application/atom+xml, application/xml, text/xml;q=0.9, */*;q=0.8"});
    response = request.urlopen(req, timeout=8);
    content: bytes = response.read();
    response.close();
    return content;
}

# FIX: XML elements with no children are "falsy", so always compare with None.
def rss_text(item_node: any, tag: str) -> str {
    found = item_node.find(tag);
    if found is None { found = item_node.find("{*}" + tag); }
    if found is not None and found.text { return found.text; }
    return "";
}

def parse_rss_source(source: dict) -> list[dict] {
    xml_data = fetch_url(source["url"] as str);
    feed = ET.fromstring(xml_data);
    entries = feed.findall(".//item");
    if len(entries) == 0 { entries = feed.findall(".//{*}entry"); }
    output: list[dict] = [];
    hint = source["category"] as str if "category" in source else "";
    for rss_item in entries {
        title = clean_text(rss_text(rss_item, "title"));
        link = rss_text(rss_item, "link").strip();
        if not link {
            link_node = rss_item.find("{*}link");
            if link_node is not None { link = link_node.attrib.get("href", "") as str; }
        }
        summary = clean_text(rss_text(rss_item, "description"));
        if not summary { summary = clean_text(rss_text(rss_item, "summary")); }
        published = rss_text(rss_item, "pubDate");
        if not published { published = rss_text(rss_item, "published"); }
        if not published { published = rss_text(rss_item, "updated"); }
        image_url = "";
        for image_tag in ["enclosure", "thumbnail", "content"] {
            image_node: any = rss_item.find("{*}" + image_tag);
            if image_node is not None {
                candidate = image_node.attrib.get("url", "") as str;
                if candidate { image_url = candidate; break; }
            }
        }
        if title and link {
            region = source["region"] as str;
            output = output + [{"title":title, "snippet":summary[:200], "imageUrl":image_url,
                "source":source["name"], "url":link, "publishedAt":normalize_date(published),
                "category":detect_category(title, summary, hint), "region":region, "language":"en"}];
        }
    }
    if len(output) == 0 { raise Exception("Valid XML contained no usable article items"); }
    return output;
}

def fetch_source_safe(source: dict) -> dict {
    try {
        return {"ok":True, "rows":parse_rss_source(source), "error":""};
    } except Exception as error {
        return {"ok":False, "rows":[], "error":str(error)};
    }
}

def refresh_news_sources() -> dict {
    import logging;
    logger = logging.getLogger("lankapulse.news");
    all_nodes = [root -->][?:NewsFeedCache];
    cache: NewsFeedCache | None = all_nodes[0] if len(all_nodes) > 0 else None;
    fresh_status: dict = {};
    fresh_source_articles: dict = {};
    combined: list[dict] = [];
    success_count = 0;
    results: list[dict] = [];
    with ThreadPoolExecutor(max_workers=9) as pool {
        results = list(pool.map(fetch_source_safe, NEWS_SOURCES));
    }
    for (source, result) in zip(NEWS_SOURCES, results) {
        source_name = source["name"] as str;
        if result["ok"] {
            rows = result["rows"] as list[dict];
            fresh_source_articles[source_name] = rows;
            fresh_status[source_name] = {"url":source["url"], "region":source["region"], "status":"ok", "items":len(rows), "error":""};
            combined = combined + rows;
            success_count = success_count + 1;
        } else {
            message = result["error"] as str;
            logger.warning("News source failed (%s, %s): %s", source_name, source["url"], message);
            prior_rows: list[dict] = cache.source_articles[source_name] as list[dict] if cache is not None and source_name in cache.source_articles else [];
            fresh_source_articles[source_name] = prior_rows;
            fresh_status[source_name] = {"url":source["url"], "region":source["region"], "status":"failed", "items":len(prior_rows), "error":message, "using_last_good":len(prior_rows) > 0};
            combined = combined + prior_rows;
        }
    }
    if success_count > 0 {
        unique: list[dict] = [];
        seen_keys: list[str] = [];
        seen_titles: list[str] = [];
        for item in combined {
            clean_url = (item["url"] as str).split("#")[0];
            article_key = clean_url.rstrip("/").lower();
            title_key = re.sub(r"[^a-z0-9]+", " ", (item["title"] as str).lower()).strip();
            if article_key and article_key not in seen_keys and title_key not in seen_titles {
                item["id"] = article_key;
                item["url"] = clean_url;
                unique = unique + [item];
                seen_keys = seen_keys + [article_key];
                seen_titles = seen_titles + [title_key];
            }
        }
        sorted_articles = sorted(unique, key=lambda (item: dict) { item["publishedAt"] as str; }, reverse=True);
        updated_now = datetime.now(timezone.utc).isoformat();
        if cache is None {
            cache = root ++> NewsFeedCache(updated_at=updated_now, last_good_at=updated_now, source_status=fresh_status, source_articles=fresh_source_articles, articles=sorted_articles);
        } else {
            cache.updated_at = updated_now;
            cache.last_good_at = updated_now;
            cache.source_status = fresh_status;
            cache.source_articles = fresh_source_articles;
            cache.articles = sorted_articles;
        }
        return {"articles":sorted_articles, "source_status":fresh_status, "updated_at":updated_now, "last_good_at":updated_now, "stale":False};
    }
    if cache is not None and cache.articles {
        return {"articles":cache.articles, "source_status":fresh_status, "updated_at":cache.updated_at, "last_good_at":cache.last_good_at, "stale":True};
    }
    return {"articles":[], "source_status":fresh_status, "updated_at":"", "last_good_at":"", "stale":True};
}

def:pub get_articles(region: str = "", category: str = "", q: str = "", page: int = 1, page_size: int = 20) -> dict {
    cache_nodes = [root -->][?:NewsFeedCache];
    cached_articles: list[dict] = [];
    status: dict = {};
    updated_at = "";
    last_good_at = "";
    stale = False;
    refresh_due = True;
    if len(cache_nodes) > 0 {
        cache = cache_nodes[0];
        cached_articles = cache.articles;
        status = cache.source_status;
        updated_at = cache.updated_at;
        last_good_at = cache.last_good_at;
        if updated_at {
            try {
                age = (datetime.now(timezone.utc) - datetime.fromisoformat(updated_at)).total_seconds();
                refresh_due = age >= 900;
            } except Exception { refresh_due = True; }
        }
    }
    if refresh_due {
        refresh = refresh_news_sources();
        cached_articles = refresh["articles"] as list[dict];
        status = refresh["source_status"] as dict;
        updated_at = refresh["updated_at"] as str;
        last_good_at = refresh["last_good_at"] as str;
        stale = refresh["stale"] as bool;
    }
    region_key = region.strip().lower();
    category_key = category.strip().lower();
    query_key = q.strip().lower();
    # "Local"/"World" are regions, not categories. Accept either spelling.
    if region_key == "world" { region_key = "foreign"; }
    if category_key in ["local", "world"] {
        region_key = "local" if category_key == "local" else "foreign";
        category_key = "";
    }
    if category_key == "all" { category_key = ""; }
    filtered: list[dict] = [];
    for article in cached_articles {
        matches = True;
        if region_key and (article["region"] as str).lower() != region_key { matches = False; }
        if category_key and (article["category"] as str).lower() != category_key { matches = False; }
        searchable = ((article["title"] as str) + " " + (article["snippet"] as str) + " " + (article["source"] as str)).lower();
        if query_key and query_key not in searchable { matches = False; }
        if matches {
            row = dict(article);
            row["time"] = time_ago(article["publishedAt"] as str);
            filtered = filtered + [row];
        }
    }
    filtered = sorted(filtered, key=lambda (article: dict) { article["publishedAt"] as str; }, reverse=True);
    safe_page = max(1, page);
    safe_size = min(max(1, page_size), 100);
    start_index = (safe_page - 1) * safe_size;
    end_index = start_index + safe_size;
    return {"articles":filtered[start_index:end_index], "total":len(filtered), "page":safe_page,
        "page_size":safe_size, "has_more":end_index < len(filtered), "updated_at":updated_at,
        "last_good_at":last_good_at, "stale":stale, "source_status":status};
}

@restspec(method=HTTPMethod.GET, path="/articles")
def:pub articles_rest(region: str = "", category: str = "", q: str = "", page: int = 1, page_size: int = 20) -> dict {
    return get_articles(region, category, q, page, page_size);
}

"""Generate exactly three concise English bullets from the supplied headline and snippet."""
@restspec(method=HTTPMethod.POST, path="/summarize")
def:pub summarize_article(title: str, snippet: str) -> dict {
    import from time { time }
    # AI is optional: a missing key must never break the app.
    if not (os.environ.get("Gemini_API_Key", "") or os.environ.get("MY_API_KEY", "")) {
        return {"error":"ai_not_configured", "message":"AI summaries aren’t set up yet."};
    }
    client_key = "anonymous";
    now_seconds = time();
    history = summary_calls[client_key] if client_key in summary_calls else [];
    recent = [t for t in history if now_seconds - t < 60.0];
    if len(recent) >= 5 {
        return {"error":"rate_limited", "message":"Please wait a minute before requesting another summary."};
    }
    summary_calls[client_key] = recent + [now_seconds];
    if len(title.strip()) == 0 and len(snippet.strip()) == 0 {
        return {"error":"empty_article", "message":"A headline or snippet is needed to summarize this story."};
    }
    try {
        result = summarize_headline(title[:300], snippet[:200]);
        bullets = result.bullets[:3];
        if len(bullets) != 3 {
            return {"error":"summary_unavailable", "message":"The summary could not be generated. Please try again."};
        }
        return {"bullets":bullets, "disclosure":"AI-generated summary based only on the headline and publisher snippet."};
    } except Exception as error {
        import logging;
        logging.getLogger("lankapulse.ai").warning("Article summary failed: %s", str(error));
        return {"error":"summary_unavailable", "message":"AI summaries are temporarily unavailable. Please try again later."};
    }
}

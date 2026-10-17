"""LankaPulse news reader: multilingual feed, onboarding and settings."""

import from "@jac/mobui" { View, Text, Pressable, ScrollView, Image, TextInput, useWindowDimensions, Animated, Easing }
import from services.articles { get_articles, articles_rest, summarize_article }
import from .theme { LIGHT, DARK, buildStyles }

glob lightStyles = buildStyles(LIGHT);
glob darkStyles = buildStyles(DARK);

# Paste your deployed backend URL here, no trailing slash. Never localhost.
glob API_BASE: str = "";

glob CATEGORIES: list[str] = ["All", "Local", "World", "Sports", "Business", "Tech", "Entertainment"];
glob TOPICS: list[str] = ["Local", "World", "Sports", "Business", "Tech", "Entertainment"];
glob ARTICLES: list[dict] = [
    {"id":"a01", "category":"Local", "topic":"COMMUNITY", "title":"Colombo’s neighbourhood gardens bring new life to city streets", "source":"Daily Island", "time":"12 min ago", "date":"Sample", "summary":"Residents and community groups are finding new ways to bring shade and shared green spaces to busy Colombo neighbourhoods. This short preview is original mock copy; follow the publisher for the full report.", "url":"https://example.com/daily-island/colombo-gardens", "image":"https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?w=900"},
    {"id":"a02", "category":"World", "topic":"CLIMATE", "title":"Cities share fresh ideas for greener, cooler public spaces", "source":"World Desk", "time":"28 min ago", "summary":"", "image":"https://images.unsplash.com/photo-1519501025264-65ba15a82390?w=900"},
    {"id":"a03", "category":"Sports", "topic":"CRICKET", "title":"Young Sri Lankan squad looks ahead to a big season", "source":"Island Sports", "time":"35 min ago", "summary":"", "image":"https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=900"},
    {"id":"a04", "category":"Business", "topic":"SMALL BUSINESS", "title":"Local makers find new customers at weekend markets", "source":"The Morning", "time":"48 min ago", "summary":"", "image":"https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=900"},
    {"id":"a05", "category":"Tech", "topic":"INNOVATION", "title":"Meet the island teams building helpful digital tools", "source":"Tech Lanka", "time":"1 hr ago", "summary":"", "image":"https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=900"},
    {"id":"a06", "category":"Entertainment", "topic":"ARTS", "title":"A new generation of artists lights up Colombo’s galleries", "source":"Culture Notes", "time":"1 hr ago", "summary":"", "image":"https://images.unsplash.com/photo-1531058020387-3be344556be6?w=900"},
    {"id":"a07", "category":"Local", "topic":"TRAVEL", "title":"Southern rail trips inspire a slower kind of weekend", "source":"Daily Island", "time":"1 hr ago", "summary":"", "image":"https://images.unsplash.com/photo-1474487548417-781cb71495f3?w=900"},
    {"id":"a08", "category":"World", "topic":"SCIENCE", "title":"Researchers make a promising discovery beneath the ocean", "source":"World Desk", "time":"1 hr ago", "summary":"", "image":"https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=900"},
    {"id":"a09", "category":"Sports", "topic":"FOOTBALL", "title":"Island football clubs welcome a new community league", "source":"Island Sports", "time":"2 hrs ago", "summary":"", "image":"https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=900"},
    {"id":"a10", "category":"Business", "topic":"ECONOMY", "title":"Family-run tea growers bring their harvest to new shelves", "source":"The Morning", "time":"2 hrs ago", "summary":"", "image":"https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=900"},
    {"id":"a11", "category":"Tech", "topic":"STARTUPS", "title":"Colombo founders turn a shared idea into a growing startup", "source":"Tech Lanka", "time":"2 hrs ago", "summary":"", "image":"https://images.unsplash.com/photo-1521737711867-e3b97375f902?w=900"},
    {"id":"a12", "category":"Entertainment", "topic":"FILM", "title":"Local filmmakers tell intimate stories with a global audience", "source":"Culture Notes", "time":"3 hrs ago", "summary":"", "image":"https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=900"},
    {"id":"a13", "category":"Local", "topic":"EDUCATION", "title":"School science clubs make room for hands-on discovery", "source":"Daily Island", "time":"3 hrs ago", "summary":"", "image":"https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=900"},
    {"id":"a14", "category":"World", "topic":"CULTURE", "title":"Community libraries bring neighbours together through stories", "source":"World Desk", "time":"3 hrs ago", "summary":"", "image":"https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=900"},
    {"id":"a15", "category":"Sports", "topic":"RUNNING", "title":"Colombo’s sunrise runners turn the waterfront into a track", "source":"Island Sports", "time":"4 hrs ago", "summary":"", "image":"https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=900"},
    {"id":"a16", "category":"Business", "topic":"FOOD", "title":"Small cafés give traditional island flavours a fresh twist", "source":"The Morning", "time":"4 hrs ago", "summary":"", "image":"https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=900"},
    {"id":"a17", "category":"Tech", "topic":"SCIENCE", "title":"Young researchers explore practical solutions for clean water", "source":"Tech Lanka", "time":"5 hrs ago", "summary":"", "image":"https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=900"},
    {"id":"a18", "category":"Entertainment", "topic":"MUSIC", "title":"An evening of live music brings Colombo friends together", "source":"Culture Notes", "time":"5 hrs ago", "summary":"", "image":"https://images.unsplash.com/photo-1506157786151-b8491531f063?w=900"},
    {"id":"a19", "category":"Local", "topic":"NATURE", "title":"Coastal volunteers join hands to care for nesting sea turtles", "source":"Daily Island", "time":"6 hrs ago", "summary":"", "image":"https://images.unsplash.com/photo-1437622368342-7a3d73a34c8f?w=900"},
    {"id":"a20", "category":"World", "topic":"TRAVEL", "title":"A new walking route invites visitors to discover old town lanes", "source":"World Desk", "time":"6 hrs ago", "summary":"", "image":"https://images.unsplash.com/photo-1516483638261-f4dbaf036963?w=900"}
];

glob COPY: dict = {
    "English": {"home":"The day, in the know.", "subtitle":"A thoughtful read from home and around the world.", "stories":"Today’s stories", "saved":"Saved stories", "search":"Search headlines, topics, sources", "refresh":"Refresh", "onboarding":"A little closer to home", "next":"Next", "start":"Start reading", "topics":"Pick what you love", "settings":"Settings", "theme":"Theme", "font":"Font size", "notifications":"Notifications", "done":"Done", "offline":"You’re offline · Showing your last saved feed"},
};

def valueOf(v: any, fallback: str) -> str {
    return v as str if v else fallback;
}

# "Local"/"World" use the region field; every other chip uses the category field.
def matchesFilter(a: dict, key: str) -> bool {
    k = key.lower();
    if k == "all" { return True; }
    region = valueOf(a["region"], "").lower();
    cat = valueOf(a["category"], "").lower();
    if k == "local" { return region == "local" or (region == "" and cat == "local"); }
    if k == "world" { return region == "foreign" or (region == "" and cat == "world"); }
    return cat == k;
}

def matchesTopics(a: dict, topics: list[str]) -> bool {
    for t in topics {
        if matchesFilter(a, t) { return True; }
    }
    return False;
}

def:pub app -> JsxElement {
    has dark_mode: bool = False,
        theme_mode: str = "system",
        font_scale: int = 0,
        notifications_on: bool = True,
        onboarding_step: int = 0,
        onboarding_done: bool = False,
        preferred_topics: list[str] = [],
        settings_open: bool = False,
        category: str = "All",
        search_input: str = "",
        search_query: str = "",
        saved_ids: list[str] = [],
        recent_searches: list[str] = [],
        server_articles: list[dict] = [],
        visible_count: int = 6,
        refreshing: bool = False,
        loading: bool = True,
        offline: bool = False,
        has_loaded_news: bool = False,
        saved_only: bool = False,
        feed_notice: str = "",
        empty_demo: bool = False,
        selected_article: str = "",
        action_message: str = "",
        summary_bullets: list[str] = [],
        summary_disclosure: str = "",
        summary_error: str = "",
        summary_loading: bool = False,
        listening: bool = False,
        weather_expanded: bool = True,
        weather_city: str = "Colombo",
        weather_notice: str = "",
        weather_error: bool = False,
        weather_greeting: str = "Good morning",
        weather_insight: str = "A bright day for a breezy 3-minute read on island gardens.",
        weather_temp: int = 29,
        weather_high: int = 31,
        weather_low: int = 25,
        weather_condition: str = "Clear",
        weather_icon: str = "☼",
        weather_tint: str = "clear",
        weather_loading: bool = False,
        weather_forecast: list[dict] = [{"time":"Now", "icon":"☼", "temp":"29°"}, {"time":"3 PM", "icon":"◐", "temp":"30°"}, {"time":"6 PM", "icon":"☼", "temp":"28°"}, {"time":"9 PM", "icon":"☾", "temp":"26°"}],
        debounce_handle: any = None;
    viewport = useWindowDimensions();
    tr: dict = COPY["English"] as dict;

    # On phones navigator.onLine can be undefined. Only a real `false` means offline.
    def isOnline -> bool {
        nav: any = (window as any).navigator;
        return not (nav and nav.onLine == False);
    }

    system_dark: bool = False;
    if (window as any).matchMedia {
        system_dark = (window as any).matchMedia("(prefers-color-scheme: dark)").matches;
    }
    display_dark: bool = system_dark if theme_mode == "system" else (theme_mode == "dark");
    styles = darkStyles if display_dark else lightStyles;
    palette = DARK if display_dark else LIGHT;
    eyebrow_text: str = new(Date).toLocaleDateString("en-US", {"weekday":"long", "month":"long", "day":"numeric"}).toUpperCase();

    source_articles: list[dict] = server_articles;
    show_samples = len(source_articles) == 0 and not has_loaded_news and not loading and isOnline();
    feed_articles: list[dict] = source_articles if len(source_articles) > 0 else (ARTICLES if show_samples else []);
    # Topics only put favourites first. They never hide other stories.
    if len(preferred_topics) > 0 {
        liked: list[dict] = [a for a in feed_articles if matchesTopics(a, preferred_topics)];
        others: list[dict] = [a for a in feed_articles if not matchesTopics(a, preferred_topics)];
        feed_articles = liked + others;
    }
    query_lower: str = search_query.lower();
    filtered: list[dict] = [a for a in feed_articles if matchesFilter(a, category) and (query_lower == "" or query_lower in valueOf(a["title"], "").lower() or query_lower in valueOf(a["summary"], "").lower() or query_lower in valueOf(a["source"], "").lower()) and (not saved_only or a["id"] in saved_ids)];
    visible: list[dict] = [a for (i, a) in enumerate(filtered) if i < visible_count];
    saved_total = len(saved_ids);

    async def fetch_articles(query: str = "") -> list[dict] {
        query_suffix = "?page_size=100" if query == "" else "?page_size=100&q=" + encodeURIComponent(query);
        response = await fetch(API_BASE + "/articles" + query_suffix, {"method":"GET", "headers":{"Accept":"application/json"}});
        if not response.ok { raise Exception("Articles request failed: " + str(response.status)); }
        payload: dict = await response.json() as dict;
        body: dict = payload;
        if payload["data"] and payload["data"]["result"] { body = payload["data"]["result"] as dict; }
        return body["articles"] as list[dict] if body["articles"] else [];
    }
    def mapArticles(raw_articles: list[dict]) -> list[dict] {
        mapped: list[dict] = [];
        for article in raw_articles {
            category_value = valueOf(article["category"], "general");
            region = valueOf(article["region"], "");
            label = category_value if category_value != "general" else ("local" if region == "local" else "world");
            mapped = mapped + [{"id":article["id"], "category":category_value, "region":region, "topic":label.upper(),
                "title":article["title"], "source":article["source"],
                "time":valueOf(article["time"], "Latest"), "date":valueOf(article["time"], "Latest"),
                "summary":valueOf(article["snippet"], ""), "url":article["url"],
                "image":valueOf(article["imageUrl"], "")}];
        }
        return mapped;
    }
    async def loadFeed(query: str) {
        try {
            raw_articles: list[dict] = await fetch_articles(query);
            live_articles: list[dict] = mapArticles(raw_articles);
            offline = False;
            feed_notice = "";
            if len(live_articles) > 0 {
                server_articles = live_articles;
                has_loaded_news = True;
                if query == "" {
                    localStorage.setItem("lankapulse_feed_cache", JSON.stringify(live_articles));
                    localStorage.setItem("lankapulse_has_loaded_news", "yes");
                }
            } elif query != "" {
                feed_notice = "No matches in the latest news.";
            } elif len(server_articles) == 0 {
                feed_notice = "News sources aren’t responding right now.";
            }
        } except Exception {
            offline = not isOnline();
            feed_notice = "" if offline else "Can’t load the latest news. Showing saved stories.";
        }
    }
    async def loadSearchResults(query: str) {
        await loadFeed(query);
    }
    async def refreshArticles {
        refreshing = True;
        await loadFeed(search_query);
        rememberSearch(search_query);
        visible_count = 6;
        empty_demo = False;
        refreshing = False;
    }

    can with entry {
        go_online = lambda (event: Event) { offline = False; refreshArticles(); };
        go_offline = lambda (event: Event) { offline = True; feed_notice = ""; };
        window.addEventListener("online", go_online);
        window.addEventListener("offline", go_offline);
        return lambda { window.removeEventListener("online", go_online); window.removeEventListener("offline", go_offline); };
    }
    async can with entry {
        try {
            onboarded_raw = localStorage.getItem("lankapulse_onboarded");
            onboarding_done = onboarded_raw == "yes";
            hour_now = new(Date, ).getHours();
            weather_greeting = "Good morning" if hour_now < 12 else ("Good afternoon" if hour_now < 18 else "Good evening");
            saved_raw = localStorage.getItem("lankapulse_saved_ids");
            if saved_raw { saved_ids = JSON.parse(saved_raw) as list[str]; }
            recent_raw = localStorage.getItem("lankapulse_recent_searches");
            if recent_raw { recent_searches = JSON.parse(recent_raw) as list[str]; }
            topics_raw = localStorage.getItem("lankapulse_topics");
            if topics_raw { preferred_topics = JSON.parse(topics_raw) as list[str]; }
            settings_raw = localStorage.getItem("lankapulse_settings");
            if settings_raw {
                settings: dict = JSON.parse(settings_raw) as dict;
                theme_mode = settings["theme"] as str if settings["theme"] else "system";
                dark_mode = theme_mode == "dark";
                font_scale = settings["font_scale"] as int if settings["font_scale"] else 0;
                notifications_on = settings["notifications"] as bool if settings["notifications"] is not None else True;
            }
            cached_raw = localStorage.getItem("lankapulse_feed_cache");
            if cached_raw { server_articles = JSON.parse(cached_raw) as list[dict]; }
            loaded_raw = localStorage.getItem("lankapulse_has_loaded_news");
            has_loaded_news = loaded_raw == "yes";
        } except Exception {}
        loadWeather(6.9271, 79.8612, "Colombo");
        await loadFeed("");
        loading = False;
    }
    def persistSettings {
        localStorage.setItem("lankapulse_settings", JSON.stringify({"theme": theme_mode, "font_scale": font_scale, "notifications": notifications_on}));
    }
    def completeOnboarding {
        onboarding_done = True;
        localStorage.setItem("lankapulse_onboarded", "yes");
        localStorage.setItem("lankapulse_topics", JSON.stringify(preferred_topics));
    }
    def scheduleSearch(value: str) {
        search_input = value;
        if debounce_handle { clearTimeout(debounce_handle); }
        debounce_handle = setTimeout(lambda { search_query = value.strip(); visible_count = 6; loadSearchResults(value.strip()); }, 350);
    }
    def rememberSearch(value: str) {
        clean_query = value.strip();
        if clean_query and clean_query not in recent_searches {
            recent_searches = [clean_query] + [q for q in recent_searches if q != clean_query];
            recent_searches = recent_searches[:5];
            localStorage.setItem("lankapulse_recent_searches", JSON.stringify(recent_searches));
        }
    }
    def toggleSaved(article_id: str) {
        next_saved_ids: list[str] = [sid for sid in saved_ids if sid != article_id] if article_id in saved_ids else saved_ids + [article_id];
        saved_ids = next_saved_ids;
        localStorage.setItem("lankapulse_saved_ids", JSON.stringify(next_saved_ids));
    }
    async def makeArticleSummary {
        summary_loading = True;
        summary_error = "";
        try {
            response = await fetch(API_BASE + "/summarize", {"method": "POST", "headers": {"Content-Type": "application/json"}, "body": JSON.stringify({"title": chosen["title"], "snippet": chosen["summary"]})});
            payload = await response.json();
            data: dict = payload["data"] as dict if payload["data"] else {};
            result: dict = data["result"] as dict if data["result"] else (payload["error"] as dict if payload["error"] else payload);
            if result["error"] {
                summary_error = valueOf(result["message"], "AI summaries are unavailable right now.");
            } else {
                summary_bullets = result["bullets"] as list[str];
                summary_disclosure = result["disclosure"] as str;
            }
        } except Exception {
            summary_error = "Summary service is unavailable. Please try again.";
        }
        summary_loading = False;
    }
    def listenToArticle {
        browser_window: any = window as any;
        speech: any = browser_window.speechSynthesis;
        if speech {
            if listening { speech.cancel(); listening = False; }
            else {
                utterance: any = new(browser_window.SpeechSynthesisUtterance, (chosen["title"] as str) + ". " + (chosen["summary"] as str));
                utterance.onend = lambda { listening = False; };
                utterance.onerror = lambda { listening = False; };
                speech.speak(utterance);
                listening = True;
                action_message = "Reading this short story preview aloud.";
            }
        } else { action_message = "Audio playback is not available on this device."; }
    }
    def toggleTopic(topic: str) {
        preferred_topics = [p for p in preferred_topics if p != topic] if topic in preferred_topics else preferred_topics + [topic];
        localStorage.setItem("lankapulse_topics", JSON.stringify(preferred_topics));
    }
    def setTheme(mode: str) {
        theme_mode = mode;
        dark_mode = mode == "dark";
        persistSettings();
    }
    def weatherDescription(code: int) -> str {
        if code == 0 { return "Clear"; }
        if code <= 2 { return "Partly cloudy"; }
        if code == 3 { return "Cloudy"; }
        if code <= 48 { return "Misty"; }
        if code <= 57 { return "Drizzle"; }
        if code <= 67 { return "Rain"; }
        if code <= 77 { return "Snow"; }
        if code <= 82 { return "Showers"; }
        if code <= 86 { return "Snow showers"; }
        if code <= 99 { return "Thunderstorm"; }
        return "Changeable";
    }
    def weatherEmoji(code: int) -> str {
        if code == 0 { return "☼"; }
        if code <= 2 { return "◐"; }
        if code <= 3 { return "☁"; }
        if code <= 48 { return "≋"; }
        if code <= 67 or code <= 82 { return "☂"; }
        if code <= 86 { return "❄"; }
        return "ϟ";
    }
    def weatherColor(code: int) -> str {
        return "night" if new(Date).getHours() >= 20 or new(Date).getHours() < 6 else ("rain" if code >= 51 and code <= 82 else "clear");
    }
    async def loadWeather(latitude: float, longitude: float, fixed_city: str = "") {
        weather_loading = True;
        weather_error = False;
        weather_notice = "Finding local conditions…";
        try {
            weather_response = await fetch("https://api.open-meteo.com/v1/forecast?latitude=" + str(latitude) + "&longitude=" + str(longitude) + "&current=temperature_2m,weather_code&daily=temperature_2m_max,temperature_2m_min&hourly=temperature_2m,weather_code&forecast_days=1&timezone=auto");
            if not weather_response.ok { raise Exception("Weather request failed"); }
            weather_data: dict = await weather_response.json() as dict;
            current_data: dict = weather_data["current"] as dict;
            daily_data: dict = weather_data["daily"] as dict;
            hourly_data: dict = weather_data["hourly"] as dict;
            code = current_data["weather_code"] as int;
            weather_temp = round(current_data["temperature_2m"] as float);
            weather_high = round((daily_data["temperature_2m_max"] as list)[0] as float);
            weather_low = round((daily_data["temperature_2m_min"] as list)[0] as float);
            weather_condition = weatherDescription(code);
            weather_icon = weatherEmoji(code);
            weather_tint = weatherColor(code);
            weather_insight = "Bring an umbrella and enjoy a cozy 3-minute read." if code >= 51 and code <= 82 else ("A clear-sky day for a breezy 3-minute read." if code <= 2 else "Take it slow with a 3-minute read between the clouds.");
            times: list[str] = hourly_data["time"] as list[str];
            temps: list[float] = hourly_data["temperature_2m"] as list[float];
            codes: list[int] = hourly_data["weather_code"] as list[int];
            next_slots: list[dict] = [];
            current_hour = new(Date).getHours();
            for slot in [0, 1, 2, 3] {
                slot_index = min(current_hour + slot * 3, len(times) - 1);
                time_label = "Now" if slot == 0 else times[slot_index].split("T")[1];
                slot_code: int = codes[slot_index] as int;
                slot_temp: float = temps[slot_index] as float;
                next_slots.append({"time":time_label, "icon":weatherEmoji(slot_code), "temp":str(round(slot_temp)) + "°"});
            }
            weather_forecast = next_slots;
            if fixed_city != "" {
                weather_city = fixed_city;
            } else {
                weather_city = "Your area";
                try {
                    place_response = await fetch("https://geocoding-api.open-meteo.com/v1/reverse?latitude=" + str(latitude) + "&longitude=" + str(longitude) + "&language=en&format=json");
                    if place_response.ok {
                        place_data: dict = await place_response.json() as dict;
                        place_results: list[dict] = place_data["results"] as list[dict] if place_data["results"] else [];
                        if len(place_results) > 0 { weather_city = place_results[0]["name"] as str; }
                    }
                } except Exception {}
            }
            weather_notice = "Live local forecast · Open-Meteo";
        } except Exception {
            weather_error = True;
            weather_notice = "";
            weather_city = "Colombo";
            weather_temp = 29;
            weather_high = 31;
            weather_low = 25;
            weather_condition = "Clear";
            weather_icon = "☼";
            weather_tint = "clear";
        }
        weather_loading = False;
    }
    def requestWeatherLocation {
        browser_window: any = window as any;
        geo: any = browser_window.navigator.geolocation;
        if geo {
            geo.getCurrentPosition(lambda (position: any) { loadWeather(position.coords.latitude, position.coords.longitude); }, lambda (error: any) {
                weather_city = "Colombo";
                weather_notice = "Location unavailable. Showing Colombo conditions.";
            }, {"timeout": 8000, "maximumAge": 300000});
        } else { weather_notice = "Location isn’t available here. Showing Colombo conditions."; }
    }
    chosen: dict = {};
    for a in feed_articles {
        if a["id"] == selected_article { chosen = a; }
    }
    if not onboarding_done {
        slide_title = "A little closer to home" if onboarding_step == 0 else "Pick what you love";
        slide_body = "A warm English-language briefing from Sri Lanka and around the world." if onboarding_step == 0 else "Choose a few topics and we’ll tune your daily reading list.";
        slide_art = "☀" if onboarding_step == 0 else "✿";
        return <ScrollView style={[styles.screen, {"height": viewport.height}]} contentContainerStyle={styles.screenContent}>
            <View style={styles.brandRow}><View style={styles.brandMark}><Text style={styles.brandMarkText}>L</Text></View><Text style={styles.brand}>LankaPulse</Text></View>
            <View style={styles.onboardHero}><Text style={styles.onboardArt}>{slide_art}</Text><Text style={styles.headline}>{slide_title}</Text><Text style={styles.subtitle}>{slide_body}</Text></View>
            {if onboarding_step == 1 {
                <View style={styles.topicGrid}>{[<Pressable key={topic} style={styles.categoryChipActive if topic in preferred_topics else styles.categoryChip} onPress={lambda { toggleTopic(topic); }}><Text style={styles.categoryChipTextActive if topic in preferred_topics else styles.categoryChipText}>{topic}</Text></Pressable> for topic in TOPICS]}</View>
            }}
            <View style={styles.onboardDots}><Text style={styles.sectionMeta}>{"●  ○" if onboarding_step == 0 else "○  ●"}</Text></View>
            <Pressable style={styles.detailAction} onPress={lambda { if onboarding_step < 1 { onboarding_step = onboarding_step + 1; } else { completeOnboarding(); } }}><Text style={styles.detailActionText}>{tr["next"] if onboarding_step < 1 else tr["start"]}</Text></Pressable>
        </ScrollView>;
    }
    return <ScrollView style={[styles.screen, {"height": viewport.height}]} contentContainerStyle={styles.screenContent}>
        <View style={styles.topRow}>
            <View style={styles.brandRow}><View style={styles.brandMark}><Text style={styles.brandMarkText}>L</Text></View><View><Text style={styles.brand}>LankaPulse</Text><Text style={styles.edition}>A little closer to home</Text></View></View>
            <View style={styles.previewRow}>
                <Pressable style={styles.themeToggle} onPress={lambda { settings_open = not settings_open; }}><Text style={styles.savedTopText}>{tr["settings"]}</Text></Pressable>
            </View>
        </View>
        {if settings_open {
            <View style={styles.detailPanel}>
                <View style={styles.sectionRow}><Text style={styles.sectionTitle}>{tr["settings"]}</Text><Pressable style={styles.detailClose} onPress={lambda { settings_open = False; }}><Text style={styles.detailCloseText}>{tr["done"]}</Text></Pressable></View>
                <Text style={styles.category}>{tr["theme"]}</Text>
                <View style={styles.topicGrid}>{[<Pressable key={mode} style={styles.categoryChipActive if theme_mode == mode else styles.categoryChip} onPress={lambda { setTheme(mode); }}><Text style={styles.categoryChipTextActive if theme_mode == mode else styles.categoryChipText}>{mode}</Text></Pressable> for mode in ["light", "dark", "system"]]}</View>
                <Text style={styles.category}>{(tr["font"] as str) + ": " + str(font_scale + 1)}</Text>
                <View style={styles.previewRow}><Pressable style={styles.detailClose} onPress={lambda { font_scale = max(0, font_scale - 1); persistSettings(); }}><Text style={styles.detailCloseText}>A−</Text></Pressable><Pressable style={styles.detailClose} onPress={lambda { font_scale = min(2, font_scale + 1); persistSettings(); }}><Text style={styles.detailCloseText}>A+</Text></Pressable></View>
                <Text style={styles.aiDisclosure}>AI summaries use Gemini. Add MY_API_KEY in Settings → Environment, then restart the preview. News works without it.</Text>
                <Pressable style={styles.detailActionSecondary} onPress={lambda { notifications_on = not notifications_on; persistSettings(); }}><Text style={styles.detailActionSecondaryText}>{(tr["notifications"] as str) + ": " + ("On" if notifications_on else "Off")}</Text></Pressable>
            </View>
        }}
        <View style={styles.greeting}><Text style={styles.eyebrow}>{eyebrow_text}</Text><Text style={styles.headline}>{tr["home"]}</Text><Text style={styles.subtitle}>{tr["subtitle"]}</Text></View>
        <Pressable accessibilityRole="button" accessibilityLabel={"Weather details " + ("expanded" if weather_expanded else "collapsed") + ". Tap to " + ("collapse" if weather_expanded else "expand")} style={styles.weatherPill} onPress={lambda { weather_expanded = not weather_expanded; }}>
            <Text style={styles.weatherPillText}>{weather_icon + "  " + weather_city + "  ·  " + str(weather_temp) + "°"}</Text>
            <Text style={styles.weatherPillMeta}>{weather_condition + "  ·  " + ("Hide" if weather_expanded else "Plan today")}</Text>
        </Pressable>
        {if weather_expanded {
            <View style={[styles.weatherCard, styles.weatherCardRain if weather_tint == "rain" else (styles.weatherCardNight if weather_tint == "night" else styles.weatherCard)]}>
                {if weather_loading {
                    <View><View style={styles.weatherLoadingBlock}/><View style={styles.weatherLoadingWide}/><View style={styles.weatherLoadingBlock}/></View>
                } else {
                    <View>
                        {if weather_error {
                            <Pressable accessibilityRole="button" style={styles.weatherLocationButton} onPress={requestWeatherLocation}><Text style={styles.weatherError}>Weather unavailable. Tap to retry</Text></Pressable>
                        } else {
                            <View>
                                <View style={styles.weatherGreeting}><Text style={styles.weatherTitle}>{weather_greeting + " from LankaPulse"}</Text><Text style={styles.weatherMeta}>A little sunshine for your day ahead</Text></View>
                                <View style={styles.weatherTop}>
                                    <View style={styles.weatherTextBlock}>
                                        <Text style={styles.weatherTemp}>{str(weather_temp) + "°"}</Text>
                                        <Text style={styles.weatherCondition}>{weather_condition}</Text>
                                        <Text style={styles.weatherCity}>{weather_city + " · Sri Lanka"}</Text>
                                        <Text style={styles.weatherMeta}>{"H " + str(weather_high) + "°  ·  L " + str(weather_low) + "°"}</Text>
                                    </View>
                                    <View style={styles.weatherGlyphGlow}><Text style={styles.weatherGlyph}>{weather_icon}</Text></View>
                                </View>
                                <View style={styles.weatherForecastRow}>
                                    <View style={styles.weatherForecastItem}><Text style={styles.weatherForecastTime}>{weather_forecast[0]["time"]}</Text><Text style={styles.weatherForecastIcon}>{weather_forecast[0]["icon"]}</Text><Text style={styles.weatherForecastTemp}>{weather_forecast[0]["temp"]}</Text></View>
                                    <View style={styles.weatherForecastItem}><Text style={styles.weatherForecastTime}>{weather_forecast[1]["time"]}</Text><Text style={styles.weatherForecastIcon}>{weather_forecast[1]["icon"]}</Text><Text style={styles.weatherForecastTemp}>{weather_forecast[1]["temp"]}</Text></View>
                                    <View style={styles.weatherForecastItem}><Text style={styles.weatherForecastTime}>{weather_forecast[2]["time"]}</Text><Text style={styles.weatherForecastIcon}>{weather_forecast[2]["icon"]}</Text><Text style={styles.weatherForecastTemp}>{weather_forecast[2]["temp"]}</Text></View>
                                    <View style={styles.weatherForecastItem}><Text style={styles.weatherForecastTime}>{weather_forecast[3]["time"]}</Text><Text style={styles.weatherForecastIcon}>{weather_forecast[3]["icon"]}</Text><Text style={styles.weatherForecastTemp}>{weather_forecast[3]["temp"]}</Text></View>
                                </View>
                                <View style={styles.weatherInsight}><Text style={styles.weatherInsightText}>{weather_insight}</Text></View>
                                <Pressable accessibilityRole="button" style={styles.weatherLocationButton} onPress={requestWeatherLocation}><Text style={styles.weatherLocationText}>Use my location</Text></Pressable>
                                {weather_notice != "" and <Text style={styles.weatherMeta}>{weather_notice}</Text>}
                            </View>
                        }}
                    </View>
                }}
            </View>
        }}
        <View style={styles.searchRow}><Text style={styles.searchIcon}>⌕</Text><TextInput style={styles.searchInput} value={search_input} placeholder={tr["search"]} placeholderTextColor={palette["muted"]} onChangeText={lambda (value: str) { scheduleSearch(value); }} onSubmitEditing={lambda { rememberSearch(search_input); search_query = search_input.strip(); loadSearchResults(search_input.strip()); }} />{if search_input != "" { <Pressable onPress={lambda { scheduleSearch(""); search_query = ""; }}><Text style={styles.searchIcon}>×</Text></Pressable> }}</View>
        {if len(recent_searches) > 0 and search_input == "" { <View style={styles.recentRow}>{[<Pressable key={recent} style={styles.recentChip} onPress={lambda { search_input = recent; search_query = recent; loadSearchResults(recent); }}><Text style={styles.recentText}>{recent}</Text></Pressable> for recent in recent_searches]}</View> }}
        <View style={styles.sectionRow}><Text style={styles.sectionTitle}>{"Sample stories" if show_samples else (tr["saved"] if saved_only else tr["stories"])}</Text><View style={styles.previewRow}><Pressable style={styles.savedMode} onPress={lambda { saved_only = not saved_only; visible_count = 20; }}><Text style={styles.refreshText}>{"All stories" if saved_only else "Saved · " + str(saved_total)}</Text></Pressable><Pressable style={styles.refreshButton} onPress={refreshArticles}><Text style={styles.refreshText}>{tr["refresh"] if not refreshing else "…"}</Text></Pressable></View></View>
        {if offline { <View style={styles.offlineBanner}><View style={styles.offlineDot}/><Text style={styles.offlineText}>{tr["offline"]}</Text><Pressable style={styles.offlineRetry} onPress={refreshArticles}><Text style={styles.offlineRetryText}>Retry</Text></Pressable></View> }}
        {if not offline and feed_notice != "" { <View style={styles.empty}><Text style={styles.emptyText}>{feed_notice}</Text><Pressable style={styles.detailClose} onPress={refreshArticles}><Text style={styles.detailCloseText}>Retry</Text></Pressable></View> }}
        {if loading { <View style={styles.skeletonCard}><View style={styles.skeletonImage}/><View style={styles.skeletonWide}/><View style={styles.skeletonBlock}/><View style={styles.skeletonShort}/></View> }}
        <ScrollView horizontal={True} showsHorizontalScrollIndicator={False} style={styles.categoryScroll} contentContainerStyle={styles.categoryRow}>{[<Pressable key={item} style={styles.categoryChipActive if category == item else styles.categoryChip} onPress={lambda { category = item; visible_count = 6; empty_demo = False; }}><Text style={styles.categoryChipTextActive if category == item else styles.categoryChipText}>{item}</Text></Pressable> for item in CATEGORIES]}</ScrollView>
        {if selected_article != "" {
            <View style={styles.detailPanel}>
                <Pressable style={styles.detailBack} onPress={lambda { selected_article = ""; action_message = ""; summary_bullets = []; summary_error = ""; listening = False; }}><Text style={styles.detailCloseText}>Back to headlines</Text></Pressable>
                {if chosen["image"] { <Image source={{"uri": chosen["image"]}} style={styles.detailImage} resizeMode="cover"/> }}
                <View style={styles.feedHeader}><View style={styles.previewChip}><Text style={styles.previewChipText}>{chosen["topic"]}</Text></View><Text style={styles.meta}>{chosen["time"] if chosen["time"] else "Latest"}</Text></View>
                <Text style={styles.detailHeadline}>{chosen["title"]}</Text>
                <Text style={styles.source}>{"By " + (chosen["source"] as str)}</Text>
                <Text style={styles.detailSummary}>{chosen["summary"]}</Text>
                <View style={styles.detailActionRow}>
                    <Pressable style={styles.detailActionSecondary} onPress={makeArticleSummary}><Text style={styles.detailActionSecondaryText}>{"Summarizing…" if summary_loading else "AI Summary"}</Text></Pressable>
                    <Pressable style={styles.detailActionSecondary} onPress={listenToArticle}><Text style={styles.detailActionSecondaryText}>{"Stop listening" if listening else "Listen"}</Text></Pressable>
                </View>
                <Text style={styles.sectionMeta}>AI-generated summary based only on the headline and publisher snippet.</Text>
                {if summary_loading { <View style={styles.skeletonCard}><View style={styles.skeletonBlock}/><View style={styles.skeletonBlock}/><View style={styles.skeletonShort}/></View> }}
                {if summary_error != "" { <Text style={styles.detailCloseText}>{summary_error}</Text> }}
                {if len(summary_bullets) > 0 { <View style={styles.detail}><Text style={styles.category}>AI-GENERATED SUMMARY</Text>{[<Text key={str(index)} style={styles.detailBody}>{"• " + bullet}</Text> for (index, bullet) in enumerate(summary_bullets)]}</View> }}
                <View style={styles.detailActionRow}><Pressable style={styles.detailAction} onPress={lambda { window.open(chosen["url"], "_blank"); }}><Text style={styles.detailActionText}>Read full story</Text></Pressable><Pressable style={styles.detailActionSecondary} onPress={lambda { action_message = "Share: " + (chosen["url"] as str); }}><Text style={styles.detailActionSecondaryText}>Share</Text></Pressable></View>
                <Pressable style={styles.detailActionSecondary} onPress={lambda { toggleSaved(chosen["id"] as str); }}><Text style={styles.detailActionSecondaryText}>{"Saved" if chosen["id"] in saved_ids else "Save this story"}</Text></Pressable>
                {if action_message != "" { <Text style={styles.detailCloseText}>{action_message}</Text> }}
            </View>
        }}
        <View style={styles.storyList}>
            {if len(visible) == 0 and not loading {
                <View style={styles.empty}>
                    <Text style={styles.brandMarkText}>♡</Text>
                    <Text style={styles.emptyTitle}>{"No saved stories yet" if saved_only else ("No matches just yet" if search_query != "" else "No stories in this category yet")}</Text>
                    <Text style={styles.emptyText}>{"Tap a bookmark to keep a story close by." if saved_only else ("Try a different search or topic." if search_query != "" else "Try another topic and find something lovely to read.")}</Text>
                    <Pressable style={styles.detailClose} onPress={lambda { category = "All"; empty_demo = False; }}><Text style={styles.detailCloseText}>Browse all stories</Text></Pressable>
                </View>
            }}
            {if len(visible) > 0 {
                for article in visible {
                    <Pressable key={article["id"]} style={styles.feedCard} onPress={lambda { selected_article = article["id"]; action_message = ""; }}>
                        {if article["image"] { <Image source={{"uri": article["image"]}} style={styles.thumbnail} resizeMode="cover" /> }}
                        <View style={styles.feedCardBody}>
                            <View style={styles.feedHeader}>
                                <View style={styles.previewChip}><Text style={styles.previewChipText}>{article["topic"]}</Text></View>
                                <Pressable style={styles.bookmark} onPress={lambda { toggleSaved(article["id"] as str); }}><Text style={styles.bookmarkText}>{"♥" if article["id"] in saved_ids else "♡"}</Text></Pressable>
                            </View>
                            <Text style={styles.feedHeadline}>{article["title"]}</Text>
                            <View style={styles.storyBottom}><Text style={styles.source}>{article["source"]}</Text><Text style={styles.meta}>{article["time"]}</Text></View>
                            <Text style={styles.sectionMeta}>{("Sri Lanka" if matchesFilter(article, "local") else "International") + " · Tap to read summary"}</Text>
                        </View>
                    </Pressable>
                }
            }}
        </View>
        <View style={styles.footer}><Text style={styles.footerText}>{str(saved_total) + " saved stories · LankaPulse"}</Text></View>
    </ScrollView>;
}

"""LankaPulse news reader: multilingual feed, onboarding and settings."""

import from "@jac/mobui" { View, Text, Pressable, ScrollView, Image, TextInput, useWindowDimensions }
import from services.articles { get_articles, articles_rest }
import from .theme { LIGHT, DARK, buildStyles }

glob lightStyles = buildStyles(LIGHT);
glob darkStyles = buildStyles(DARK);
glob CATEGORIES: list[str] = ["All", "Local", "World", "Sports", "Business", "Tech", "Entertainment"];
glob TOPICS: list[str] = ["Local", "World", "Sports", "Business", "Tech", "Entertainment"];
glob ARTICLES: list[dict] = [
    {"id":"a01", "category":"Local", "topic":"COMMUNITY", "title":"Colombo’s neighbourhood gardens bring new life to city streets", "source":"Daily Island", "time":"12 min ago", "date":"20 October 2026", "summary":"Residents and community groups are finding new ways to bring shade and shared green spaces to busy Colombo neighbourhoods. This short preview is original mock copy; follow the publisher for the full report.", "url":"https://example.com/daily-island/colombo-gardens", "image":"https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?w=900"},
    {"id":"a02", "category":"World", "topic":"CLIMATE", "title":"Cities share fresh ideas for greener, cooler public spaces", "source":"World Desk", "time":"28 min ago", "image":"https://images.unsplash.com/photo-1519501025264-65ba15a82390?w=900"},
    {"id":"a03", "category":"Sports", "topic":"CRICKET", "title":"Young Sri Lankan squad looks ahead to a big season", "source":"Island Sports", "time":"35 min ago", "image":"https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=900"},
    {"id":"a04", "category":"Business", "topic":"SMALL BUSINESS", "title":"Local makers find new customers at weekend markets", "source":"The Morning", "time":"48 min ago", "image":"https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=900"},
    {"id":"a05", "category":"Tech", "topic":"INNOVATION", "title":"Meet the island teams building helpful digital tools", "source":"Tech Lanka", "time":"1 hr ago", "image":"https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=900"},
    {"id":"a06", "category":"Entertainment", "topic":"ARTS", "title":"A new generation of artists lights up Colombo’s galleries", "source":"Culture Notes", "time":"1 hr ago", "image":"https://images.unsplash.com/photo-1531058020387-3be344556be6?w=900"},
    {"id":"a07", "category":"Local", "topic":"TRAVEL", "title":"Southern rail trips inspire a slower kind of weekend", "source":"Daily Island", "time":"1 hr ago", "image":"https://images.unsplash.com/photo-1474487548417-781cb71495f3?w=900"},
    {"id":"a08", "category":"World", "topic":"SCIENCE", "title":"Researchers make a promising discovery beneath the ocean", "source":"World Desk", "time":"1 hr ago", "image":"https://images.unsplash.com/photo-1518837695005-2083093ee35b?w=900"},
    {"id":"a09", "category":"Sports", "topic":"FOOTBALL", "title":"Island football clubs welcome a new community league", "source":"Island Sports", "time":"2 hrs ago", "image":"https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=900"},
    {"id":"a10", "category":"Business", "topic":"ECONOMY", "title":"Family-run tea growers bring their harvest to new shelves", "source":"The Morning", "time":"2 hrs ago", "image":"https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=900"},
    {"id":"a11", "category":"Tech", "topic":"STARTUPS", "title":"Colombo founders turn a shared idea into a growing startup", "source":"Tech Lanka", "time":"2 hrs ago", "image":"https://images.unsplash.com/photo-1521737711867-e3b97375f902?w=900"},
    {"id":"a12", "category":"Entertainment", "topic":"FILM", "title":"Local filmmakers tell intimate stories with a global audience", "source":"Culture Notes", "time":"3 hrs ago", "image":"https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=900"},
    {"id":"a13", "category":"Local", "topic":"EDUCATION", "title":"School science clubs make room for hands-on discovery", "source":"Daily Island", "time":"3 hrs ago", "image":"https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=900"},
    {"id":"a14", "category":"World", "topic":"CULTURE", "title":"Community libraries bring neighbours together through stories", "source":"World Desk", "time":"3 hrs ago", "image":"https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=900"},
    {"id":"a15", "category":"Sports", "topic":"RUNNING", "title":"Colombo’s sunrise runners turn the waterfront into a track", "source":"Island Sports", "time":"4 hrs ago", "image":"https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=900"},
    {"id":"a16", "category":"Business", "topic":"FOOD", "title":"Small cafés give traditional island flavours a fresh twist", "source":"The Morning", "time":"4 hrs ago", "image":"https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=900"},
    {"id":"a17", "category":"Tech", "topic":"SCIENCE", "title":"Young researchers explore practical solutions for clean water", "source":"Tech Lanka", "time":"5 hrs ago", "image":"https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=900"},
    {"id":"a18", "category":"Entertainment", "topic":"MUSIC", "title":"An evening of live music brings Colombo friends together", "source":"Culture Notes", "time":"5 hrs ago", "image":"https://images.unsplash.com/photo-1506157786151-b8491531f063?w=900"},
    {"id":"a19", "category":"Local", "topic":"NATURE", "title":"Coastal volunteers join hands to care for nesting sea turtles", "source":"Daily Island", "time":"6 hrs ago", "image":"https://images.unsplash.com/photo-1437622368342-7a3d73a34c8f?w=900"},
    {"id":"a20", "category":"World", "topic":"TRAVEL", "title":"A new walking route invites visitors to discover old town lanes", "source":"World Desk", "time":"6 hrs ago", "image":"https://images.unsplash.com/photo-1516483638261-f4dbaf036963?w=900"}
];

glob COPY: dict = {
    "English": {"home":"The day, in the know.", "subtitle":"A thoughtful read from home and around the world.", "stories":"Today’s stories", "saved":"Saved stories", "search":"Search headlines, topics, sources", "refresh":"Refresh", "onboarding":"A little closer to home", "next":"Next", "start":"Start reading", "topics":"Pick what you love", "settings":"Settings", "theme":"Theme", "font":"Font size", "notifications":"Notifications", "done":"Done", "offline":"You’re offline · Showing your last saved feed"},
};

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
        saved_only: bool = False,
        feed_notice: str = "",
        empty_demo: bool = False,
        selected_article: str = "",
        action_message: str = "",
        debounce_handle: any = None;
    viewport = useWindowDimensions();
    styles = darkStyles if dark_mode else lightStyles;
    palette = DARK if dark_mode else LIGHT;
    tr: dict = COPY["English"] as dict;
    display_dark = False if theme_mode == "system" else dark_mode;
    styles = darkStyles if display_dark else lightStyles;
    palette = DARK if display_dark else LIGHT;
    source_articles: list[dict] = server_articles;
    feed_articles: list[dict] = source_articles if len(source_articles) > 0 else ARTICLES;
    if len(preferred_topics) > 0 {
        feed_articles = [a for a in feed_articles if a["category"] in preferred_topics];
    }
    filtered: list[dict] = [a for a in feed_articles if (category == "All" or a["category"] == category) and (search_query == "" or search_query.lower() in (a["title"] as str).lower() or search_query.lower() in (a["summary"] as str).lower() or search_query.lower() in (a["source"] as str).lower()) and (not saved_only or a["id"] in saved_ids)];
    visible: list[dict] = [a for (i, a) in enumerate(filtered) if i < visible_count];
    saved_total = len(saved_ids);
    async can with entry {
        try {
            onboarded_raw = localStorage.getItem("lankapulse_onboarded");
            onboarding_done = onboarded_raw == "yes";
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
        } except Exception {}
        try {
            live_articles: list[dict] = (await fetch_live_articles()) as list[dict];
            if len(live_articles) > 0 {
                server_articles = live_articles;
                localStorage.setItem("lankapulse_feed_cache", JSON.stringify(server_articles));
                offline = False;
                feed_notice = "";
            } else {
                feed_notice = "Live feeds are quiet right now. Showing saved headlines.";
            }
        } except Exception {
            offline = True;
            feed_notice = "";
        }
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
    async def loadSearchResults(query: str) {
        try {
            live_results: list[dict] = (await fetch_live_articles(query, 1)) as list[dict];
            if len(live_results) > 0 {
                server_articles = live_results;
                localStorage.setItem("lankapulse_feed_cache", JSON.stringify(server_articles));
                offline = False;
                feed_notice = "";
            } elif query and not offline {
                feed_notice = "No live stories match that search." if len(server_articles) == 0 else "";
            }
        } except Exception {
            offline = True;
            feed_notice = "" if len(server_articles) > 0 else "Couldn’t reach the news desk. Tap Refresh to try again.";
        }
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
        saved_ids = [sid for sid in saved_ids if sid != article_id] if article_id in saved_ids else saved_ids + [article_id];
        localStorage.setItem("lankapulse_saved_ids", JSON.stringify(saved_ids));
    }
    async def refreshArticles {
        refreshing = True;
        try {
            live_articles: list[dict] = (await fetch_live_articles(search_query, 1)) as list[dict];
            if len(live_articles) > 0 {
                server_articles = live_articles;
                localStorage.setItem("lankapulse_feed_cache", JSON.stringify(server_articles));
                offline = False;
                feed_notice = "";
            } elif len(server_articles) == 0 {
                feed_notice = "Live feeds are quiet right now. Showing sample headlines.";
            }
        } except Exception {
            offline = True;
            feed_notice = "" if len(server_articles) > 0 else "News sources are unavailable. Showing sample headlines.";
        }
        rememberSearch(search_query);
        visible_count = 6;
        empty_demo = False;
        refreshing = False;
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
                <Pressable style={styles.detailActionSecondary} onPress={lambda { notifications_on = not notifications_on; persistSettings(); }}><Text style={styles.detailActionSecondaryText}>{(tr["notifications"] as str) + ": " + ("On" if notifications_on else "Off")}</Text></Pressable>
            </View>
        }}
        <View style={styles.greeting}><Text style={styles.eyebrow}>TUESDAY, OCTOBER 20</Text><Text style={styles.headline}>{tr["home"]}</Text><Text style={styles.subtitle}>{tr["subtitle"]}</Text></View>
        <View style={styles.searchRow}><Text style={styles.searchIcon}>⌕</Text><TextInput style={styles.searchInput} value={search_input} placeholder={tr["search"]} placeholderTextColor={palette["muted"]} onChangeText={lambda (value: str) { scheduleSearch(value); }} onSubmitEditing={lambda { rememberSearch(search_input); search_query = search_input.strip(); loadSearchResults(search_input.strip()); }} />{if search_input != "" { <Pressable onPress={lambda { scheduleSearch(""); search_query = ""; }}><Text style={styles.searchIcon}>×</Text></Pressable> }}</View>
        {if len(recent_searches) > 0 and search_input == "" { <View style={styles.recentRow}>{[<Pressable key={recent} style={styles.recentChip} onPress={lambda { search_input = recent; search_query = recent; loadSearchResults(recent); }}><Text style={styles.recentText}>{recent}</Text></Pressable> for recent in recent_searches]}</View> }}
        <View style={styles.sectionRow}><Text style={styles.sectionTitle}>{tr["saved"] if saved_only else tr["stories"]}</Text><View style={styles.previewRow}><Pressable style={styles.savedMode} onPress={lambda { saved_only = not saved_only; visible_count = 20; }}><Text style={styles.refreshText}>{"All stories" if saved_only else "Saved · " + str(saved_total)}</Text></Pressable><Pressable style={styles.refreshButton} onPress={refreshArticles}><Text style={styles.refreshText}>{tr["refresh"] if not refreshing else "…"}</Text></Pressable></View></View>
        {if offline { <View style={styles.offlineBanner}><View style={styles.offlineDot}/><Text style={styles.offlineText}>{tr["offline"]}</Text></View> }}
        {if feed_notice != "" { <View style={styles.empty}><Text style={styles.emptyText}>{feed_notice}</Text><Pressable style={styles.detailClose} onPress={refreshArticles}><Text style={styles.detailCloseText}>Retry</Text></Pressable></View> }}
        {if loading { <View style={styles.skeletonCard}><View style={styles.skeletonImage}/><View style={styles.skeletonWide}/><View style={styles.skeletonBlock}/><View style={styles.skeletonShort}/></View> }}
        <ScrollView horizontal={True} showsHorizontalScrollIndicator={False} style={styles.categoryScroll} contentContainerStyle={styles.categoryRow}>{[<Pressable key={item} style={styles.categoryChipActive if category == item else styles.categoryChip} onPress={lambda { category = item; visible_count = 6; empty_demo = False; }}><Text style={styles.categoryChipTextActive if category == item else styles.categoryChipText}>{item}</Text></Pressable> for item in CATEGORIES]}</ScrollView>
        {if selected_article != "" { <View style={styles.detailPanel}><Pressable style={styles.detailBack} onPress={lambda { selected_article = ""; action_message = ""; }}><Text style={styles.detailCloseText}>Back to headlines</Text></Pressable><Image source={{"uri": chosen["image"]}} style={styles.detailImage} resizeMode="cover"/><View style={styles.feedHeader}><View style={styles.previewChip}><Text style={styles.previewChipText}>{chosen["topic"]}</Text></View><Text style={styles.meta}>{chosen["date"] if chosen["date"] else "Latest"}</Text></View><Text style={styles.detailHeadline}>{chosen["title"]}</Text><Text style={styles.source}>{"By " + (chosen["source"] as str)}</Text><Text style={styles.detailSummary}>{chosen["summary"]}</Text><View style={styles.detailActionRow}><Pressable style={styles.detailAction} onPress={lambda { window.open(chosen["url"], "_blank"); }}><Text style={styles.detailActionText}>Read full story</Text></Pressable><Pressable style={styles.detailActionSecondary} onPress={lambda { action_message = "Share: " + (chosen["url"] as str); }}><Text style={styles.detailActionSecondaryText}>Share</Text></Pressable></View><Pressable style={styles.detailActionSecondary} onPress={lambda { toggleSaved(chosen["id"] as str); }}><Text style={styles.detailActionSecondaryText}>{"Saved" if chosen["id"] in saved_ids else "Save this story"}</Text></Pressable>{if action_message != "" { <Text style={styles.detailCloseText}>{action_message}</Text> }}</View> }}
        <View style={styles.storyList}>
            {if len(visible) == 0 {
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
                        <Image source={{"uri": article["image"]}} style={styles.thumbnail} resizeMode="cover" />
                        <View style={styles.feedCardBody}>
                            <View style={styles.feedHeader}>
                                <View style={styles.previewChip}><Text style={styles.previewChipText}>{article["topic"]}</Text></View>
                                <Pressable style={styles.bookmark} onPress={lambda { toggleSaved(article["id"] as str); }}><Text style={styles.bookmarkText}>{"♥" if article["id"] in saved_ids else "♡"}</Text></Pressable>
                            </View>
                            <Text style={styles.feedHeadline}>{article["title"]}</Text>
                            <View style={styles.storyBottom}><Text style={styles.source}>{article["source"]}</Text><Text style={styles.meta}>{article["time"]}</Text></View>
                            <Text style={styles.sectionMeta}>{("Sri Lanka" if article["category"] == "Local" else "International") + " · Tap to read summary"}</Text>
                        </View>
                    </Pressable>
                }
            }}
        </View>
        <View style={styles.footer}><Text style={styles.footerText}>{str(saved_total) + " saved stories · LankaPulse"}</Text></View>
    </ScrollView>;
}

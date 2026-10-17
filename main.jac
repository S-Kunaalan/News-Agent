"""LankaPulse home feed with mock stories and reader-friendly controls."""

import from "@jac/mobui" { View, Text, Pressable, ScrollView, Image, useWindowDimensions }
import from .theme { LIGHT, DARK, buildStyles }

glob lightStyles = buildStyles(LIGHT);
glob darkStyles = buildStyles(DARK);
glob CATEGORIES: list[str] = ["All", "Local", "World", "Sports", "Business", "Tech", "Entertainment"];
glob ARTICLES: list[dict] = [
    {"id":"a01", "category":"Local", "topic":"COMMUNITY", "title":"Colombo’s neighbourhood gardens bring new life to city streets", "source":"Daily Island", "time":"12 min ago", "image":"https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?w=900"},
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

def:pub app -> JsxElement {
    has dark_mode: bool = False,
        category: str = "All",
        saved_ids: list[str] = [],
        visible_count: int = 6,
        refreshing: bool = False,
        empty_demo: bool = False;
    viewport = useWindowDimensions();
    styles = darkStyles if dark_mode else lightStyles;
    palette = DARK if dark_mode else LIGHT;
    filtered: list[dict] = [a for a in ARTICLES if category == "All" or a["category"] == category];
    visible: list[dict] = [a for (i, a) in enumerate(filtered) if i < visible_count];
    saved_total = len(saved_ids);
    return <ScrollView style={[styles.screen, {"height": viewport.height}]} contentContainerStyle={styles.screenContent}>
        <View style={styles.topRow}>
            <View style={styles.brandRow}>
                <View style={styles.brandMark}><Text style={styles.brandMarkText}>L</Text></View>
                <View>
                    <Text style={styles.brand}>LankaPulse</Text>
                    <Text style={styles.edition}>A little closer to home</Text>
                </View>
            </View>
            <Pressable style={styles.themeToggle} onPress={lambda { dark_mode = not dark_mode; }}>
                <Text style={styles.savedTopText}>{"Light" if dark_mode else "Dark"}</Text>
            </Pressable>
        </View>

        <View style={styles.greeting}>
            <Text style={styles.eyebrow}>TUESDAY, OCTOBER 20</Text>
            <Text style={styles.headline}>The day, in the know.</Text>
            <Text style={styles.subtitle}>A thoughtful read from home and around the world.</Text>
        </View>

        <View style={styles.sectionRow}>
            <Text style={styles.sectionTitle}>Today’s stories</Text>
            <Pressable style={styles.refreshButton} onPress={lambda {
                refreshing = True;
                visible_count = 6;
                empty_demo = False;
                refreshing = False;
            }}>
                <Text style={styles.refreshText}>{"Refreshed" if refreshing else "Refresh"}</Text>
            </Pressable>
        </View>

        <ScrollView horizontal={True} showsHorizontalScrollIndicator={False} style={styles.categoryScroll} contentContainerStyle={styles.categoryRow}>
            {[<Pressable key={item} style={styles.categoryChipActive if category == item else styles.categoryChip} onPress={lambda { category = item; visible_count = 6; empty_demo = False; }}>
                <Text style={styles.categoryChipTextActive if category == item else styles.categoryChipText}>{item}</Text>
            </Pressable> for item in CATEGORIES]}
        </ScrollView>

        <View style={styles.storyList}>
            {if empty_demo or len(visible) == 0 {
                <View style={styles.empty}>
                    <Text style={styles.brandMarkText}>♡</Text>
                    <Text style={styles.emptyTitle}>No stories in this category yet</Text>
                    <Text style={styles.emptyText}>Try another topic and find something lovely to read.</Text>
                    <Pressable style={styles.detailClose} onPress={lambda { category = "All"; empty_demo = False; }}>
                        <Text style={styles.detailCloseText}>Browse all stories</Text>
                    </Pressable>
                </View>
                skip;
            }}
            {[<View key={article["id"]} style={styles.feedCard}>
                <Image source={{"uri": article["image"]}} style={styles.thumbnail} resizeMode="cover" />
                <View style={styles.feedCardBody}>
                    <View style={styles.feedHeader}>
                        <View style={styles.previewChip}><Text style={styles.previewChipText}>{article["topic"]}</Text></View>
                        <Pressable style={styles.bookmark} onPress={lambda {
                            if article["id"] in saved_ids { saved_ids = [sid for sid in saved_ids if sid != article["id"]]; }
                            else { saved_ids = saved_ids + [article["id"]]; }
                        }}>
                            <Text style={styles.bookmarkText}>{"♥" if article["id"] in saved_ids else "♡"}</Text>
                        </Pressable>
                    </View>
                    <Text style={styles.feedHeadline}>{article["title"]}</Text>
                    <View style={styles.storyBottom}>
                        <Text style={styles.source}>{article["source"]}</Text>
                        <Text style={styles.meta}>{article["time"]}</Text>
                    </View>
                    <Text style={styles.sectionMeta}>{article["category"] + " · Source story link coming soon"}</Text>
                </View>
            </View> for article in visible]}
        </View>

        {if visible_count < len(filtered) and not empty_demo {
            <Pressable style={styles.loadMore} onPress={lambda { visible_count = visible_count + 6; }}>
                <Text style={styles.loadMoreText}>Load more stories</Text>
            </Pressable>
        }}
        {if visible_count >= len(filtered) and not empty_demo {
            <Pressable style={styles.loadMore} onPress={lambda { empty_demo = True; }}>
                <Text style={styles.loadMoreText}>You’re all caught up · Show empty state</Text>
            </Pressable>
        }}
        <View style={styles.footer}>
            <Text style={styles.footerText}>{str(saved_total) + " saved stories · Mock headlines for preview"}</Text>
        </View>
    </ScrollView>;
}

"""Island Brief, a friendly daily reader for Sri Lankan and world news."""

import from "@jac/mobui" { View, Text, Pressable, ScrollView, useWindowDimensions }
import from .theme { DARK, buildStyles }

glob styles = buildStyles(DARK);
glob STORIES: list[dict] = [
    {"id": "s1", "region": "Sri Lanka", "category": "COMMUNITY", "title": "Colombo’s new green corridors bring shade back to busy streets", "summary": "Neighbourhood planting projects are transforming everyday walks, with residents helping care for young trees across the city.", "source": "Daily Island", "time": "18 min ago", "detail": "Community groups and city planners are working together to add trees and shaded walking routes in some of Colombo’s busiest neighbourhoods. Organisers say the locally led planting programme will connect parks, schools and public spaces while helping make daily journeys more comfortable."},
    {"id": "s2", "region": "Sri Lanka", "category": "EDUCATION", "title": "Island schools explore hands-on science in new classroom programme", "summary": "Teachers are bringing practical experiments into lessons to help young learners discover science together.", "source": "Island Observer", "time": "42 min ago", "detail": "A new classroom initiative is giving students more opportunities to learn science by doing. Participating teachers are sharing activity-based lessons and simple experiments that make it easier to connect classroom topics with the world around them."},
    {"id": "s3", "region": "Sri Lanka", "category": "TRAVEL", "title": "Southern rail journeys welcome more weekend visitors", "summary": "Local businesses along the route are preparing for a lively season of coastal day trips and slower travel.", "source": "The Morning Post", "time": "1 hr ago", "detail": "Small businesses in southern towns are getting ready to welcome visitors taking weekend rail trips. Cafes, guesthouses and community guides say travellers are increasingly keen to spend time in local markets and explore at an unhurried pace."},
    {"id": "w1", "region": "World", "category": "CLIMATE", "title": "Cities share practical ideas for cooler, more walkable neighbourhoods", "summary": "Urban teams are comparing small-scale shade, water and street design projects that residents can feel day to day.", "source": "World Desk", "time": "25 min ago", "detail": "City representatives from several regions are sharing practical approaches to help people stay comfortable in warmer weather. The projects focus on shade, accessible public spaces and local participation, rather than large infrastructure changes alone."},
    {"id": "w2", "region": "World", "category": "CULTURE", "title": "Community libraries find new ways to bring readers together", "summary": "From book swaps to shared reading clubs, local organisers are making room for stories and conversation.", "source": "Global Journal", "time": "56 min ago", "detail": "Independent libraries and community reading groups are introducing welcoming, low-cost activities to bring neighbours together. Organisers say book swaps and regular reading sessions are helping make shared spaces feel more connected."},
    {"id": "w3", "region": "World", "category": "FOOD", "title": "Local food markets connect growers with a new generation of cooks", "summary": "Seasonal produce and simple cooking demonstrations are drawing curious visitors to neighbourhood markets.", "source": "The Daily Globe", "time": "1 hr ago", "detail": "Markets in several cities are pairing seasonal produce with informal cooking demonstrations. Growers say the gatherings give shoppers a chance to learn where ingredients come from and discover new ways to prepare familiar foods."}
];

def:pub app -> JsxElement {
    has region: str = "Sri Lanka",
        selected_id: str = "",
        saved_ids: list[str] = [],
        saved_only: bool = False;
    viewport = useWindowDimensions();
    visible: list[dict] = [s for s in STORIES if ((s["region"] == region) and (not saved_only or (s["id"] in saved_ids)))];
    selected: dict = {};
    for story in STORIES {
        if story["id"] == selected_id { selected = story; }
    }
    saved_count = len(saved_ids);
    return <ScrollView style={[styles.screen, {"height": viewport.height}]} contentContainerStyle={styles.screenContent}>
        <View style={styles.topRow}>
            <View style={styles.brandRow}>
                <View style={styles.brandMark}><Text style={styles.brandMarkText}>i</Text></View>
                <View>
                    <Text style={styles.brand}>Island Brief</Text>
                    <Text style={styles.edition}>Your little window to the world</Text>
                </View>
            </View>
            <Pressable style={styles.savedTopActive if saved_only else styles.savedTop} onPress={lambda { saved_only = not saved_only; selected_id = ""; }}>
                <Text style={styles.savedTopTextActive if saved_only else styles.savedTopText}>{"Saved · " + str(saved_count) if saved_count > 0 else ("Saved stories" if saved_only else "My saves")}</Text>
            </Pressable>
        </View>
        <View style={styles.greeting}>
            <Text style={styles.eyebrow}>YOUR DAILY READ</Text>
            <Text style={styles.headline}>A brighter little briefing.</Text>
            <Text style={styles.subtitle}>Good stories from home and everywhere else.</Text>
        </View>
        <View style={styles.weatherCard}>
            <View>
                <Text style={styles.weatherTitle}>A fresh start, Colombo</Text>
                <Text style={styles.weatherMeta}>Today’s edition · Tuesday, October 20</Text>
            </View>
            <Text style={styles.weatherIcon}>☀</Text>
        </View>
        <View style={styles.sectionRow}>
            <Text style={styles.sectionTitle}>{"Today’s stories"}</Text>
            <Text style={styles.sectionMeta}>{str(len(visible)) + " reads"}</Text>
        </View>
        <View style={styles.tabs}>
            <Pressable style={styles.tabActive if region == "Sri Lanka" else styles.tab} onPress={lambda { region = "Sri Lanka"; selected_id = ""; saved_only = False; }}>
                <Text style={styles.tabTextActive if region == "Sri Lanka" else styles.tabText}>Sri Lanka</Text>
            </Pressable>
            <Pressable style={styles.tabActive if region == "World" else styles.tab} onPress={lambda { region = "World"; selected_id = ""; saved_only = False; }}>
                <Text style={styles.tabTextActive if region == "World" else styles.tabText}>Around the world</Text>
            </Pressable>
        </View>
        {(
            <View style={styles.empty}>
                <Text style={styles.emptyTitle}>{"Nothing saved just yet" if saved_only else "A quiet moment"}</Text>
                <Text style={styles.emptyText}>{"Tap Save on any story and it will be waiting here for you." if saved_only else "There are no stories in this edition right now."}</Text>
            </View>
        ) if len(visible) == 0 else <View style={styles.storyList}>
            {[<View key={story["id"]} style={styles.storyCardSelected if selected_id == story["id"] else styles.storyCard}>
                <Pressable onPress={lambda { selected_id = story["id"] if selected_id != story["id"] else ""; }}>
                    <View style={styles.storyTop}>
                        <Text style={styles.category}>{story["category"]}</Text>
                        <Text style={styles.meta}>{story["time"]}</Text>
                    </View>
                    <Text style={styles.storyTitle}>{story["title"]}</Text>
                    <Text style={styles.storySummary}>{story["summary"]}</Text>
                </Pressable>
                <View style={styles.storyBottom}>
                    <Text style={styles.source}>{story["source"]}</Text>
                    <Pressable style={styles.saveButtonActive if story["id"] in saved_ids else styles.saveButton} onPress={lambda {
                        if story["id"] in saved_ids { saved_ids = [sid for sid in saved_ids if sid != story["id"]]; }
                        else { saved_ids = saved_ids + [story["id"]]; }
                    }}>
                        <Text style={styles.saveLabelActive if story["id"] in saved_ids else styles.saveLabel}>{"Saved" if story["id"] in saved_ids else "Save story"}</Text>
                    </Pressable>
                </View>
            </View> for story in visible]}
        </View>}
        {(
            <View style={styles.detail}>
                <Text style={styles.eyebrow}>THE FULL STORY</Text>
                <Text style={styles.detailTitle}>{selected["title"]}</Text>
                <Text style={styles.detailBody}>{selected["detail"]}</Text>
                <Pressable style={styles.detailClose} onPress={lambda { selected_id = ""; }}>
                    <Text style={styles.detailCloseText}>Close story</Text>
                </Pressable>
            </View>
        ) if selected_id != "" else <View/>}
        <View style={styles.footer}><Text style={styles.footerText}>A thoughtful little read, wherever you are.</Text></View>
    </ScrollView>;
}

"""LankaPulse design preview: warm reusable interface samples."""

import from "@jac/mobui" { View, Text, Pressable, ScrollView, useWindowDimensions }
import from .theme { LIGHT, DARK, buildStyles }

glob lightStyles = buildStyles(LIGHT);
glob darkStyles = buildStyles(DARK);

def:pub app -> JsxElement {
    has dark_mode: bool = False;
    viewport = useWindowDimensions();
    styles = darkStyles if dark_mode else lightStyles;
    palette = DARK if dark_mode else LIGHT;
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
            <Text style={styles.eyebrow}>DESIGN PREVIEW</Text>
            <Text style={styles.headline}>Warm news, made for you.</Text>
            <Text style={styles.subtitle}>A friendly, easy-to-read look for stories from Sri Lanka and beyond.</Text>
        </View>

        <View style={styles.previewSection}>
            <Text style={styles.previewLabel}>BUTTONS</Text>
            <View style={styles.previewRow}>
                <Pressable style={styles.previewButton}><Text style={styles.previewButtonText}>Explore news</Text></Pressable>
                <Pressable style={styles.previewOutline}><Text style={styles.previewOutlineText}>Later</Text></Pressable>
            </View>
        </View>

        <View style={styles.previewSection}>
            <Text style={styles.previewLabel}>CHIPS</Text>
            <View style={styles.previewRow}>
                <View style={styles.previewChip}><Text style={styles.previewChipText}>Sri Lanka</Text></View>
                <View style={styles.tab}><Text style={styles.tabText}>World</Text></View>
                <View style={styles.previewChip}><Text style={styles.previewChipText}>Culture</Text></View>
            </View>
        </View>

        <View style={styles.previewSection}>
            <Text style={styles.previewLabel}>NEWS CARD</Text>
            <View style={styles.previewCard}>
                <View style={styles.storyTop}>
                    <Text style={styles.category}>COMMUNITY</Text>
                    <Text style={styles.meta}>12 min read</Text>
                </View>
                <Text style={styles.storyTitle}>Colombo’s green spaces welcome a new generation of city gardeners</Text>
                <Text style={styles.storySummary}>Neighbourhood volunteers are bringing more shade and colour to shared spaces around the city.</Text>
                <View style={styles.storyBottom}>
                    <Text style={styles.source}>LankaPulse Daily</Text>
                    <Pressable style={styles.saveButtonActive}><Text style={styles.saveLabelActive}>Read story</Text></Pressable>
                </View>
            </View>
        </View>

        <View style={styles.previewSection}>
            <Text style={styles.previewLabel}>SKELETON LOADER</Text>
            <View style={styles.previewCard}>
                <View style={styles.skeletonWide}/>
                <View style={styles.skeletonBlock}/>
                <View style={styles.skeletonShort}/>
            </View>
        </View>

        <View style={styles.previewSection}>
            <Text style={styles.previewLabel}>EMPTY STATE</Text>
            <View style={styles.empty}>
                <Text style={styles.brandMarkText}>♡</Text>
                <Text style={styles.emptyTitle}>Your reading list awaits</Text>
                <Text style={styles.emptyText}>Save a story you love and find it here whenever you’re ready.</Text>
            </View>
        </View>

        <View style={styles.previewSection}>
            <Text style={styles.previewLabel}>PALETTE AND TYPE</Text>
            <View style={styles.previewCard}>
                <View style={styles.previewRow}>
                    <View style={{"width": 30, "height": 30, "borderRadius": 15, "backgroundColor": palette["accent"]}}/>
                    <View style={{"width": 30, "height": 30, "borderRadius": 15, "backgroundColor": palette["green"]}}/>
                    <View style={{"width": 30, "height": 30, "borderRadius": 15, "backgroundColor": palette["surfaceWarm"]}}/>
                    <Text style={styles.sectionMeta}>Tea-leaf green · sunset orange</Text>
                </View>
                <Text style={styles.detailTitle}>Readable together, in every language.</Text>
                <Text style={styles.detailBody}>Use a system sans-serif font with Noto Sans Sinhala and Noto Sans Tamil fallbacks for broad script coverage.</Text>
            </View>
        </View>

        <View style={styles.footer}><Text style={styles.footerText}>Rounded corners · generous spacing · soft, calm surfaces</Text></View>
    </ScrollView>;
}

import AppIntents
import WidgetKit

enum Distance2: String, CaseIterable, AppEnum {
    case mile
    case kilo

    public static var typeDisplayRepresentation: TypeDisplayRepresentation = "Timeframe"

    public static var caseDisplayRepresentations: [Distance2: DisplayRepresentation] = [
        .mile: "Miles",
        .kilo: "Kilometers",
    ]
}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")

    @Parameter(title: "Distance", default: .mile)
    var distanceType: Distance2
}

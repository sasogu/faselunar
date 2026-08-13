import WidgetKit
import SwiftUI

@main
struct MoonWidgetBundle: WidgetBundle {
  var body: some Widget {
    MoonWidget()
  }
}

struct MoonWidget: Widget {
  let kind = "MoonWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: MoonProvider()) { entry in
      MoonWidgetView(entry: entry)
    }
    .configurationDisplayName("Fase lunar")
    .description("Fase lunar del día")
    .supportedFamilies([.systemSmall, .accessoryCircular])
  }
}

import WidgetKit
import SwiftUI

private let appGroup = "group.com.sasogu.faselunar"

// MARK: - Moon phase math (mirrors MoonPhaseService in Dart)

enum MoonPhaseType: Int {
  case newMoon
  case waxingCrescent
  case firstQuarter
  case waxingGibbous
  case fullMoon
  case waningGibbous
  case lastQuarter
  case waningCrescent

  var isWaxing: Bool {
    switch self {
    case .waxingCrescent, .firstQuarter, .waxingGibbous: return true
    default: return false
    }
  }

  var name: String {
    let locale = Locale.current.language.languageCode?.identifier ?? "en"
    switch (self, locale) {
    case (.newMoon, "es"): return "Luna nueva"
    case (.newMoon, "ca"): return "Lluna nova"
    case (.waxingCrescent, "es"): return "Luna creciente"
    case (.waxingCrescent, "ca"): return "Lluna creixent"
    case (.firstQuarter, "es"): return "Cuarto creciente"
    case (.firstQuarter, "ca"): return "Quart creixent"
    case (.waxingGibbous, "es"): return "Gibosa creciente"
    case (.waxingGibbous, "ca"): return "Gibosa creixent"
    case (.fullMoon, "es"): return "Luna llena"
    case (.fullMoon, "ca"): return "Lluna plena"
    case (.waningGibbous, "es"): return "Gibosa menguante"
    case (.waningGibbous, "ca"): return "Gibosa minvant"
    case (.lastQuarter, "es"): return "Cuarto menguante"
    case (.lastQuarter, "ca"): return "Quart minvant"
    case (.waningCrescent, "es"): return "Luna menguante"
    case (.waningCrescent, "ca"): return "Lluna minvant"
    default:
      switch self {
      case .newMoon: return "New moon"
      case .waxingCrescent: return "Waxing crescent"
      case .firstQuarter: return "First quarter"
      case .waxingGibbous: return "Waxing gibbous"
      case .fullMoon: return "Full moon"
      case .waningGibbous: return "Waning gibbous"
      case .lastQuarter: return "Last quarter"
      case .waningCrescent: return "Waning crescent"
      }
    }
  }
}

struct MoonPhase {
  let date: Date
  let age: Double
  let illumination: Double
  let type: MoonPhaseType

  init(date: Date) {
    self.date = date
    let synodic = 29.53058867
    let reference = Calendar(identifier: .gregorian).date(
      from: DateComponents(
        timeZone: TimeZone(identifier: "UTC")!,
        year: 2000, month: 1, day: 6, hour: 18, minute: 14
      )
    )!
    let seconds = date.timeIntervalSince(reference)
    var age = seconds.truncatingRemainder(dividingBy: synodic * 86400) / 86400
    if age < 0 { age += synodic }
    self.age = age

    let phaseAngle = 2 * Double.pi * (age / synodic)
    self.illumination = min(max(0.5 * (1 - cos(phaseAngle)), 0), 1)

    switch age {
    case ..<1.84566: self.type = .newMoon
    case ..<5.53699: self.type = .waxingCrescent
    case ..<9.22831: self.type = .firstQuarter
    case ..<12.91963: self.type = .waxingGibbous
    case ..<16.61096: self.type = .fullMoon
    case ..<20.30228: self.type = .waningGibbous
    case ..<23.99361: self.type = .lastQuarter
    case ..<27.68493: self.type = .waningCrescent
    default: self.type = .newMoon
    }
  }
}

// MARK: - Timeline

struct MoonEntry: TimelineEntry {
  let date: Date
  let phaseDate: Date
  let phase: MoonPhase
}

struct MoonProvider: TimelineProvider {
  func placeholder(in context: Context) -> MoonEntry {
    let now = Date()
    return MoonEntry(date: now, phaseDate: now, phase: MoonPhase(date: now))
  }

  func getSnapshot(in context: Context, completion: @escaping (MoonEntry) -> Void) {
    let now = Date()
    completion(MoonEntry(date: now, phaseDate: now, phase: MoonPhase(date: now)))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<MoonEntry>) -> Void) {
    let now = Date()
    let stored = UserDefaults(suiteName: appGroup)?.object(forKey: "selectedDate") as? Double
    let phaseDate: Date
    if let ts = stored {
      phaseDate = Date(timeIntervalSince1970: ts / 1000.0)
    } else {
      phaseDate = now
    }
    let entry = MoonEntry(date: now, phaseDate: phaseDate, phase: MoonPhase(date: phaseDate))
    let refresh = Calendar.current.date(byAdding: .hour, value: 6, to: now)
      ?? now.addingTimeInterval(6 * 3600)
    completion(Timeline(entries: [entry], policy: .after(refresh)))
  }
}

// MARK: - View

struct MoonWidgetView: View {
  @Environment(\.widgetFamily) var family
  let entry: MoonEntry

  private var radius: CGFloat {
    switch family {
    case .systemSmall: return 48
    case .accessoryCircular: return 26
    default: return 42
    }
  }

  var body: some View {
    if family == .accessoryCircular {
      ZStack {
        AccessoryWidgetBackground()
        moonBody
      }
      .moonWidgetBackground(Color.clear)
    } else {
      VStack(spacing: 8) {
        moonBody
        Text(entry.phase.type.name)
          .font(.headline)
          .multilineTextAlignment(.center)
        Text(String(format: "%.1f%%", entry.phase.illumination * 100))
          .font(.caption)
          .foregroundColor(.secondary)
      }
      .padding()
      .moonWidgetBackground(
        LinearGradient(
          colors: [
            Color(red: 11 / 255, green: 16 / 255, blue: 35 / 255),
            Color(red: 28 / 255, green: 39 / 255, blue: 74 / 255),
            Color(red: 43 / 255, green: 51 / 255, blue: 93 / 255),
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
      )
    }
  }

  private var moonBody: some View {
    let clamped = min(max(entry.phase.illumination, 0), 1)
    let shift = clamped * radius * 2
    let waxing = entry.phase.type.isWaxing
    return ZStack {
      Circle().fill(Color(red: 11 / 255, green: 16 / 255, blue: 35 / 255))
      Circle().fill(Color(red: 246 / 255, green: 241 / 255, blue: 209 / 255))
      Circle().fill(Color(red: 11 / 255, green: 16 / 255, blue: 35 / 255))
        .offset(x: waxing ? -shift : shift)
      Circle().stroke(Color.white.opacity(0.25), lineWidth: 1.5)
    }
    .frame(width: radius * 2, height: radius * 2)
  }
}

extension View {
  @ViewBuilder
  func moonWidgetBackground(_ background: some View) -> some View {
    if #available(iOS 17.0, *) {
      containerBackground(for: .widget) { background }
    } else {
      self.background(background)
    }
  }
}

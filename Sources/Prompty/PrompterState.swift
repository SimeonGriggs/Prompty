import AppKit
import Observation

@Observable
final class PrompterState {
    static let maxCharactersPerLine = 40
    static let speedRange: ClosedRange<Double> = 10...400
    static let speedStep: Double = 10
    static let fontSizeRange: ClosedRange<Double> = 24...160
    static let fontSizeStep: Double = 4

    var text: String {
        didSet { UserDefaults.standard.set(text, forKey: "text") }
    }

    /// Scroll speed in points per second.
    var speed: Double {
        didSet { UserDefaults.standard.set(speed, forKey: "speed") }
    }

    var fontSize: Double {
        didSet { UserDefaults.standard.set(fontSize, forKey: "fontSize") }
    }

    var isPlaying = false

    init() {
        let defaults = UserDefaults.standard
        text = defaults.string(forKey: "text") ?? ""
        speed = defaults.object(forKey: "speed") as? Double ?? 60
        fontSize = defaults.object(forKey: "fontSize") as? Double ?? 64
    }

    var font: NSFont {
        .systemFont(ofSize: fontSize, weight: .semibold)
    }

    /// Width of the text column, sized to fit roughly `maxCharactersPerLine` characters.
    var columnWidth: CGFloat {
        let sample = "the quick brown fox jumps over a lazy dog "
        let sampleWidth = (sample as NSString).size(withAttributes: [.font: font]).width
        let averageCharacterWidth = sampleWidth / CGFloat(sample.count)
        return averageCharacterWidth * CGFloat(Self.maxCharactersPerLine)
    }

    func faster() { speed = min(speed + Self.speedStep, Self.speedRange.upperBound) }
    func slower() { speed = max(speed - Self.speedStep, Self.speedRange.lowerBound) }
    func larger() { fontSize = min(fontSize + Self.fontSizeStep, Self.fontSizeRange.upperBound) }
    func smaller() { fontSize = max(fontSize - Self.fontSizeStep, Self.fontSizeRange.lowerBound) }
}

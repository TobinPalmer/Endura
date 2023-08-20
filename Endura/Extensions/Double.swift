import Foundation

public extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    func truncate(places: Int) -> Double {
        let value = Double(floor(pow(10.0, Double(places)) * self) / pow(10.0, Double(places)))
        let truncated = value.truncatingRemainder(dividingBy: 1)
        return truncated == 0 ? value : value + truncated
    }

    func removeTrailingZeros() -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}

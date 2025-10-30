import SwiftUI

public extension Color {
  init?(hexString: String) {
    guard hexString.count == 6 else { return nil }

    let upper = hexString.uppercased()
    let rStr = String(upper.prefix(2))
    let gStr = String(upper.dropFirst(2).prefix(2))
    let bStr = String(upper.dropFirst(4).prefix(2))

    guard let r = UInt8(rStr, radix: 16),
          let g = UInt8(gStr, radix: 16),
          let b = UInt8(bStr, radix: 16)
    else {
      return nil
    }

    self.init(
      red: Double(r) / 255.0,
      green: Double(g) / 255.0,
      blue: Double(b) / 255.0,
      opacity: 1.0
    )
  }
}

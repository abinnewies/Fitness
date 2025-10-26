import SwiftUI

extension SFSymbolName: Identifiable {
  public var id: String { rawValue }
}

public extension Image {
  @available(iOS 13.0, macOS 11.0, tvOS 13.0, watchOS 6.0, *)
  init(symbol: SFSymbolName) {
    self = Image(systemName: symbol.rawValue)
  }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public func Label(_ title: LocalizedStringKey, symbol: SFSymbolName) -> Label<Text, Image> {
  Label(title, systemImage: symbol.rawValue)
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
public func Label(_ title: String, symbol: SFSymbolName) -> Label<Text, Image> {
  Label(title, systemImage: symbol.rawValue)
}

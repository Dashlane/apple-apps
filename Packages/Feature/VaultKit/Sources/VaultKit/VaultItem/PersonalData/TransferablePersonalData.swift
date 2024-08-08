import SwiftUI

public protocol TransferablePersonalData: Codable, Transferable {}

extension TransferablePersonalData {
  public static var transferRepresentation: some TransferRepresentation {
    CodableRepresentation(for: Self.self, contentType: .item)
  }
}

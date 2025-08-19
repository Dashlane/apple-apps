import Foundation

extension UserEvent {

  public struct `Performance`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `measureName`: Definition.MeasureName, `measureType`: Definition.MeasureType? = nil,
      `unit`: Definition.Unit? = nil, `value`: Double
    ) {
      self.measureName = measureName
      self.measureType = measureType
      self.unit = unit
      self.value = value
    }
    public let measureName: Definition.MeasureName
    public let measureType: Definition.MeasureType?
    public let name = "performance"
    public let unit: Definition.Unit?
    public let value: Double
  }
}

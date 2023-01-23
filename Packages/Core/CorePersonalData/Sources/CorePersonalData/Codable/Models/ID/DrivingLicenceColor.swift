import Foundation

public enum DrivingLicenceColor {
    public static var defaultValueForUnknown: DrivingLicenceColor = .restOfTheWorld
    
    case california
    case newYork
    case restOfTheUS
    case restOfTheWorld
    
    public init(countryCode: String?, state: String?) {
        guard let countryCode = countryCode else {
            self = .defaultValueForUnknown
            return
        }

        switch countryCode {
        case "US" where state == "US-0-NY":
            self = .newYork
        case "US" where state == "US-0-CA":
            self = .california
        case "US":
            self = .restOfTheUS
        default:
            self = .defaultValueForUnknown
        }
    }
}

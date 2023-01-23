import Foundation

extension Definition {

public enum `BuildType`: String, Encodable {
case `alpha`
case `beta`
case `dev`
case `nightly`
case `production`
case `qa`
}
}
import Foundation

#if os(macOS)
typealias SharedAsset = Asset
#else
typealias SharedAsset = FiberAsset
#endif

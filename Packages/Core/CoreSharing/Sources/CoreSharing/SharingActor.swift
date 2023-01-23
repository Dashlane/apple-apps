import Foundation

@globalActor
public actor SharingActor {
    public static let shared: SharingActor = SharingActor()
}

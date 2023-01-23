import Foundation

extension NSFileCoordinator {
    static func coordinateWrite(of data: Data, at url: URL, completion: (Result<Void, Error>) -> Void) {
        NSFileCoordinator().coordinate(writingItemAt: url,
                                       options: .forReplacing,
                                       error: nil) { accessor in
            do {
                try data.write(to: accessor, options: .atomic)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

import Foundation

extension NSFileCoordinator {
  func coordinateWrite(of data: Data, at url: URL, completion: (Result<Void, Error>) -> Void) {
    coordinate(
      writingItemAt: url,
      options: .forReplacing,
      error: nil
    ) { accessor in
      do {
        try data.write(to: accessor, options: [])
        completion(.success(()))
      } catch {
        completion(.failure(error))
      }
    }
  }
}

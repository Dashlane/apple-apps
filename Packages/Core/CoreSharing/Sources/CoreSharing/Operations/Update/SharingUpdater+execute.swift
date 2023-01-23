import Foundation

extension SharingUpdater {
                            func execute(maxIteration: Int = 5, _ action: (_ nextRequest: inout UpdateRequest) async throws -> Void) async throws {
        var shouldLoop: Bool = false
        var iteration: Int = 0

        repeat {
            shouldLoop = false
            iteration += 1
            do {
                var updateRequest = UpdateRequest()
                try await action(&updateRequest)

                if !updateRequest.isEmpty {
                    try await update(for: updateRequest)
                }
            }
                        catch let error as SharingInvalidActionError where iteration < maxIteration {
                logger.error("Invalid local state, perform an update loop with ids to fetch and retry")
                try await update(for: UpdateRequest(error: error), maxIteration: 1)
                shouldLoop = true
            }
                        catch is SharingInvalidActionError where iteration >= maxIteration {
                logger.fatal("Invalid local state, was not able to update local state after \(maxIteration) iterations.")
                throw SharingUpdaterError.maximumLoopExecutionReached
            }
                        catch {
                logger.fatal("Cannot execute operation", error: error)
                throw error
            }
        } while shouldLoop && iteration < maxIteration
    }
}

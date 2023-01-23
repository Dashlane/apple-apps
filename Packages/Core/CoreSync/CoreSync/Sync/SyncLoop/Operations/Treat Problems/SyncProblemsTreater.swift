import Foundation
import DashTypes

struct SyncProblemsTreater<Database: SyncableDatabase> {
    struct Output {
        let remotelyMissingTransactions: [Identifier]
        let locallyMissingTransactions: [Identifier]
    }
    
    let database: Database
    let logger: Logger
    
    func callAsFunction(forRemoteSummary remoteDataSummary: [TimestampIdPair],
                        problems existingProblems: inout Set<SyncProblem>,
                        report: inout SyncReport) throws -> Output {
        do {
            let localDataSummary = try database.makeLocalDataSummary()
    
            let problems = SyncChecker().problems(remoteTransactions: Set(remoteDataSummary),
                                                  localTransactions: Set(localDataSummary),
                                                  existingProblems: existingProblems)
            defer {
                existingProblems.formUnion(problems)
            }
            
            guard !problems.isEmpty else {
                logger.info("No problems found")
                return Output(remotelyMissingTransactions: [], locallyMissingTransactions: [])
            }
            logger.fatal("Problems found \(problems)")

            let solutions = problems.compactMap(SyncSolution.init)
            report.update(with: solutions)

            let remotelyMissingTransactions = solutions.filter(\.isUpload).map(\.identifier)
            let locallyMissingTransactions = solutions.filter(\.isDownload).map(\.identifier)
            
            logger.info("Treating problem (\(remotelyMissingTransactions.count) remotelyMissingTransaction(s) \(locallyMissingTransactions.count) locallyMissingTransaction(s))")
            
            if !remotelyMissingTransactions.isEmpty {
                try database.markAsPendingUploadItems(withIds: remotelyMissingTransactions)
            }
            return Output(remotelyMissingTransactions: remotelyMissingTransactions,
                          locallyMissingTransactions: locallyMissingTransactions)
        } catch {
            logger.error("Treat problem failed", error: error)
            throw SyncError.unknown(originalError: error)
        }
    }
}

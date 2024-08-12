import CoreData
import DashTypes
import Foundation

public enum DownloadedDataParserError: Error, Equatable {
  case invalidData(transactionId: Identifier)
}

public enum ValidationError: Error, Equatable {
  case noSettingsTransactionFound
  case invalidSettingsData
  case couldNotDecode
}

public struct IncomingDataResult<Item> {
  public let items: [Item]
  public let removedItemIds: [Identifier]
  public let timestamp: Timestamp?
  let summary: SyncSummary?
  public let errors: [Identifier: Error]
}

struct DownloadedDataParser<Database: SyncableDatabase> {
  let database: Database
  let logger: Logger
  let shouldParallelize: Bool

  func callAsFunction(_ incomingResponse: DownloadedTransactions) async -> IncomingDataResult<
    Database.Item
  > {
    return await withTaskGroup(of: ParsingResult<Database>.self) { group in
      let transactions = incomingResponse
        .transactions
        .filter { transaction in
          guard let type = PersonalDataContentType(rawValue: transaction.type) else {
            return false
          }
          return database.acceptedTypes.contains(type)
        }

      let chunkSize =
        if shouldParallelize {
          max(500, transactions.count / 5)
        } else {
          transactions.count
        }

      for transactions in transactions.chunked(into: chunkSize) {
        group.addTask(priority: .background) {
          parse(transactions)
        }
      }

      let results = await group.reduce(into: .init()) { $0 += $1 }

      let removedIds = incomingResponse.transactions
        .filter { $0.action == .backupRemove }
        .map { $0.identifier }

      let summary = SyncSummary(
        timestamp: Timestamp(incomingResponse.timestamp),
        summary: incomingResponse.summary.mapValues { dictionary in
          dictionary.mapValues(Timestamp.init)
        }
      )

      if !results.errors.isEmpty {
        logger.fatal("Parsing transaction failed \(results.errors)")
      }

      return IncomingDataResult(
        items: results.items,
        removedItemIds: removedIds.map(Identifier.init(stringLiteral:)),
        timestamp: Timestamp(incomingResponse.timestamp),
        summary: summary,
        errors: results.errors
      )
    }
  }

  private func parse(_ transactions: [DownloadedTransaction]) -> ParsingResult<Database> {
    var result = ParsingResult<Database>()
    for transaction in transactions {
      do {
        guard let decodedPersonalData = try parse(transaction) else {
          continue
        }
        result.items.append(decodedPersonalData)
      } catch {
        result.errors[Identifier(transaction.identifier)] = error
      }
    }

    return result
  }

  private func parse(_ transaction: DownloadedTransaction) throws -> Database.Item? {
    try Task.checkCancellation()

    guard let type = PersonalDataContentType(rawValue: transaction.type),
      let content = transaction.content,
      transaction.action != .backupRemove
    else {
      return nil
    }

    guard let encryptedData = Data(base64Encoded: content) else {
      throw DownloadedDataParserError.invalidData(
        transactionId: Identifier(transaction.identifier)
      )
    }

    return try database.parse(
      fromEncryptedTransactionData: encryptedData,
      identifier: Identifier(transaction.identifier),
      type: type,
      timestamp: Timestamp(transaction.backupDate))
  }
}

private struct ParsingResult<Database: SyncableDatabase> {
  static func += (result1: inout Self, result12: Self) {
    result1.errors.merge(result12.errors) { errors, _ in
      errors
    }
    result1.items += result12.items
  }

  var items: [Database.Item] = []
  var errors: [Identifier: Error] = [:]
}

extension RandomAccessCollection where Index == Int {
  func chunked(into size: Int) -> [[Element]] {
    guard size > 0 else {
      return []
    }

    guard size <= count else {
      return [Array(self)]
    }

    return stride(from: 0, to: count, by: size).map {
      Array(self[$0..<Swift.min($0 + size, count)])
    }
  }
}

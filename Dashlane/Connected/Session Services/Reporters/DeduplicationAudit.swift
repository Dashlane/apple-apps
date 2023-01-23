import Foundation
import CorePersonalData
import DashlaneReportKit
import DashlaneAppKit
import CoreSettings

class DeduplicationAudit {
    let credentials: [Credential]
    let linkedDomainService: LinkedDomainService
    let userSettings: UserSettings
    let usageLogService: UsageLogServiceProtocol
    let queue = DispatchQueue(label: "deduplicationAudit", qos: .background)

    init(credentials: [Credential],
         linkedDomainService: LinkedDomainService,
         usageLogService: UsageLogServiceProtocol,
         userSettings: UserSettings) {
        self.credentials = credentials
        self.linkedDomainService = linkedDomainService
        self.usageLogService = usageLogService
        self.userSettings = userSettings
    }

                func performAuditIfNeeded() {
        guard userSettings[.hasSentDeduplicationAudit] != true else {
            return
        }

        queue.async {
            let duplicates = self.computeDuplicates(for: self.credentials)
            duplicates.forEach { self.usageLogService.post($0) }
            self.userSettings[.hasSentDeduplicationAudit] = true
        }
    }

            func computeDuplicates(for credentials: [Credential]) -> [UsageLogCode141AuditDup] {
        let relevantCredentials = credentials.filter { !$0.editableURL.isEmpty }
        var groupedByDomain = Dictionary(grouping: relevantCredentials) { $0.url?.domain?.name ?? "other" }
        let domains = groupedByDomain.keys

        let groups = domains.compactMap { domain -> [Credential]? in
            var associatedGroup: [Credential] = []

                        guard let currentCredentials = groupedByDomain[domain] else { return nil }
            associatedGroup += currentCredentials
            groupedByDomain.removeValue(forKey: domain)

                        linkedDomainService[domain]?.forEach { linkedDomain in
                if let credentials = groupedByDomain[linkedDomain] {
                    associatedGroup += credentials
                    groupedByDomain.removeValue(forKey: linkedDomain)
                }
            }
            return associatedGroup.count > 1 ? associatedGroup : nil
        }

        let similarCredentials = groups
            .filter { $0.count > 1 }
            .map { Array($0.dynamicGroupingByLoginAndEmail().values) }
            .flatMap { $0 }
            .filter { $0.count > 1 }

        let checkId = String.randomAlphanumeric(ofLength: 5)
        let totalNbCredentials = credentials.count
        let totalNbDuplicates = similarCredentials.flatMap { $0 }.count
        let totalNbDuplicateGroups = similarCredentials.count

        let logs: [UsageLogCode141AuditDup] = similarCredentials
            .enumerated()
            .compactMap { index, similarCredentials in
                self.computeLog(for: similarCredentials,
                                index: index + 1,
                                checkId: checkId,
                                totalNbCredentials: totalNbCredentials,
                                totalNbDuplicates: totalNbDuplicates,
                                totalNbDuplicateGroups: totalNbDuplicateGroups)
            }

        return logs
    }

        func computeLog(for similarCredentials: [Credential],
                    index: Int,
                    checkId: String,
                    totalNbCredentials: Int,
                    totalNbDuplicates: Int,
                    totalNbDuplicateGroups: Int) -> UsageLogCode141AuditDup? {
        guard similarCredentials.count > 1 else { return nil }
        let nbDifferentHosts: Int = Set<String>(similarCredentials.compactMap { $0.url?.host?.removeWwwPrefix() }).count
        let nbDifferentPasswords: Int = Set<String>(similarCredentials.map(\.password)).count
        let exactDuplicates = Dictionary(grouping: similarCredentials) { credential -> String in
            return (credential.url?.host?.removeWwwPrefix() ?? "") + credential.password + credential.email + credential.login + credential.secondaryLogin
        }
        .values

        let nbExactDuplicates = exactDuplicates
            .map { $0.count > 1 ? $0.count : 0 }
            .reduce(0, +)

        return UsageLogCode141AuditDup(check_id: checkId,
                                       total_nb_credentials: totalNbCredentials,
                                       total_nb_duplicates: totalNbDuplicates,
                                       total_nb_duplicate_groups: totalNbDuplicateGroups,
                                       group_index: index,
                                       group_nb_credentials: similarCredentials.count,
                                       group_nb_exact_duplicates: nbExactDuplicates,
                                       group_nb_different_hosts: nbDifferentHosts,
                                       group_nb_different_passwords: nbDifferentPasswords)
    }
}

private extension String {
        func removeWwwPrefix() -> String {
        guard self.hasPrefix("www.") else { return self }
        return String(self.dropFirst(4))
    }
}

private extension Array where Element == Credential {
                    func dynamicGroupingByLoginAndEmail() -> [Set<String>: [Credential]] {
        var result: [Set<String>: [Credential]] = [:]
        self.forEach { element in
            let candidateKey = element.groupingKeys

            let matchedExistingKeys: [Set<String>] = result.keys.filter {
                !candidateKey.isDisjoint(with: $0)
            }

            if matchedExistingKeys.isEmpty {
                result.updateValue([element], forKey: candidateKey)
            } else {
                                let newKey: Set<String> = matchedExistingKeys.reduce([]) { acc, set -> Set<String> in
                    acc.union(set)
                }
                .union(candidateKey)

                                var newValues: [Credential] = []
                matchedExistingKeys.forEach { key in
                    guard let values = result[key] else { return }
                    newValues.append(contentsOf: values)
                    result.removeValue(forKey: key)
                }

                                newValues.append(element)
                                result.updateValue(newValues, forKey: newKey)
            }

        }
        return result
    }
}

private extension Credential {
        var groupingKeys: Set<String> {
        return Set<String>([email, login]).filter { !$0.isEmpty }
    }
}

extension UsageLogCode141AuditDup {
    var testDescription: String {
        return "\(totalNbCredentials) | \(totalNbDuplicates) | \(totalNbDuplicateGroups) | \(groupNbCredentials) | \(groupNbExactDuplicates) | \(groupNbDifferentHosts) | \(groupNbDifferentPasswords)"
    }
}

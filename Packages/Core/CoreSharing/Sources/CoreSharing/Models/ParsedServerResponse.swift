import Foundation
import DashlaneAPI

public struct ParsedServerResponse {
        public var userGroups: [UserGroup]
        public var userGroupErrors: [UserGroupError]
        public var itemGroups: [ItemGroup]
        public var itemGroupErrors: [ItemGroupError]
        public var items: [ItemContentCache]
        public var itemErrors: [ItemError]

    init(userGroups: [UserGroup] = [],
         userGroupErrors: [UserGroupError] = [],
         itemGroups: [ItemGroup] = [],
         itemGroupErrors: [ItemGroupError] = [],
         items: [ItemContentCache] = [],
         itemErrors: [ItemError] = []) {
        self.userGroups = userGroups
        self.userGroupErrors = userGroupErrors
        self.itemGroups = itemGroups
        self.itemGroupErrors = itemGroupErrors
        self.items = items
        self.itemErrors = itemErrors
    }

    init(_ serverResponse: ServerResponse) {
        self.itemErrors = serverResponse.itemErrors ?? []
        self.itemGroupErrors = serverResponse.itemGroupErrors ?? []
        self.itemGroups = serverResponse.itemGroups?.map { ItemGroup($0) } ?? []
        self.items = serverResponse.items?.map { ItemContentCache($0) } ?? []
        self.userGroupErrors = serverResponse.userGroupErrors ?? []
        self.userGroups = serverResponse.userGroups?.map { UserGroup($0) } ?? []
    }
}

extension ServerResponse {
    func parsed() -> ParsedServerResponse {
        .init(self)
    }
}

public extension ParsedServerResponse {
    static func += (lhs: inout ParsedServerResponse, rhs: ParsedServerResponse) {
        lhs.userGroups += rhs.userGroups
        lhs.userGroupErrors += rhs.userGroupErrors

        lhs.itemGroups += rhs.itemGroups
        lhs.itemGroupErrors += rhs.itemGroupErrors

        lhs.items += rhs.items
        lhs.itemErrors += rhs.itemErrors
    }

    init() {
        userGroups = []
        userGroupErrors = []

        itemGroups = []
        itemGroupErrors = []

        items = []
        itemErrors = []
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

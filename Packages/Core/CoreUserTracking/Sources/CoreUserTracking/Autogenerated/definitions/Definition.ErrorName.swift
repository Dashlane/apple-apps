import Foundation

extension Definition {

public enum `ErrorName`: String, Encodable {
case `authentication`
case `dataProcessing` = "data_processing"
case `database`
case `download`
case `httpIo` = "http_io"
case `httpStatus` = "http_status"
case `itemGroupInvalidGroupAcceptSignature` = "item_group_invalid_group_accept_signature"
case `itemGroupInvalidGroupProposeSignature` = "item_group_invalid_group_propose_signature"
case `itemGroupInvalidKey` = "item_group_invalid_key"
case `itemGroupInvalidUserAcceptSignature` = "item_group_invalid_user_accept_signature"
case `itemGroupInvalidUserProposeSignature` = "item_group_invalid_user_propose_signature"
case `itemGroupNoAccess` = "item_group_no_access"
case `memory`
case `other`
case `responseContent` = "response_content"
case `upload`
}
}
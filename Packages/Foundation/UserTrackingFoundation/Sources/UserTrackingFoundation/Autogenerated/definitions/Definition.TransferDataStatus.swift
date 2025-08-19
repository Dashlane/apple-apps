import Foundation

extension Definition {

  public enum `TransferDataStatus`: String, Encodable, Sendable {
    case `exportFlowStarted` = "export_flow_started"
    case `failedToDecryptVault` = "failed_to_decrypt_vault"
    case `failedToFetchVault` = "failed_to_fetch_vault"
    case `failureDuringExport` = "failure_during_export"
    case `failureDuringImport` = "failure_during_import"
    case `fileMatched` = "file_matched"
    case `importFlowStarted` = "import_flow_started"
    case `importFlowTerminated` = "import_flow_terminated"
    case `importFlowTimeout` = "import_flow_timeout"
    case `multipleFilesSelected` = "multiple_files_selected"
    case `noDataFound` = "no_data_found"
    case `pendingSourceSelection` = "pending_source_selection"
    case `processFailure` = "process_failure"
    case `processTerminated` = "process_terminated"
    case `processTimeout` = "process_timeout"
    case `start`
    case `success`
    case `wrongFileFormat` = "wrong_file_format"
    case `wrongFilePassword` = "wrong_file_password"
    case `wrongFileStructure` = "wrong_file_structure"
  }
}

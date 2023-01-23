import Foundation

extension Definition {

public enum `ImportDataStatus`: String, Encodable {
case `failureDuringImport` = "failure_during_import"
case `importFlowTerminated` = "import_flow_terminated"
case `importFlowTimeout` = "import_flow_timeout"
case `multipleFilesSelected` = "multiple_files_selected"
case `noDataFound` = "no_data_found"
case `success`
case `wrongFileFormat` = "wrong_file_format"
case `wrongFilePassword` = "wrong_file_password"
case `wrongFileStructure` = "wrong_file_structure"
}
}
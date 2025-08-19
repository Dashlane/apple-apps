import Foundation

extension Definition {

  public enum `RiskDetectionSetupStep`: String, Encodable, Sendable {
    case `adminSeeCrdLogFromAuditLogs` = "admin_see_crd_log_from_audit_logs"
    case `adminSeeCrdLogFromInsights` = "admin_see_crd_log_from_insights"
    case `cancelRotateToken` = "cancel_rotate_token"
    case `clickChromeAdmxLink` = "click_chrome_admx_link"
    case `confirmRotateToken` = "confirm_rotate_token"
    case `copyConfigurationToken` = "copy_configuration_token"
    case `copyGpoConfigurationToken` = "copy_gpo_configuration_token"
    case `copyIntuneChromeDeviceValue` = "copy_intune_chrome_device_value"
    case `copyIntuneConfigurationToken` = "copy_intune_configuration_token"
    case `copyIntuneEdgeDeviceValue` = "copy_intune_edge_device_value"
    case `copyJamfForceInstallChromePreferenceDomain` =
      "copy_jamf_force_install_chrome_preference_domain"
    case `copyJamfForceInstallChromePropertyList` = "copy_jamf_force_install_chrome_property_list"
    case `copyJamfForceInstallEdgePreferenceDomain` =
      "copy_jamf_force_install_edge_preference_domain"
    case `copyJamfForceInstallEdgePropertyList` = "copy_jamf_force_install_edge_property_list"
    case `copyJamfPoliciesChromePreferenceDomain` = "copy_jamf_policies_chrome_preference_domain"
    case `copyJamfPoliciesEdgePreferenceDomain` = "copy_jamf_policies_edge_preference_domain"
    case `copyJamfPoliciesPropertyList` = "copy_jamf_policies_property_list"
    case `downloadChromeAndEdgeGpoFile` = "download_chrome_and_edge_gpo_file"
    case `downloadChromeGpoFile` = "download_chrome_gpo_file"
    case `downloadEdgeGpoFile` = "download_edge_gpo_file"
    case `downloadIntuneScriptFile` = "download_intune_script_file"
    case `downloadRiskActivityCsv` = "download_risk_activity_csv"
    case `errorLoadRiskDetectionInsights` = "error_load_risk_detection_insights"
    case `exportRiskDetectionCsv` = "export_risk_detection_csv"
    case `filterLogsLast30Days` = "filter_logs_last_30_days"
    case `filterLogsLast7Days` = "filter_logs_last_7_days"
    case `rotateToken` = "rotate_token"
    case `seeActivityLogs` = "see_activity_logs"
    case `startSetup` = "start_setup"
    case `turnOff` = "turn_off"
    case `turnOn` = "turn_on"
  }
}

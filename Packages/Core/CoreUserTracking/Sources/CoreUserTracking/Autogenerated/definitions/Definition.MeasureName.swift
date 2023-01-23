import Foundation

extension Definition {

public enum `MeasureName`: String, Encodable {
case `systemCpu` = "system_cpu"
case `systemMemory` = "system_memory"
case `timeToAppReady` = "time_to_app_ready"
case `timeToD` = "time_to_d"
case `timeToDropdownWebcard` = "time_to_dropdown_webcard"
case `timeToInitCarbon` = "time_to_init_carbon"
case `timeToInitPersistent` = "time_to_init_persistent"
case `timeToInitSw` = "time_to_init_sw"
case `timeToLoad` = "time_to_load"
case `timeToLoadAutofill` = "time_to_load_autofill"
case `timeToLoadLocal` = "time_to_load_local"
case `timeToLoadRemote` = "time_to_load_remote"
case `timeToLogin` = "time_to_login"
case `timeToPrepareWebcardData` = "time_to_prepare_webcard_data"
case `timeToUnlock` = "time_to_unlock"
case `webvitalsCls` = "webvitals_cls"
case `webvitalsFid` = "webvitals_fid"
case `webvitalsLcp` = "webvitals_lcp"
}
}
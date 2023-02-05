import Foundation

enum NotificationCode: Int, Hashable {
    case desktopEmail            = 1
    case trialUser               = 4
    case general                 = 100
    case token                   = 101
    case postTypeNotification    = 102
    case supportNotification     = 103
    case startM2D                = 104
    case startSafariOnBoarding   = 105
    case openMenuItem            = 106
    case openMenu                = 107
    case securityAlert           = 108
    case darkWebAlert            = 109
    case appInstall              = 300 
    case weakPassword            = 350 
    case ccExpiry                = 400
    case idExpiry                = 450
    case bastardRemindMe         = 666
    case renewal                 = 700
    case sharingEvent            = 800
    case sharingEventItemGroup   = 801
    case sharingEventUserGroup   = 802
    case receipt                 = 999
}

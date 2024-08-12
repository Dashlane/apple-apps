import CoreUserTracking
import Foundation
import VaultKit

enum VaultListCompletion {
  case enterDetail(VaultItem, UserEvent.SelectVaultItem, isEditing: Bool)
  case addItem(AddItemFlowViewModel.DisplayMode)
}

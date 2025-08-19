import CoreLocalization
import CorePersonalData
import DesignSystem
import Foundation
import SwiftTreats
import SwiftUI
import UIComponents
import VaultKit

struct ContextMenuAddressDetailView: View {

  @StateObject var model: ContextMenuAddressDetailViewModel

  init(
    model: @escaping @autoclosure () -> ContextMenuAddressDetailViewModel
  ) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    ContextMenuDetailContainerView(title: model.item.localizedTitle) {
      AutofillAvailableSection {
        if model.item.mode == .europe {
          addressFull
          zipCode
          city
        } else if model.item.mode == .europeWithState {
          addressFull
          zipCode
          city
          state
        } else if model.item.mode == .japan {
          zipCode
          city
          addressFull
        } else if model.item.mode == .asia {
          addressFull
          city
          zipCode
        } else if model.item.mode == .unitedKingdom {
          streetNumber
          streetName
          city
          state
          zipCode
        } else if model.item.mode == .northAmericaAndAustralasia {
          addressFull
          city
          state
          zipCode
        }
        country

        receiver
        building
        stairs
        floor
        door
        digitCode
      }
    }
  }

  @ViewBuilder
  private var addressFull: some View {
    if !model.item.addressFull.isEmpty {
      DisplayField(CoreL10n.KWAddressIOS.addressFull, text: model.item.addressFull)
        .contentShape(Rectangle())
        .onTapGesture {
          model.performAutofill(with: model.item.addressFull)
        }
    } else {
      EmptyView()
    }
  }

  @ViewBuilder
  private var zipCode: some View {
    if !model.item.zipCode.isEmpty {
      DisplayField(
        CoreL10n.KWAddressIOS.zipCodeFieldTitle(for: model.item.stateVariant),
        text: model.item.zipCode
      )
      .contentShape(Rectangle())
      .onTapGesture {
        model.performAutofill(with: model.item.zipCode)
      }
    } else {
      EmptyView()
    }
  }

  @ViewBuilder
  private var city: some View {
    if !model.item.city.isEmpty {
      DisplayField(CoreL10n.KWAddressIOS.city, text: model.item.city)
        .contentShape(Rectangle())
        .onTapGesture {
          model.performAutofill(with: model.item.city)
        }
    } else {
      EmptyView()
    }
  }

  @ViewBuilder
  private var state: some View {
    if let state = model.item.state?.name {
      DisplayField(CoreL10n.KWAddressIOS.stateFieldTitle(for: model.item.stateVariant), text: state)
        .contentShape(Rectangle())
        .onTapGesture {
          model.performAutofill(with: state)
        }
    } else {
      EmptyView()
    }
  }

  @ViewBuilder
  private var streetNumber: some View {
    if !model.item.streetNumber.isEmpty {
      DisplayField(CoreL10n.KWAddressIOS.streetNumber, text: model.item.streetNumber)
        .contentShape(Rectangle())
        .onTapGesture {
          model.performAutofill(with: model.item.streetNumber)
        }
    } else {
      EmptyView()
    }
  }

  @ViewBuilder
  private var streetName: some View {
    if !model.item.streetName.isEmpty {
      DisplayField(CoreL10n.KWAddressIOS.streetName, text: model.item.streetName)
        .contentShape(Rectangle())
        .onTapGesture {
          model.performAutofill(with: model.item.streetName)
        }
    } else {
      EmptyView()
    }
  }

  @ViewBuilder
  private var country: some View {
    if let country = model.item.country?.name {
      DisplayField(CoreL10n.KWAddressIOS.country, text: country)
        .contentShape(Rectangle())
        .onTapGesture {
          model.performAutofill(with: country)
        }
    } else {
      EmptyView()
    }
  }

  @ViewBuilder
  private var receiver: some View {
    if !model.item.receiver.isEmpty {
      DisplayField(CoreL10n.KWAddressIOS.receiver, text: model.item.receiver)
        .contentShape(Rectangle())
        .onTapGesture {
          model.performAutofill(with: model.item.receiver)
        }
    } else {
      EmptyView()
    }
  }

  @ViewBuilder
  private var building: some View {
    if !model.item.building.isEmpty {
      DisplayField(CoreL10n.KWAddressIOS.building, text: model.item.building)
        .contentShape(Rectangle())
        .onTapGesture {
          model.performAutofill(with: model.item.building)
        }
    } else {
      EmptyView()
    }
  }

  @ViewBuilder
  private var stairs: some View {
    if !model.item.stairs.isEmpty {
      DisplayField(CoreL10n.KWAddressIOS.stairs, text: model.item.stairs)
        .contentShape(Rectangle())
        .onTapGesture {
          model.performAutofill(with: model.item.stairs)
        }
    } else {
      EmptyView()
    }
  }

  @ViewBuilder
  private var floor: some View {
    if !model.item.floor.isEmpty {
      DisplayField(CoreL10n.KWAddressIOS.floor, text: model.item.floor)
        .contentShape(Rectangle())
        .onTapGesture {
          model.performAutofill(with: model.item.floor)
        }
    } else {
      EmptyView()
    }
  }

  @ViewBuilder
  private var door: some View {
    if !model.item.door.isEmpty {
      DisplayField(CoreL10n.KWAddressIOS.door, text: model.item.door)
        .contentShape(Rectangle())
        .onTapGesture {
          model.performAutofill(with: model.item.door)
        }
    } else {
      EmptyView()
    }
  }

  @ViewBuilder
  private var digitCode: some View {
    if !model.item.digitCode.isEmpty {
      DisplayField(CoreL10n.KWAddressIOS.digitCode, text: model.item.digitCode)
        .contentShape(Rectangle())
        .onTapGesture {
          model.performAutofill(with: model.item.digitCode)
        }
    } else {
      EmptyView()
    }
  }

}

#Preview {
  ContextMenuAddressDetailView(model: .mock())
}

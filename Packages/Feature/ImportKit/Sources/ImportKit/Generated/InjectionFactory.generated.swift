#if canImport(Combine)
  import Combine
#endif
#if canImport(CorePersonalData)
  import CorePersonalData
#endif
#if canImport(CorePremium)
  import CorePremium
#endif
#if canImport(CoreSettings)
  import CoreSettings
#endif
#if canImport(CoreUserTracking)
  import CoreUserTracking
#endif
#if canImport(DashTypes)
  import DashTypes
#endif
#if canImport(Foundation)
  import Foundation
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif
#if canImport(UniformTypeIdentifiers)
  import UniformTypeIdentifiers
#endif
#if canImport(VaultKit)
  import VaultKit
#endif

public protocol ImportKitServicesInjecting {}

extension ImportKitServicesContainer {
  @MainActor
  public func makeCSVImportViewModel(
    importService: ImportServiceProtocol, didSave: @escaping () -> Void
  ) -> CSVImportViewModel {
    return CSVImportViewModel(
      importService: importService,
      iconService: iconService,
      personalDataURLDecoder: personalDataURLDecoder,
      activityReporter: reporter,
      userSpacesService: userSpacesService,
      didSave: didSave
    )
  }

}

extension ImportKitServicesContainer {
  @MainActor
  public func makeChromeImportFlowViewModel(initialStep: ImportFlowStep, userSettings: UserSettings)
    -> ChromeImportFlowViewModel
  {
    return ChromeImportFlowViewModel(
      initialStep: initialStep,
      userSettings: userSettings,
      importInformationViewModelFactory: InjectedFactory(makeImportInformationViewModel)
    )
  }
  @MainActor
  public func makeChromeImportFlowViewModel(userSettings: UserSettings) -> ChromeImportFlowViewModel
  {
    return ChromeImportFlowViewModel(
      userSettings: userSettings,
      importInformationViewModelFactory: InjectedFactory(makeImportInformationViewModel)
    )
  }

}

extension ImportKitServicesContainer {
  @MainActor
  internal func makeChromeImportViewModel() -> ChromeImportViewModel {
    return ChromeImportViewModel(
      activityReporter: reporter,
      userSpacesService: userSpacesService,
      personalDataURLDecoder: personalDataURLDecoder
    )
  }

}

extension ImportKitServicesContainer {
  @MainActor
  public func makeDashImportFlowViewModel(
    initialStep: ImportFlowStep?, applicationDatabase: ApplicationDatabase,
    databaseDriver: DatabaseDriver
  ) -> DashImportFlowViewModel {
    return DashImportFlowViewModel(
      initialStep: initialStep,
      applicationDatabase: applicationDatabase,
      databaseDriver: databaseDriver,
      iconService: iconService,
      activityReporter: reporter,
      activityLogsService: activityLogsService,
      dashImportViewModelFactory: InjectedFactory(makeDashImportViewModel),
      importInformationViewModelFactory: InjectedFactory(makeImportInformationViewModel)
    )
  }
  @MainActor
  public func makeDashImportFlowViewModel(
    shouldHaveInitialStep: Bool = true, applicationDatabase: ApplicationDatabase,
    databaseDriver: DatabaseDriver
  ) -> DashImportFlowViewModel {
    return DashImportFlowViewModel(
      shouldHaveInitialStep: shouldHaveInitialStep,
      applicationDatabase: applicationDatabase,
      databaseDriver: databaseDriver,
      iconService: iconService,
      activityReporter: reporter,
      activityLogsService: activityLogsService,
      dashImportViewModelFactory: InjectedFactory(makeDashImportViewModel),
      importInformationViewModelFactory: InjectedFactory(makeImportInformationViewModel)
    )
  }

}

extension ImportKitServicesContainer {
  @MainActor
  public func makeDashImportViewModel(importService: ImportServiceProtocol) -> DashImportViewModel {
    return DashImportViewModel(
      importService: importService,
      iconService: iconService,
      personalDataURLDecoder: personalDataURLDecoder,
      activityReporter: reporter,
      userSpacesService: userSpacesService
    )
  }

}

extension ImportKitServicesContainer {

  public func makeImportInformationViewModel(
    kind: ImportFlowKind, step: ImportInformationViewModel.Step
  ) -> ImportInformationViewModel {
    return ImportInformationViewModel(
      kind: kind,
      step: step,
      activityReporter: reporter
    )
  }

}

extension ImportKitServicesContainer {
  @MainActor
  public func makeKeychainImportFlowViewModel(
    initialStep: ImportFlowStep, applicationDatabase: ApplicationDatabase
  ) -> KeychainImportFlowViewModel {
    return KeychainImportFlowViewModel(
      initialStep: initialStep,
      personalDataURLDecoder: personalDataURLDecoder,
      applicationDatabase: applicationDatabase,
      iconService: iconService,
      activityReporter: reporter,
      csvImportViewModelFactory: InjectedFactory(makeCSVImportViewModel),
      importInformationViewModelFactory: InjectedFactory(makeImportInformationViewModel)
    )
  }
  @MainActor
  public func makeKeychainImportFlowViewModel(applicationDatabase: ApplicationDatabase)
    -> KeychainImportFlowViewModel
  {
    return KeychainImportFlowViewModel(
      personalDataURLDecoder: personalDataURLDecoder,
      applicationDatabase: applicationDatabase,
      iconService: iconService,
      activityReporter: reporter,
      csvImportViewModelFactory: InjectedFactory(makeCSVImportViewModel),
      importInformationViewModelFactory: InjectedFactory(makeImportInformationViewModel)
    )
  }

}

extension ImportKitServicesContainer {
  @MainActor
  public func makeLastpassImportFlowViewModel(
    initialStep: ImportFlowStep, applicationDatabase: ApplicationDatabase,
    userSettings: UserSettings
  ) -> LastpassImportFlowViewModel {
    return LastpassImportFlowViewModel(
      initialStep: initialStep,
      personalDataURLDecoder: personalDataURLDecoder,
      applicationDatabase: applicationDatabase,
      userSettings: userSettings,
      iconService: iconService,
      activityReporter: reporter,
      csvImportViewModelFactory: InjectedFactory(makeCSVImportViewModel),
      importInformationViewModelFactory: InjectedFactory(makeImportInformationViewModel)
    )
  }
  @MainActor
  public func makeLastpassImportFlowViewModel(
    applicationDatabase: ApplicationDatabase, userSettings: UserSettings
  ) -> LastpassImportFlowViewModel {
    return LastpassImportFlowViewModel(
      personalDataURLDecoder: personalDataURLDecoder,
      applicationDatabase: applicationDatabase,
      userSettings: userSettings,
      iconService: iconService,
      activityReporter: reporter,
      csvImportViewModelFactory: InjectedFactory(makeCSVImportViewModel),
      importInformationViewModelFactory: InjectedFactory(makeImportInformationViewModel)
    )
  }

}

public typealias _CSVImportViewModelFactory = @MainActor (
  _ importService: ImportServiceProtocol,
  _ didSave: @escaping () -> Void
) -> CSVImportViewModel

extension InjectedFactory where T == _CSVImportViewModelFactory {
  @MainActor
  public func make(importService: ImportServiceProtocol, didSave: @escaping () -> Void)
    -> CSVImportViewModel
  {
    return factory(
      importService,
      didSave
    )
  }
}

extension CSVImportViewModel {
  public typealias Factory = InjectedFactory<_CSVImportViewModelFactory>
}

public typealias _ChromeImportFlowViewModelFactory = @MainActor (
  _ initialStep: ImportFlowStep,
  _ userSettings: UserSettings
) -> ChromeImportFlowViewModel

extension InjectedFactory where T == _ChromeImportFlowViewModelFactory {
  @MainActor
  public func make(initialStep: ImportFlowStep, userSettings: UserSettings)
    -> ChromeImportFlowViewModel
  {
    return factory(
      initialStep,
      userSettings
    )
  }
}

extension ChromeImportFlowViewModel {
  public typealias Factory = InjectedFactory<_ChromeImportFlowViewModelFactory>
}

public typealias _ChromeImportFlowViewModelSecondFactory = @MainActor (
  _ userSettings: UserSettings
) -> ChromeImportFlowViewModel

extension InjectedFactory where T == _ChromeImportFlowViewModelSecondFactory {
  @MainActor
  public func make(userSettings: UserSettings) -> ChromeImportFlowViewModel {
    return factory(
      userSettings
    )
  }
}

extension ChromeImportFlowViewModel {
  public typealias SecondFactory = InjectedFactory<_ChromeImportFlowViewModelSecondFactory>
}

internal typealias _ChromeImportViewModelFactory = @MainActor (
) -> ChromeImportViewModel

extension InjectedFactory where T == _ChromeImportViewModelFactory {
  @MainActor
  func make() -> ChromeImportViewModel {
    return factory()
  }
}

extension ChromeImportViewModel {
  internal typealias Factory = InjectedFactory<_ChromeImportViewModelFactory>
}

public typealias _DashImportFlowViewModelFactory = @MainActor (
  _ initialStep: ImportFlowStep?,
  _ applicationDatabase: ApplicationDatabase,
  _ databaseDriver: DatabaseDriver
) -> DashImportFlowViewModel

extension InjectedFactory where T == _DashImportFlowViewModelFactory {
  @MainActor
  public func make(
    initialStep: ImportFlowStep?, applicationDatabase: ApplicationDatabase,
    databaseDriver: DatabaseDriver
  ) -> DashImportFlowViewModel {
    return factory(
      initialStep,
      applicationDatabase,
      databaseDriver
    )
  }
}

extension DashImportFlowViewModel {
  public typealias Factory = InjectedFactory<_DashImportFlowViewModelFactory>
}

public typealias _DashImportFlowViewModelSecondFactory = @MainActor (
  _ shouldHaveInitialStep: Bool,
  _ applicationDatabase: ApplicationDatabase,
  _ databaseDriver: DatabaseDriver
) -> DashImportFlowViewModel

extension InjectedFactory where T == _DashImportFlowViewModelSecondFactory {
  @MainActor
  public func make(
    shouldHaveInitialStep: Bool = true, applicationDatabase: ApplicationDatabase,
    databaseDriver: DatabaseDriver
  ) -> DashImportFlowViewModel {
    return factory(
      shouldHaveInitialStep,
      applicationDatabase,
      databaseDriver
    )
  }
}

extension DashImportFlowViewModel {
  public typealias SecondFactory = InjectedFactory<_DashImportFlowViewModelSecondFactory>
}

public typealias _DashImportViewModelFactory = @MainActor (
  _ importService: ImportServiceProtocol
) -> DashImportViewModel

extension InjectedFactory where T == _DashImportViewModelFactory {
  @MainActor
  public func make(importService: ImportServiceProtocol) -> DashImportViewModel {
    return factory(
      importService
    )
  }
}

extension DashImportViewModel {
  public typealias Factory = InjectedFactory<_DashImportViewModelFactory>
}

public typealias _ImportInformationViewModelFactory = (
  _ kind: ImportFlowKind,
  _ step: ImportInformationViewModel.Step
) -> ImportInformationViewModel

extension InjectedFactory where T == _ImportInformationViewModelFactory {

  public func make(kind: ImportFlowKind, step: ImportInformationViewModel.Step)
    -> ImportInformationViewModel
  {
    return factory(
      kind,
      step
    )
  }
}

extension ImportInformationViewModel {
  public typealias Factory = InjectedFactory<_ImportInformationViewModelFactory>
}

public typealias _KeychainImportFlowViewModelFactory = @MainActor (
  _ initialStep: ImportFlowStep,
  _ applicationDatabase: ApplicationDatabase
) -> KeychainImportFlowViewModel

extension InjectedFactory where T == _KeychainImportFlowViewModelFactory {
  @MainActor
  public func make(initialStep: ImportFlowStep, applicationDatabase: ApplicationDatabase)
    -> KeychainImportFlowViewModel
  {
    return factory(
      initialStep,
      applicationDatabase
    )
  }
}

extension KeychainImportFlowViewModel {
  public typealias Factory = InjectedFactory<_KeychainImportFlowViewModelFactory>
}

public typealias _KeychainImportFlowViewModelSecondFactory = @MainActor (
  _ applicationDatabase: ApplicationDatabase
) -> KeychainImportFlowViewModel

extension InjectedFactory where T == _KeychainImportFlowViewModelSecondFactory {
  @MainActor
  public func make(applicationDatabase: ApplicationDatabase) -> KeychainImportFlowViewModel {
    return factory(
      applicationDatabase
    )
  }
}

extension KeychainImportFlowViewModel {
  public typealias SecondFactory = InjectedFactory<_KeychainImportFlowViewModelSecondFactory>
}

public typealias _LastpassImportFlowViewModelFactory = @MainActor (
  _ initialStep: ImportFlowStep,
  _ applicationDatabase: ApplicationDatabase,
  _ userSettings: UserSettings
) -> LastpassImportFlowViewModel

extension InjectedFactory where T == _LastpassImportFlowViewModelFactory {
  @MainActor
  public func make(
    initialStep: ImportFlowStep, applicationDatabase: ApplicationDatabase,
    userSettings: UserSettings
  ) -> LastpassImportFlowViewModel {
    return factory(
      initialStep,
      applicationDatabase,
      userSettings
    )
  }
}

extension LastpassImportFlowViewModel {
  public typealias Factory = InjectedFactory<_LastpassImportFlowViewModelFactory>
}

public typealias _LastpassImportFlowViewModelSecondFactory = @MainActor (
  _ applicationDatabase: ApplicationDatabase,
  _ userSettings: UserSettings
) -> LastpassImportFlowViewModel

extension InjectedFactory where T == _LastpassImportFlowViewModelSecondFactory {
  @MainActor
  public func make(applicationDatabase: ApplicationDatabase, userSettings: UserSettings)
    -> LastpassImportFlowViewModel
  {
    return factory(
      applicationDatabase,
      userSettings
    )
  }
}

extension LastpassImportFlowViewModel {
  public typealias SecondFactory = InjectedFactory<_LastpassImportFlowViewModelSecondFactory>
}

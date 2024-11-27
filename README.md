# Apple apps
This repository contains the source code for all the Apple applications (Dashlane iOS, Dashlane macOS). It is publicly available for everyone to audit our code and learn more about how the Apple applications work.

## History

The iOS project was started back in 2010 and was relying on Objective-C, C++, and UIKit. Throughout the years, we transitioned to Swift to have a more modern codebase. Today, we no longer have any Objective-C code within our codebase. After Apple announced SwiftUI in 2019, we decided to rewrite the app with this technology. Today, most of our codebase uses the latest Apple technologies like SwiftUI and Swift Concurrency.

## High-level architecture

The architecture pattern used for the views is MVVM. It helps us isolate the business logic in clear layers and components.

Because we were using a UIKit-based navigation, we relied on the Coordinator pattern to push the different views in the flows. These components are fading away as we're replacing the navigation with a SwiftUI-based one, relying only on MVVM.

We rely on small services to perform non-UI operations (VaultItemService, RegionInformationService, PasswordEvaluator, ...). These services are split into two categories, the ones available when the user is not authenticated, and the others that require user information. They are respectively instantiated in `AppServicesContainer` and `SessionServicesContainer`.

These services all define protocols for their public interface, clearly defining what should and should not be public. Using protocols makes it easier to define Mocks and use them in Unit Tests and SwiftUI Previews.

### SwiftUI

We have been early adopters of the technology, using the first version of SwiftUI in production. While we still have a few screens written in UIKit, most of the codebase uses SwiftUI.

The main navigation relies on UIKit because of the lack of features in the SwiftUI navigation when we introduced it. We started replacing it in some flows (like in the Settings or the Login) with the SwiftUI Navigation. We aim to finish the migration in 2023, allowing us to fully benefit from the SwiftUI environment.

### Swift Concurrency

Swift Concurrency has been long awaited in the Swift community. All our Services relied on Combine to provide async information. Most of them have been migrated to Swift Concurrency, allowing a simpler codebase.

As of 2023 the migration still continues. We regularly update the services to use Swift Concurrency.

### Codebase organization

The codebase is a monorepo, meaning that all Apple applications are in a single repository. It brings us many advantages as we share code between our applications. At the repository's root is a folder per target/app and one for all our `Packages`.
Before using a monorepo, adding code in packages was difficult because they were in other repositories. Developers had to create multiple merge requests to add their code if it impacted different parts of the applications. It led to the `Shared` folder that contains files used by multiple targets. It was easy to add code there. As we migrate most of our features in `Packages`, the `Shared` folder will eventually disappear. We stopped adding code in this folder a few months ago, but removing it will take some time.

### Cryptography

All cryptographic operations are based on the Apple frameworks CommonCrypto and CryptoKit.

The derivation of the Master Password is performed with the Password Hashing Competition winner, [Argon2](https://github.com/P-H-C/phc-winner-argon2). The codebase contains a Swift wrapper that uses the C implementation of the algorithm.

If you want to learn more about cryptography at Dashlane, take a look at our [Security Whitepaper](https://www.dashlane.com/download/whitepaper-en.pdf).

## How to contribute

### Security issue

If you find a vulnerability or a security issue, please report it on our [Hacker One Bug Bounty program](https://hackerone.com/dashlane).

### Codebase improvement

If there is an improvement for the codebase you would like to share with us, we would be happy to hear your thoughts! Feel free to open an issue on this repository or contact us at dev-relationship@dashlane.com.

## Get our apps

|  Dashlane Apps |  Download link | 
|---|---|
| Dashlane Password Manager   |  <a href="https://apps.apple.com/app/dashlane/id517914548"><img alt="Download Dashlane Password Manager on App Store" src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg"></a>  |

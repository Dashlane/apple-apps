import Foundation
import DashlaneAppKit
import CoreFeature

struct PluginCapacities {

    struct EnabledCapacity: Encodable {
        let name: String
        let enabled: Bool
    }

    enum PluginCapacity: String, Encodable, CaseIterable {
        case hasQueryDataModelWithSpacesCapacity
        case hasGetSpacesForPopupCapacity

        static let capacities: [PluginCapacity: Bool] = [
            .hasQueryDataModelWithSpacesCapacity: true,
            .hasGetSpacesForPopupCapacity: true
        ]
    }

    struct Capacities: Encodable {
                let list: [String: Bool]
                let pluginCapacitiesList: [String: Bool]

        enum CodingKeys: String, CodingKey {
            case list
            case pluginCapacitiesList
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(list.jsonRepresentation, forKey: .list)
            try container.encode(pluginCapacitiesList.jsonRepresentation, forKey: .pluginCapacitiesList)
        }
    }

    let featureService: FeatureServiceProtocol

    func makeResponse() -> SessionStateRequest.Response {

        let enabledPluginCapacity = PluginCapacity.capacities.reduce(into: [String: Bool]()) { (result, capacity) in
            result[capacity.key.rawValue] = capacity.value
        }

                        let forcedEnabledFeatures = ["autofill-saex-shush-dashlane-webcard", "autofill-saex-save-after-generation", "autofill_web_shush"]
        
        let enabledThroughService = featureService.enabledFeatures().map({ $0.rawValue })
        let featureFlipsInformation = (enabledThroughService + forcedEnabledFeatures)
            .reduce(into: [String: Bool]()) { result, feature in
                result[feature] = true
            }

        let capacities = Capacities(list: featureFlipsInformation,
                                    pluginCapacitiesList: enabledPluginCapacity)

        return SessionStateRequest.Response(action: .accountFeaturesChanged,
                                            content: capacities.jsonRepresentation)
    }
}

import UIKit

class SidebarItem: Hashable {

    enum ItemType: Int {
        case header, row
    }

    let id: UUID
    let type: ItemType
    let title: String
    var detail: TabElementDetail?
    let image: UIImage?
    let selectedImage: UIImage?
    var tabCoordinator: TabCoordinator?

    private init(id: UUID, type: SidebarItem.ItemType, title: String, detail: TabElementDetail? = nil, image: UIImage?, selectedImage: UIImage?, tabCoordinator: TabCoordinator? = nil) {
        self.id = id
        self.type = type
        self.title = title
        self.detail = detail
        self.image = image
        self.selectedImage = selectedImage
        self.tabCoordinator = tabCoordinator
    }

    static func header(title: String, id: UUID) -> SidebarItem {
        return SidebarItem(id: id, type: .header, title: title, detail: nil, image: nil, selectedImage: nil)
    }

    static func row(tab: TabCoordinator) -> SidebarItem {
        return SidebarItem(id: tab.id, type: .row, title: tab.title, detail: tab.detailInformationValue?.value, image: tab.sidebarImage.image.image, selectedImage: tab.sidebarImage.selectedImage.image, tabCoordinator: tab)
    }

    static func == (lhs: SidebarItem, rhs: SidebarItem) -> Bool {
        return lhs.id == rhs.id && lhs.detail == rhs.detail
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

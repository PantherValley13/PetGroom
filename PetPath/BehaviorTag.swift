import Foundation

struct BehaviorTag: Identifiable, Hashable, Codable {
    let id: UUID
    var label: String
    var isActive: Bool

    init(id: UUID = UUID(), label: String, isActive: Bool = false) {
        self.id = id
        self.label = label
        self.isActive = isActive
    }
}

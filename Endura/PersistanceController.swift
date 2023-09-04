import CoreData
import Foundation

struct PersistenceController {
    /// A singleton for our entire app to use
    static let shared = PersistenceController()
    /// Storage for Core Data
    let container: NSPersistentContainer
    let activitiesContainer: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ObjectCache")
        activitiesContainer = NSPersistentContainer(name: "Activities")
        for container in [activitiesContainer, container] {
            if inMemory {
                container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
            }
            container.loadPersistentStores { _, error in
                if let error = error {
                    fatalError("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}

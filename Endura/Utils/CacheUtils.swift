import CoreData
import Foundation

protocol Cacheable {
    associatedtype T: NSManagedObject
    func updateCache(_ cache: T)
    static func fromCache(_ cache: T) -> Self
}

public enum CacheUtils {
    public static func updateObject<T: NSManagedObject>(_: T.Type, update: (T) -> Void) {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.fetchLimit = 1
        do {
            try update(context.fetch(fetchRequest).first ?? T(context: context))
            try context.save()
        } catch {
            print("Error updating object: \(error)")
        }
    }

    public static func fetchObject<T: NSManagedObject>(_: T.Type) -> T? {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.fetchLimit = 1
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Error fetching object: \(error)")
            return nil
        }
    }

    public static func deleteObject<T: NSManagedObject>(_: T.Type) {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.fetchLimit = 1
        do {
            if let object = try context.fetch(fetchRequest).first {
                context.delete(object)
                try context.save()
            }
        } catch {
            print("Error deleting object: \(error)")
        }
    }
}

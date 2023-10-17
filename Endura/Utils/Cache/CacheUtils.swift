import CoreData
import Foundation

protocol Cacheable {
    associatedtype T: NSManagedObject
    func updateCache(_ cache: T)
    static func fromCache(_ cache: T) -> Self
}

public enum CacheUtils {
    public static let context = PersistenceController.shared.container.viewContext

    public static func predicateMatchingField<T>(_ field: String, value: T) -> NSPredicate {
        value is Date
            ? NSPredicate(format: "\(field) == %@", value as! NSDate)
            : NSPredicate(format: "\(field) == %@", value as! CVarArg)
    }

    public static func updateObject<T: NSManagedObject>(_: T.Type, update: (T) -> Void) {
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.fetchLimit = 1
        do {
            try update(context.fetch(fetchRequest).first ?? T(context: context))
            try context.save()
        } catch {
            Global.log.error("Error updating object: \(error)")
        }
    }

    public static func fetchObject<T: NSManagedObject>(_: T.Type) -> T? {
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.fetchLimit = 1
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            Global.log.error("Error fetching object: \(error)")
            return nil
        }
    }

    public static func deleteObject<T: NSManagedObject>(_: T.Type) {
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.fetchLimit = 1
        do {
            if let object = try context.fetch(fetchRequest).first {
                context.delete(object)
                try context.save()
            }
        } catch {
            Global.log.error("Error deleting object: \(error)")
        }
    }

    public static func fetchListedObject<T: NSManagedObject>(_: T.Type, predicate: NSPredicate? = nil) -> [T] {
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.predicate = predicate
        do {
            return try context.fetch(fetchRequest)
        } catch {
            Global.log.error("Error fetching query for listed objects: \(error)")
            return []
        }
    }

    public static func updateListedObject<T: NSManagedObject>(_: T.Type, update: (T) -> Void, predicate: NSPredicate?) {
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        do {
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            try update(context.fetch(fetchRequest).first ?? T(context: context))
            try context.save()
        } catch {
            Global.log.error("Error updating listed object: \(error)")
        }
    }

    public static func deleteListedObject<T: NSManagedObject>(_: T.Type, predicate: NSPredicate?) {
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        do {
            if let object = try context.fetch(fetchRequest).first {
                context.delete(object)
                try context.save()
            }
        } catch {
            Global.log.error("Error deleting listed object: \(error)")
        }
    }

    public static func addListedObject<T: NSManagedObject>(_ object: T) {
        context.perform {
            context.insert(object)
            do {
                try context.save()
            } catch {
                Global.log.error("Error saving listed object: \(error)")
            }
        }
    }
}

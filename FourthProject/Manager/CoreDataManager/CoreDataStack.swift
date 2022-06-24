//
//  CoreDataStack.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 1.03.22.
//

import Foundation
import UIKit
import CoreData

class CoreDataStack: NSObject {

	static let sharedInstance = CoreDataStack()
	private override init() {}

	// MARK: - Core Data stack
	lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "FourthProject")
		container.loadPersistentStores(completionHandler: { (_, error) in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		return container
	}()

	// MARK: - Core Data Saving support
	func saveContext () {
		let context = persistentContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}

	func saveATMInCoreDataWith(atms: ATMResponse, context: NSManagedObjectContext) {
		let encoder = JSONEncoder()
		do {
			let new = ATMData(context: context)
			let data = try encoder.encode(atms)
			new.atmData = data
			CoreDataStack.sharedInstance.saveContext()
			print("saved")
		} catch {
			print(error)
		}
	}

	func saveBranchInCoreDataWith(branches: Branch, context: NSManagedObjectContext) {
		let encoder = JSONEncoder()
		do {
			let new = BranchData(context: context)
			let data = try encoder.encode(branches)
			new.branchData = data
			CoreDataStack.sharedInstance.saveContext()
			print("saved")
		} catch {
			print(error)
		}
	}

	func saveInfoBoxInCoreDataWith(infoboxes: [InfoBoxElement], context: NSManagedObjectContext) {
		let encoder = JSONEncoder()
		do {
			let new = InfoboxData(context: context)
			let data = try encoder.encode(infoboxes)
			new.infoboxData = data
			CoreDataStack.sharedInstance.saveContext()
			print("saved")
		} catch {
			print(error)
		}
	}

	func clearData(type: Any, context: NSManagedObjectContext) {
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: type))
		do {
			let objects  = try context.fetch(fetchRequest) as? [NSManagedObject]
			_ = objects.map { $0.map { context.delete($0) } }
			CoreDataStack.sharedInstance.saveContext()
		} catch let error {
			print("ERROR DELETING : \(error)")
		}
	}
}

extension CoreDataStack {
    func applicationDocumentsDirectory() {
        if let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last {
            print(url.absoluteString)
        }
    }
}

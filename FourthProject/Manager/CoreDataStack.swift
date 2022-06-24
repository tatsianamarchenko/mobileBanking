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
}

extension CoreDataStack {
    func applicationDocumentsDirectory() {
        if let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last {
            print(url.absoluteString)
        }
    }
}

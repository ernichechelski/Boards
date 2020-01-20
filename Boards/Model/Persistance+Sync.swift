//
//  Persistance+Sync.swift
//  Boards
//
//  Created by Ernest Chechelski on 20/01/2020.
//  Copyright © 2020 Ernest Chechelski. All rights reserved.
//

import Foundation

final class PersistanceManager {

    static let sharedInstance = PersistanceManager()

    let database = fetch()

    private init() {
        UpdateEvent.observe(self, selector: #selector(update))
    }

    private static func fetch() -> Database {
        Database.from(jsonString: UserDefaults.standard.string(forKey: "Database"))   ?? Database()
    }

    func save() {
        UserDefaults.standard.set(database.asJSON, forKey: "Database")
    }

    @objc func update(notification: Notification) {
        if let _ = notification.object as? UpdateEvent { save() }
    }
}


enum UpdateEvent {

    static let name = Notification.Name("UpdateEvent")

    case reload
    case project(rootProject: Project? = nil)
    case board(rootProject: Project? = nil, board: Board? = nil)
    case item(rootProject: Project? = nil, board: Board? = nil, item: Board.Item? = nil)

    func post() {
        PersistanceManager.sharedInstance.save()
        NotificationCenter.default.post(Notification(name: UpdateEvent.name, object: self))
    }

    static func observe(_ observer: Any, selector: Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: nil)
    }
}

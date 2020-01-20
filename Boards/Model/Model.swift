//
//  Model.swift
//  Boards
//
//  Created by Ernest Chechelski on 20/01/2020.
//  Copyright © 2020 Ernest Chechelski. All rights reserved.
//

import Foundation
import UIKit

class Database: Codable {
    var projects: [Project] = []
    init(projects: [Project]) {
        self.projects = projects
    }

    init() {}
}

final class Project: Codable {

    var name: String

    var boards: [Board]

    var id = UUID().uuidString

    init(name: String, boards: [Board]) {
        self.name = name
        self.boards = boards
    }

    init(board: Board?) {
        name = "New Project"
        if let board = board {
            boards = [board]
        } else {
            boards = []
        }

    }

    init(item: Board.Item?) {
        name = "New Project"
        boards = [Board(item: item)]
    }

    init() {
        name = "New Project"
        boards = []
    }
}

final class Board: Codable {

    class Item: Codable {
        var value: String

        let id = UUID().uuidString

        init(value: String) {
            self.value = value
        }
    }

    var name: String

    var items: [Item]

    let id = UUID().uuidString

    init(name: String, items: [Item]) {
        self.name = id
        self.items = items
    }

    init(item: Item?) {
        name = "New board"
        if let item = item {
            items = [item]
        } else {
            items = []
        }
    }
}

extension Encodable {
    var asJSON: String? {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    var asData: Data? {
        asJSON?.data(using: .utf8)
    }
}

extension Decodable {

    static func from(jsonString: String?) -> Self? {
        guard let json = jsonString else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(Self.self, from: json.data(using: .utf8)!)
    }

    static func from(data: Data?) -> Self? {
        guard let data = data else { return nil }
        if let string = String(data: data, encoding: .utf8) {
            return Self.from(jsonString: string)
        } else {
            return nil
        }
    }


}

protocol ModelDraggable {
    static var activityType: String { get }
    static var taskType: String { get }
    var dragItem: UIDragItem { get }
    var stateRestoration: NSUserActivity { get }
    static func create(from: NSUserActivity) -> Self?
}

extension ModelDraggable {
    static var activityType: String { "com.ernichechelski.boards" }
}

extension ModelDraggable where Self: Codable {

    var dragItem: UIDragItem {
        let itemProvider = NSItemProvider()
        let dragItem = UIDragItem(itemProvider: itemProvider)
        let userActivity = stateRestoration
        itemProvider.registerObject(userActivity, visibility: .all)
        return dragItem
    }

    var stateRestoration: NSUserActivity {
        let userActivity = NSUserActivity(activityType: Self.activityType)
        userActivity.title = Self.taskType
        userActivity.userInfo = ["Coded": self.asJSON!]
        return userActivity
    }

    func put(into existingStateRestoration: NSUserActivity?) {
        existingStateRestoration?.userInfo = ["Coded": self.asJSON!]
    }

    static func create(from stateRestoration: NSUserActivity) -> Self? {
        if let json = stateRestoration.userInfo?["Coded"] as? String {
            return Self.from(jsonString: json)
        }
        return nil
    }
}

extension Project: ModelDraggable {
    static var taskType: String { "Project" }
}

extension Board: ModelDraggable {
    static var taskType: String { "Board" }
}

extension Board.Item: ModelDraggable {
    static var taskType: String { "Item" }
}

extension NSUserActivity {
    static var restoration: NSUserActivity { .init(activityType: "Restoration") }
}

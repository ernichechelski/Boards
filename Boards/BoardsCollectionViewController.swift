//
//  BoardsCollectionViewController.swift
//  Boards
//
//  Created by Ernest Chechelski on 15/01/2020.
//  Copyright © 2020 Ernest Chechelski. All rights reserved.
//

import UIKit

class Project: Codable {
    var boards: [Board]

    init(boards: [Board]) {
        self.boards = boards
    }
}

class Board: Codable {
    struct Item: Codable {
        var value: String
    }
    var id: String
    var items: [Item]

    init(id: String, items: [Item]) {
        self.id = id
        self.items = items
    }
}

extension Encodable {
    var asJSON: String? {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

extension Decodable {
    static func from(jsonString: String) -> Self? {
        let decoder = JSONDecoder()
        return try? decoder.decode(Self.self, from: jsonString.data(using: .utf8)!)
    }
}


class BoardsCollectionViewController: UICollectionViewController {

    var database = Project(boards: [
        Board(id: "Cats", items: [
            Board.Item(value: "Meowing")
        ]),
        Board(id: "XDS", items: [
            Board.Item(value: "XDDD"),
            Board.Item(value: "XDDD2")
        ]),
        Board(id: "Brzydkie", items: [
            Board.Item(value: "Dupa"),
            Board.Item(value: "Gunwo"),
            Board.Item(value: "kdfajskdfjlkasdjflkas djfkl;asdjf ;lkasdjflj fldsj f;lkdsjflkjasldk fjads;kjfas;lkdfj")
        ]),
        Board(id: "Śmieszki", items: [
            Board.Item(value: "Cheche"),
            Board.Item(value: "hehue"),
            Board.Item(value: "hehe"),
            Board.Item(value: "haha")
        ])
    ])

    private let reuseIdentifier = "Cell"

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
//        collectionView.reorderingCadence = .fast
//        collectionView.addInteraction(UIDropInteraction(delegate: self))
        updateCollectionViewItem(with: view.bounds.size)
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

//    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
//        true
//    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        database.boards.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BoardCollectionViewCell
        cell.board = database.boards[indexPath.row]
        cell.setup()
        return cell
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateCollectionViewItem(with: size)
    }

    private func updateCollectionViewItem(with size: CGSize) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        layout.itemSize = CGSize(width: 225, height: size.height * 0.8)
    }

}

extension BoardsCollectionViewController: UICollectionViewDelegateFlowLayout { }

extension BoardsCollectionViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let itemProvider = NSItemProvider()
        let dragItem = UIDragItem(itemProvider: itemProvider)
        let selectedItem = database.boards[indexPath.row]
        let userActivity = NSUserActivity(activityType: "com.ernichechelski.boards")
        userActivity.title = "NewProjectWithBoard"
        userActivity.userInfo = ["Board": selectedItem.asJSON!]
        itemProvider.registerObject(userActivity, visibility: .all)
        session.localContext = (selectedItem,database,collectionView,indexPath)
        return [dragItem]
    }
}

extension BoardsCollectionViewController: UICollectionViewDropDelegate {

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
           UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
       }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let context = coordinator.session.localDragSession?.localContext as? (Board, Project, UICollectionView, IndexPath) else {
            return
        }

        let indexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        context.1.boards.remove(at: context.3.row)
        context.2.deleteItems(at: [context.3])

        
        database.boards.insert(context.0, at: indexPath.row)
        collectionView.insertItems(at: [indexPath])
        collectionView.reloadItems(at: [indexPath])
    }
}

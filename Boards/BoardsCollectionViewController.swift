//
//  BoardsCollectionViewController.swift
//  Boards
//
//  Created by Ernest Chechelski on 15/01/2020.
//  Copyright © 2020 Ernest Chechelski. All rights reserved.
//

import UIKit

class Project: Codable {
    var name: String
    var boards: [Board]

    init(name: String, boards: [Board]) {
        self.name = name
        self.boards = boards
    }
}

class Board: Codable {
    class Item: Codable {
        var value: String
        init(value: String) {
            self.value = value
        }
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


class BoardsCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var projectNameTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!


    var database = Project(name: "Procastination", boards: [
        Board(id: "TODO", items: [
            Board.Item(value: "Do something productive ☹️")
        ]),
        Board(id: "In progress", items: [
            Board.Item(value: "Dring beer 🍺"),
            Board.Item(value: "Eat something tasty 🍔")
        ]),
        Board(id: "Done", items: [
            Board.Item(value: "Buy beer 🍻"),
            Board.Item(value: "Buy something to eat 😋"),
            Board.Item(value: "Go to sleep 😴")
        ]),
        Board(id: "Rejected", items: [
            Board.Item(value: "Do some research about vege diet 👨🏼‍🔬🌿"),
            Board.Item(value: "Go for a walk 🚶‍♀️"),
            Board.Item(value: "Create some meme 🖼")
        ])
    ])

    private let reuseIdentifier = "Cell"

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
//        collectionView.reorderingCadence = .fast
//        collectionView.addInteraction(UIDropInteraction(delegate: self))
        updateCollectionViewItem(with: view.bounds.size)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        projectNameTextField.text = database.name
    }


    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

//    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
//        true
//    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        database.boards.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
        layout.itemSize = CGSize(width: 225, height: size.height * 0.7)
    }

}

extension BoardsCollectionViewController: UICollectionViewDelegateFlowLayout { }

extension BoardsCollectionViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let itemProvider = NSItemProvider()
        let dragItem = UIDragItem(itemProvider: itemProvider)
        let currentCell = collectionView.cellForItem(at: indexPath) as! BoardCollectionViewCell
        let selectedItem = currentCell.board
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

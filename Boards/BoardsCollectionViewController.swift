//
//  BoardsCollectionViewController.swift
//  Boards
//
//  Created by Ernest Chechelski on 15/01/2020.
//  Copyright © 2020 Ernest Chechelski. All rights reserved.
//

import UIKit

class Database {
    var boards: [Board]

    init(boards: [Board]) {
        self.boards = boards
    }
}

class Board {
    struct Item {
        var value: String
    }
    var id: String
    var items: [Item]

    init(id: String, items: [Item]) {
        self.id = id
        self.items = items
    }
}


class BoardsCollectionViewController: UICollectionViewController {

    var database = Database(boards: [
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
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return database.boards.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BoardCollectionViewCell
        cell.board = database.boards[indexPath.row]
        cell.setup()

        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension BoardsCollectionViewController: UICollectionViewDelegateFlowLayout {}


extension BoardsCollectionViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let itemProvider = NSItemProvider()
        let dragItem = UIDragItem(itemProvider: itemProvider)
        session.localContext = (database.boards[indexPath.row],database,collectionView,indexPath)
        return [dragItem]
    }
}

extension BoardsCollectionViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard var context = coordinator.session.localDragSession?.localContext as? (Board, Database, UICollectionView, IndexPath) else {
            return
        }

        let indexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        context.1.boards.remove(at: context.3.row)
        context.2.deleteItems(at: [context.3])

        database.boards.insert(context.0, at: indexPath.row)
        collectionView.insertItems(at: [indexPath])
    }
}

//
//  BoardCollectionViewCell.swift
//  Boards
//
//  Created by Ernest Chechelski on 15/01/2020.
//  Copyright © 2020 Ernest Chechelski. All rights reserved.
//

import UIKit

class BoardCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameTextField: UITextField!
    var board: Board?
}

extension BoardCollectionViewCell {

    override func prepareForReuse() {
        super.prepareForReuse()
        setup()
    }

    func setup() {
        layer.masksToBounds = true
        layer.cornerRadius = 10.0
        tableView.dataSource = self
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.dragInteractionEnabled = true
        tableView.tableFooterView = UIView()
        nameTextField.text = board?.id
    }
}

extension BoardCollectionViewCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        board?.items.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = board?.items[indexPath.row]
        cell.textLabel?.text = item?.value
        return cell
    }
}

extension BoardCollectionViewCell: UITableViewDragDelegate {
     func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {

        guard let selectedItem = board?.items[indexPath.row] else {
            return []
        }

        let currentBoard = board

        let userActivity = NSUserActivity(activityType: "com.ernichechelski.boards")
        userActivity.title = "NewProjectWithTask"
        userActivity.userInfo = ["Task": selectedItem.value]

        let itemProvider = NSItemProvider()
        itemProvider.registerObject(userActivity, visibility: .all)

        let dragItem = UIDragItem(itemProvider: itemProvider)
        session.localContext = (selectedItem,currentBoard,tableView,indexPath)
        return [dragItem]
    }
}

extension BoardCollectionViewCell:UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        guard let context = coordinator.session.localDragSession?.localContext as? (Board.Item, Board, UITableView, IndexPath) else {
            
            return
        }

        if context.2.isEqual(tableView) {
            tableView.beginUpdates()
            if let item = board?.items[context.3.row] {
                let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
                           tableView.moveRow(at: context.3, to: destinationIndexPath)
                board?.items.remove(at: context.3.row)
                board?.items.insert(item, at: destinationIndexPath.row)
            }
            tableView.endUpdates()

        } else {
            tableView.beginUpdates()
            if let board = board {
                let indexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
                board.items.insert(context.0, at: indexPath.row)
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
            tableView.endUpdates()

            context.2.beginUpdates()
            context.2.deleteRows(at: [context.3], with: .automatic)
            context.1.items.remove(at: context.3.row)
            context.2.endUpdates()
        }
    }

    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
}



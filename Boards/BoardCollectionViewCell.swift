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

extension BoardCollectionViewCell: UITextFieldDelegate {

    override func prepareForReuse() {
        super.prepareForReuse()
        setup(with: nil)
    }

    func setup(with board: Board?) -> Self {
        self.board = board
        layer.masksToBounds = true
        layer.cornerRadius = 10.0
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
        tableView.dataSource = self
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.dragInteractionEnabled = true
        tableView.tableFooterView = UIView()
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to add")
        tableView.refreshControl?.tintColor = .clear
        tableView.refreshControl?.addTarget(self, action: #selector(add), for: .valueChanged)
        tableView.reloadData()
        nameTextField.delegate = self
        nameTextField.text = board?.id
        return self
    }

    func textFieldDidEndEditing(_ textField: UITextField)  {
        board?.id = textField.text ?? ""
    }

    @objc func add() {
        tableView.refreshControl?.endRefreshing()

        tableView.beginUpdates()
        board?.items.insert(Board.Item(value: "New task"), at: 0)

        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()

        let cell = tableView.cellForRow(at: indexPath) as! ItemTableViewCell
        cell.textView.becomeFirstResponder()
    }
}

extension BoardCollectionViewCell: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        board?.items.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "editCell", for: indexPath) as! ItemTableViewCell
        let item = board?.items[indexPath.row]
        cell.item = item
        cell.rootTableView = tableView
        cell.setup()
        return cell
    }
}

extension BoardCollectionViewCell: UITableViewDragDelegate {
     func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let selectedItem = board?.items[indexPath.row] else { return [] }
        session.setTableViewCellContext(sourceItem: selectedItem, sourceBoard: board!, sourceTableView: tableView, sourceIndexPath: indexPath)
        return [selectedItem.dragItem]
    }


}

extension UIDragSession {
    func setTableViewCellContext(sourceItem: Board.Item, sourceBoard: Board, sourceTableView: UITableView, sourceIndexPath: IndexPath) {
        localContext = (sourceItem,sourceBoard,sourceTableView,sourceIndexPath)
    }

    func getTableViewCellContext() -> (sourceItem: Board.Item, sourceBoard: Board, sourceTableView: UITableView, sourceIndexPath: IndexPath)?  {
        localContext as? (Board.Item, Board, UITableView, IndexPath)
    }
}

protocol ModelDraggable {
    static var activityType: String { get }
    static var taskNewProject: String { get }
    var dragItem: UIDragItem { get }
    static func create(from: NSUserActivity) -> Self?
}

extension Board.Item: ModelDraggable {

    static let activityType = "com.ernichechelski.boards"
    static let taskNewProject = "NewProjectWithTask"

    var itemProvider: NSItemProvider {
        let userActivity = NSUserActivity(activityType: Board.Item.activityType)
        userActivity.title = Board.Item.taskNewProject
        if let json = self.asJSON {
            userActivity.userInfo = ["Task": json]
        }
        let itemProvider = NSItemProvider()
        itemProvider.registerObject(userActivity, visibility: .all)
        return itemProvider
    }

    var dragItem: UIDragItem {
        UIDragItem(itemProvider: self.itemProvider)
    }

    static func create(from activity: NSUserActivity) -> Self? {
        let json = activity.userInfo?["Task"] as! String
        return Board.Item.from(jsonString: json) as? Self
    }
}

extension BoardCollectionViewCell:UITableViewDropDelegate {

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        guard let context = coordinator.session.localDragSession?.getTableViewCellContext() else { return }

        let sourceTableView = context.sourceTableView
        let sourceIndexPath = context.sourceIndexPath
        let sourceBoard = context.sourceBoard
        let sourceItem = context.sourceItem

        let destinationTableView = tableView
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        let destinationBoard = board!

        destinationTableView.beginUpdates()
        sourceTableView.beginUpdates()

        switch sourceTableView.isEqual(tableView) {
        case true:
            let item = destinationBoard.items[sourceIndexPath.row]
            destinationBoard.items.remove(at: sourceIndexPath.row)
            destinationBoard.items.insert(item, at: destinationIndexPath.row)
            destinationTableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
        case false:
            destinationBoard.items.insert(sourceItem, at: destinationIndexPath.row)
            destinationTableView.insertRows(at: [destinationIndexPath], with: .automatic)
            sourceBoard.items.remove(at: sourceIndexPath.row)
            sourceTableView.deleteRows(at: [sourceIndexPath], with: .automatic)
        }

        destinationTableView.endUpdates()
        sourceTableView.endUpdates()
    }

    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
}



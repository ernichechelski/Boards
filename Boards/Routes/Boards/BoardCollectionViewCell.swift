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
    weak var rootProject: Project?
    weak var board: Board?
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
        tableView.delegate = self
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
        nameTextField.text = board?.name
        UpdateEvent.observe(self, selector: #selector(update))
        return self
    }

    @objc func update(notification: Notification) {
        let event = notification.object as! UpdateEvent
        switch event {
            case .reload:
                tableView.reloadData()
                nameTextField.text = board?.name
            case .project:
                nameTextField.text = board?.name
                tableView.reloadData()
            case .board: tableView.reloadData()
            case .item: tableView.reloadData()
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField)  {
        board?.name = textField.text ?? ""
        UpdateEvent.board(rootProject: rootProject, board: board).post()
    }

    @objc func add() {
        tableView.refreshControl?.endRefreshing()

        tableView.beginUpdates()
        board?.items.insert(Board.Item(value: "New task"), at: 0)
        UpdateEvent.board(rootProject: rootProject, board: board).post()

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
        cell.rootProject = rootProject
        cell.setup()
        return cell
    }
}

// Not accessible when everything is in scrollable collectionview
extension BoardCollectionViewCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        .init(actions: [
            .init(style: .destructive, title: "Delete", handler: { [weak self] (action, view, completion) in
                self?.tableView.beginUpdates()
                self?.board?.items.remove(at: indexPath.row)
                UpdateEvent.board(rootProject: self?.rootProject, board: self?.board).post()
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                self?.tableView.endUpdates()
            })
        ])
    }
}

extension BoardCollectionViewCell: UITableViewDragDelegate {
     func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let selectedItem = board?.items[indexPath.row] else { return [] }
        session.setTableViewCellContext(sourceItem: selectedItem, sourceBoard: board!, sourceTableView: tableView, sourceIndexPath: indexPath)
        return [selectedItem.dragItem]
    }
}

extension BoardCollectionViewCell: UITableViewDropDelegate {

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
            guard !destinationBoard.id.elementsEqual(sourceBoard.id) else { break }
            destinationBoard.items.insert(sourceItem, at: destinationIndexPath.row)
            destinationTableView.insertRows(at: [destinationIndexPath], with: .automatic)
            sourceBoard.items.remove(at: sourceIndexPath.row)
            sourceTableView.deleteRows(at: [sourceIndexPath], with: .automatic)
        }

        destinationTableView.endUpdates()
        sourceTableView.endUpdates()
        UpdateEvent.board(rootProject: rootProject).post()
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        .init(operation: .move, intent: .insertAtDestinationIndexPath)
    }
}



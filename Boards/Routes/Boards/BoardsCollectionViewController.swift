//
//  BoardsCollectionViewController.swift
//  Boards
//
//  Created by Ernest Chechelski on 15/01/2020.
//  Copyright © 2020 Ernest Chechelski. All rights reserved.
//

import UIKit

final class BoardsCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var projectNameTextField: UITextField!

    @IBOutlet weak var collectionView: UICollectionView!

    var database: PersistanceManager { PersistanceManager.sharedInstance }

    var project: Project!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        projectNameTextField.delegate = self
        updateCollectionViewItem(with: view.bounds.size)
        UpdateEvent.observe(self, selector: #selector(update))
    }

    @objc func update(notification: Notification) {
        let event = notification.object as! UpdateEvent
        switch event {
        case .reload: collectionView.reloadData()
        case .project: collectionView.reloadData()
        case .board: break
        case .item: break
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        projectNameTextField.text = project.name
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUserActivityState(.restoration)
    }
    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        project.boards.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == project.boards.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addCell", for: indexPath) as! NewBoardCollectionViewCell
            cell.rootCollectionView = collectionView
            cell.rootProject = project
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! BoardCollectionViewCell
        cell.rootProject = project
        return cell.setup(with: project.boards[indexPath.row])
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateCollectionViewItem(with: size)
    }

    private func updateCollectionViewItem(with size: CGSize) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        collectionView.layoutIfNeeded()
        layout.itemSize = CGSize(width: 225, height: size.height * 0.7)
    }

}

extension BoardsCollectionViewController: UICollectionViewDelegateFlowLayout { }

extension BoardsCollectionViewController: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let currentCell = collectionView.cellForItem(at: indexPath) as! BoardCollectionViewCell
        let selectedItem = currentCell.board!
        session.localContext = (selectedItem,project,collectionView,indexPath)
        return [selectedItem.dragItem]
    }
}

extension BoardsCollectionViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        project.name = textField.text!
        UpdateEvent.project(rootProject: project).post()
    }
}

extension BoardsCollectionViewController: UICollectionViewDropDelegate {

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
           UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
       }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let source = coordinator.session.localDragSession?.getCollectionViewCellContext() else { return }

        let sourceCollectionView = source.sourceCollectionView
        let sourceProject = source.sourceProject
        let sourceIndexPath = source.sourceIndexPath
        let sourceBoard = source.sourceBoard

        let destinationCollectionView = collectionView
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        let destinationProject = project!

        guard !sourceProject.id.elementsEqual(destinationProject.id) else { return }
        guard destinationIndexPath.row != destinationProject.boards.count + 1 else { return }

        sourceProject.boards.remove(at: sourceIndexPath.row)
        sourceCollectionView.deleteItems(at: [sourceIndexPath])

        destinationProject.boards.insert(sourceBoard, at: destinationIndexPath.row)
        destinationCollectionView.insertItems(at: [destinationIndexPath])
        destinationCollectionView.reloadItems(at: [destinationIndexPath])
    }

    override func restoreUserActivityState(_ activity: NSUserActivity) {
        super.restoreUserActivityState(activity)
        project = Project.create(from: activity)
    }

    override func updateUserActivityState(_ activity: NSUserActivity) {
        super.updateUserActivityState(activity)
        project.put(into: activity)
        project.put(into: view.window?.windowScene?.userActivity)
    }
}

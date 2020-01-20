//
//  NewBoardCollectionViewCell.swift
//  Boards
//
//  Created by Ernest Chechelski on 20/01/2020.
//  Copyright © 2020 Ernest Chechelski. All rights reserved.
//

import UIKit

class NewBoardCollectionViewCell: UICollectionViewCell {

    weak var rootProject: Project?
    weak var rootCollectionView: UICollectionView?

    @IBAction func newBoardButtonTapped(_ sender: Any) {
        guard let rootProject = rootProject else { return }
        let board = Board(item: Board.Item(value: "New item"))
        rootProject.boards.append(board)

        UpdateEvent.project(project: rootProject).post()

        self.rootCollectionView?.reloadData()
        let indexPath = IndexPath(row: (self.rootCollectionView?.dataSource?.collectionView(self.rootCollectionView!, numberOfItemsInSection: 0))! - 1, section: 0)
        self.rootCollectionView?.insertItems(at: [indexPath])
    }
}

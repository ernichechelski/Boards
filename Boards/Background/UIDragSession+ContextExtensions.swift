//
//  UIDragSession+ContextExtensions.swift
//  Boards
//
//  Created by Ernest Chechelski on 20/01/2020.
//  Copyright © 2020 Ernest Chechelski. All rights reserved.
//

import UIKit

extension UIDragSession {
    
    func setTableViewCellContext(sourceItem: Board.Item, sourceBoard: Board, sourceTableView: UITableView, sourceIndexPath: IndexPath) {
        localContext = (sourceItem,sourceBoard,sourceTableView,sourceIndexPath)
    }

    func getTableViewCellContext() -> (sourceItem: Board.Item, sourceBoard: Board, sourceTableView: UITableView, sourceIndexPath: IndexPath)?  {
        localContext as? (Board.Item, Board, UITableView, IndexPath)
    }

    func setCollectionViewCellContext(sourceBoard: Board, sourceProject: Project, sourceCollectionView: UICollectionView, sourceIndexPath: IndexPath) {
        localContext = (sourceBoard, sourceProject, sourceCollectionView, sourceIndexPath)
    }

    func getCollectionViewCellContext() -> (sourceBoard: Board, sourceProject: Project, sourceCollectionView: UICollectionView, sourceIndexPath: IndexPath)?  {
        localContext as? (Board, Project, UICollectionView, IndexPath)
    }
}

//
//  RemoveButton.swift
//  Boards
//
//  Created by Ernest Chechelski on 17/01/2020.
//  Copyright © 2020 Ernest Chechelski. All rights reserved.
//

import UIKit

final class RemoveButton: UIButton, UIDropInteractionDelegate {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        let dropInteraction = UIDropInteraction(delegate: self)
        addInteraction(dropInteraction)
    }

    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        if let context = session.localDragSession?.getTableViewCellContext() {
            let sourceTableView = context.sourceTableView
            let sourceIndexPath = context.sourceIndexPath
            let sourceBoard = context.sourceBoard

            sourceTableView.beginUpdates()
            sourceBoard.items.remove(at: sourceIndexPath.row)
            UpdateEvent.board(board: sourceBoard).post()
            sourceTableView.deleteRows(at: [sourceIndexPath], with: .automatic)
            sourceTableView.endUpdates()
        }

        if let context = session.localDragSession?.localContext as? (Board, Project, UICollectionView, IndexPath) {
            guard context.3.row != context.1.boards.count else { return }
            context.1.boards.remove(at: context.3.row)
            UpdateEvent.project(rootProject: context.1).post()
            context.2.deleteItems(at: [context.3])
        }
    }

    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        if let _ = session.localDragSession?.getTableViewCellContext() {
            return true
        }

        if let _ = session.localDragSession?.localContext as? (Board, Project, UICollectionView, IndexPath) {
            return true
        }
        return false
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        .init(operation: .move)
    }

}

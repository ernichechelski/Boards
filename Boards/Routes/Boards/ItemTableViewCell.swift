//
//  ItemTableViewCell.swift
//  Boards
//
//  Created by Ernest Chechelski on 16/01/2020.
//  Copyright © 2020 Ernest Chechelski. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell, UITextViewDelegate {

    weak var rootTableView: UITableView?

    weak var rootProject: Project?

    weak var rootBoard: Board?

    var item: Board.Item?

    @IBOutlet weak var textView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        textView.delegate = self
    }

    func setup() {
        textView.text = item?.value
        UpdateEvent.observe(self, selector: #selector(update))
    }

   @objc func update(notification: Notification) {
       let event = notification.object as! UpdateEvent
       switch event {
           case .reload: break
           case .project: break
           case .board: break
           case .item: textView.text = item?.value
       }
   }

    func textViewDidEndEditing(_ textView: UITextView) {
        item?.value = textView.text
        UpdateEvent.item(rootProject: rootProject, rootBoard: rootBoard, item: item).post()
    }

    func textViewDidChange(_ textView: UITextView) {
        rootTableView?.beginUpdates()
        rootTableView?.endUpdates()
    }
}

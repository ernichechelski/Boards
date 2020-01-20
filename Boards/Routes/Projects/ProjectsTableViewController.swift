//
//  ProjectsTableViewController.swift
//  Boards
//
//  Created by Ernest Chechelski on 20/01/2020.
//  Copyright © 2020 Ernest Chechelski. All rights reserved.
//

import UIKit

class ProjectsTableViewController: UITableViewController {

    let database = PersistanceManager.sharedInstance.database

    func setup() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.tableFooterView = .init()
        tableView.refreshControl = .init()
        tableView.refreshControl?.attributedTitle = .init(string: "Pull to add")
        tableView.refreshControl?.tintColor = .clear
        tableView.refreshControl?.addTarget(self, action: #selector(add), for: .valueChanged)
        tableView.reloadData()
        UpdateEvent.observe(self, selector: #selector(update))
    }

    @objc func update(notification: Notification) {
        let event = notification.object as! UpdateEvent
        switch event {
        case .reload: tableView.reloadData()
        case .board: break
        case .project: break
        case .item: break
        }
    }

    @objc func add() {
        tableView.refreshControl?.endRefreshing()
        createNewProject()
    }

    func createNewProject() {
        tableView.beginUpdates()
        database.projects.insert(Project(name: "New project", boards: []), at: 0)
        UpdateEvent.reload.post()
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int { 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { database.projects.count }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let project = database.projects[indexPath.row]
        cell.textLabel?.text = project.name
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }


    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        .init(actions: [
            .init(style: .normal, title: "In new window", handler: { [weak self] (action, view, completion) in
                guard let project = self?.database.projects[indexPath.row] else { return }
                UIApplication.shared.requestSceneSessionActivation(nil, userActivity: project.stateRestoration, options: nil, errorHandler: nil)
            })
        ])
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let project = database.projects[indexPath.row]
        let boards = RoutesFactory.boards
        boards.project = project
        navigationController?.present(boards, animated: true)
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        .init(actions: [
            .init(style: .destructive, title: "Delete", handler: { [weak self] (action, view, completion) in
                self?.tableView.beginUpdates()
                self?.database.projects.remove(at: indexPath.row)
                UpdateEvent.reload.post()
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                self?.tableView.endUpdates()
            })
        ])
    }
}

extension ProjectsTableViewController: UITableViewDragDelegate {

     func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let selectedItem = database.projects[indexPath.row]
        return [selectedItem.dragItem]
    }
}

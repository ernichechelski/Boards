//
//  SceneDelegate.swift
//  Boards
//
//  Created by Ernest Chechelski on 15/01/2020.
//  Copyright © 2020 Ernest Chechelski. All rights reserved.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        window = UIWindow(windowScene: scene as! UIWindowScene)

        if let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
            switch userActivity.title {
            case Board.taskType:
                let boards = RoutesFactory.boards
                let newProject = Project(board: .create(from: userActivity))
                PersistanceManager.sharedInstance.database.projects.append(newProject)
                UpdateEvent.reload.post()
                boards.project = newProject
                window?.rootViewController = boards
            case Board.Item.taskType:
                let boards = RoutesFactory.boards
                let newProject = Project(item: .create(from: userActivity))
                PersistanceManager.sharedInstance.database.projects.append(newProject)
                UpdateEvent.reload.post()
                boards.project = newProject
                window?.rootViewController = boards
            case Project.taskType:
                let boards = RoutesFactory.boards
                var newProject = Project.create(from: userActivity) ?? Project()

                let duplicate = PersistanceManager.sharedInstance.database.projects.first {
                    $0.id.elementsEqual(newProject.id)
                }
                if duplicate == nil {
                    PersistanceManager.sharedInstance.database.projects.append(newProject)
                } else {
                    newProject = duplicate ?? newProject
                }
                UpdateEvent.reload.post()
                boards.project = newProject
                window?.rootViewController = boards
            default:
                window?.rootViewController = RoutesFactory.projectsRoot
                break
            }
        } else {
             window?.rootViewController = RoutesFactory.projectsRoot
        }
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) { }

    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? { .restoration }
}

extension UIWindow {

    var visibleViewController: UIViewController? {
        (rootViewController as? UINavigationController)?.visibleViewController ?? rootViewController
    }

    var boards: BoardsCollectionViewController? {
        visibleViewController as? BoardsCollectionViewController
    }
}




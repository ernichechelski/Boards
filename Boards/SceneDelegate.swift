//
//  SceneDelegate.swift
//  Boards
//
//  Created by Ernest Chechelski on 15/01/2020.
//  Copyright © 2020 Ernest Chechelski. All rights reserved.
//

import UIKit

enum RoutesFactory {
    enum Storyboards {
        static let main = UIStoryboard(name: "Main", bundle: nil)
    }

    static var boards: BoardsCollectionViewController {
        Storyboards.main.instantiateViewController(withIdentifier: "boards") as! BoardsCollectionViewController
    }
}



class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        window = UIWindow(windowScene: scene as! UIWindowScene)

        let boards = RoutesFactory.boards
        if let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
            switch userActivity.title {
            case Board.activityType:
                boards.database = Project(board: .create(from: userActivity))
            case Board.Item.activityType:
                boards.database = Project(item: .create(from: userActivity))
            default:
                break
            }
        }
        window?.rootViewController = boards
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}


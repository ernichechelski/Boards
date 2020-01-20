//
//  RoutesFactory.swift
//  Boards
//
//  Created by Ernest Chechelski on 20/01/2020.
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

    static var projectsRoot: UINavigationController {
        Storyboards.main.instantiateViewController(withIdentifier: "projects") as! UINavigationController
    }
}

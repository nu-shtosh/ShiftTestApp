//
//  SceneDelegate.swift
//  ShiftTestApp
//
//  Created by Илья Дубенский on 24.02.2023.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.makeKeyAndVisible()
        window?.rootViewController = makeRootViewController()
    }
}

extension SceneDelegate {
    private func makeRootViewController() -> UIViewController {
        let notesVC = NotesViewController()
        let notesNavBarVC = UINavigationController(rootViewController: notesVC)
        return notesNavBarVC
    }
}

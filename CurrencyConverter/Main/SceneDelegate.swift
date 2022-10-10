//
//  SceneDelegate.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/8/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
 
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
    
        let walletService = WalletService()
        let client = ConversionHTTPClient()
        let conversionService = ConversionService(client: client)
        let walletViewModel = WalletViewModel(walletService: walletService, conversionService: conversionService)
        
        let walletViewController = WalletViewController(viewModel: walletViewModel)
        let navigation = UINavigationController(rootViewController: walletViewController)
        navigation.navigationBar.tintColor = UIColor.appOrange

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigation
        self.window = window
        window.makeKeyAndVisible()
    }
} 
      

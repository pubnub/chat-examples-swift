//
//  AppDelegate.swift
//  AnimalForestChat
//
//  Created by Craig Lane on 3/12/19.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  // tag::INIT-0[]
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // tag::ignore[]
    // Set the Bar Button Text Color
    UINavigationBar.appearance().tintColor = #colorLiteral(red: 0.8117647059, green: 0.1294117647, blue: 0.1607843137, alpha: 1)
    UINavigationBar.appearance().backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    // end::ignore[]

    // Assign default values for initial view controller
    if let navController = self.window?.rootViewController as? UINavigationController,
       let chatVC = navController.viewControllers.first as? ChatViewController {

      // Typically there would be user authentication flows prior to displaying
      // the default chat room view, but this app currently uses default values for
      // all users and rooms.
      let service = ChatRoomService()

      chatVC.viewModel = ChatViewModel(with: service)
    }

    return true
  }
  // end::INIT-0[]

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state.
    // This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message)
    // or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks.
    // Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers,
    // and store enough application state information to restore your application
    // to its current state in case it is terminated later.
    // If your application supports background execution,
    // this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state;
    // here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive.
    // If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate.
    // Save data if appropriate. See also applicationDidEnterBackground:.
  }
}

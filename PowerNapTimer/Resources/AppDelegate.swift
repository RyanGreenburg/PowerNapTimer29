//
//  AppDelegate.swift
//  PowerNapTimer
//
//  Created by RYAN GREENBURG on 9/24/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
import UserNotifications

protocol InvalidateTimerDelegate {
    
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
            if !granted {
                print("Notification disabled")
            }
        }
        return true
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {

  // This function will be called when the app receive notification
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      
    // show the notification alert (banner), and with sound
    completionHandler([.alert, .sound])
  }
    
  // This function will be called right after user tap on the notification
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
      let application = UIApplication.shared
      
      if(application.applicationState == .active){
        print("user tapped the notification bar when the app is in foreground")
        
      }
      
      if(application.applicationState == .inactive)
      {
        // Invalidate Our timer and do some otehr ttjiodsapfidnosk;a. mdsx
        print("user tapped the notification bar when the app is in background: This is where we would now want to cancel the timer")
      }
    // tell the app that we have finished processing the user's action / response
    completionHandler()
  }
}

//
//  AppDelegate.swift
//  AnimalGo
//
//  Created by Kiwon on 16/07/2019.
//  Copyright © 2019 AnimalGo. All rights reserved.
//

import UIKit
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        if #available(iOS 13.0, *) {
//            self.window?.overrideUserInterfaceStyle = .light
//        }
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false,
                                     kOSSettingsKeyInAppLaunchURL: false]
        
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload? = result?.notification.payload
        
            print("Message = \(payload!.body ?? "")")
            print("badge number = \(payload?.badge ?? 0)")
            print("notification sound = \(payload?.sound ?? "None")")
            
            // 구앱 대응 - HTML로 푸시를 보낼때 아래 로직이 동작
            if let additionalData = result!.notification.payload!.additionalData,
                let pushURL = additionalData["custom_url"] as? String {
                print("additionalData = \(additionalData)")
                print("pushURL = \(pushURL)")
                
                if let rootVC = self.window?.rootViewController as? MainWebViewController {
                    rootVC.reloadURL(pushURL)
                }
                
                if let actionSelected = payload?.actionButtons {
                    print("actionSelected = \(actionSelected)")
                }
                
                // DEEP LINK from action buttons
                if let actionID = result?.action.actionID {
                    print("actionID = \(actionID)")
                }
            }

        }
        
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: ONE_SIGNAL_APP_ID,
                                        handleNotificationReceived: nil,
                                        handleNotificationAction: notificationOpenedBlock,
                                        settings: onesignalInitSettings)
                
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User enable notifications: \(accepted)")
        })
        
        OneSignal.add(self as OSPermissionObserver)
        OneSignal.add(self as OSSubscriptionObserver)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension AppDelegate: OSPermissionObserver, OSSubscriptionObserver {
    func onOSPermissionChanged(_ stateChanges: OSPermissionStateChanges!) {
        
        if stateChanges.from.status == OSNotificationPermission.notDetermined {
            if stateChanges.to.status == OSNotificationPermission.authorized {
                print("푸시 노티 허용!")
                if let rootVC = self.window?.rootViewController as? MainWebViewController {
                    rootVC.setPushID()
                }
            } else if stateChanges.to.status == OSNotificationPermission.denied {
                print("푸시 노티 미허용!!!! ")
            }
        }
    }
    
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        if !stateChanges.from.subscribed && stateChanges.to.subscribed {
            print("Subscribed for OneSignal push notifications!")
        }
    }
    
    // Output:
    
    /*
     Subscribed for OneSignal push notifications!
     PermissionStateChanges:
     Optional(<OSSubscriptionStateChanges:
     from: <OSSubscriptionState: userId: (null), pushToken: 0000000000000000000000000000000000000000000000000000000000000000 userSubscriptionSetting: 1, subscribed: 0>,
     to:   <OSSubscriptionState: userId: 11111111-222-333-444-555555555555, pushToken: 0000000000000000000000000000000000000000000000000000000000000000, userSubscriptionSetting: 1, subscribed: 1>
     >
     */
}


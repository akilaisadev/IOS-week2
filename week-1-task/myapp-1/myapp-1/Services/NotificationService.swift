//
//  NotificationService.swift
//  myapp-1
//
//  service managing local daily challenge notifications using UNUserNotificationCenter
//

import Foundation
import UserNotifications
import Combine

class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()
    
    private let center = UNUserNotificationCenter.current()
    private let enabledKey = "DailyChallengeNotificationEnabled"
    private let timeKey = "DailyChallengeNotificationTime"
    private let requestIdentifier = "DailyChallengeReminder"
    
    @Published var isAuthorized: Bool = false
    @Published var isEnabled: Bool = false
    @Published var reminderTime: Date = Date()
    
    override private init() {
        super.init()
        center.delegate = self
        loadPreferences()
        checkAuthorizationStatus()
    }
    
    // load saved reminder preference from user defaults
    private func loadPreferences() {
        isEnabled = UserDefaults.standard.bool(forKey: enabledKey)
        
        if let savedTime = UserDefaults.standard.object(forKey: timeKey) as? Date {
            reminderTime = savedTime
        } else {
            // default reminder time to 8:00 PM
            var components = DateComponents()
            components.hour = 20
            components.minute = 0
            if let defaultTime = Calendar.current.date(from: components) {
                reminderTime = defaultTime
            }
        }
    }
    
    // check current notification authorization permissions
    func checkAuthorizationStatus() {
        center.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = (settings.authorizationStatus == .authorized)
            }
        }
    }
    
    // request permission from the user for local notifications
    func requestPermission(completion: ((Bool) -> Void)? = nil) {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
                if granted, let self = self, self.isEnabled {
                    self.scheduleDailyChallenge(at: self.reminderTime)
                }
                completion?(granted)
            }
        }
    }
    
    // schedule daily challenge notification at specified time
    func scheduleDailyChallenge(at date: Date) {
        // cancel existing requests before scheduling a new one
        center.removeAllPendingNotificationRequests()
        
        // update published property and persistence
        DispatchQueue.main.async {
            self.reminderTime = date
            self.isEnabled = true
            UserDefaults.standard.set(true, forKey: self.enabledKey)
            UserDefaults.standard.set(date, forKey: self.timeKey)
        }
        
        // if not yet authorized, request permission first
        if !isAuthorized {
            requestPermission { granted in
                if granted {
                    self.createNotificationRequest(for: date)
                }
            }
            return
        }
        
        createNotificationRequest(for: date)
    }
    
    // helper to construct and register UNNotificationRequest
    private func createNotificationRequest(for date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Daily Challenge Ready!"
        content.body = "Ready to beat your personal best today? Jump into Tap Frenzy, Light It Up, or Quiz Rush!"
        content.sound = .default
        content.badge = 1
        
        // extract hour and minute for daily repeating schedule
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule daily challenge: \(error.localizedDescription)")
            }
        }
    }
    
    // cancel all scheduled daily challenge notifications
    func cancelDailyChallenge() {
        center.removeAllPendingNotificationRequests()
        
        DispatchQueue.main.async {
            self.isEnabled = false
            UserDefaults.standard.set(false, forKey: self.enabledKey)
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationService: UNUserNotificationCenterDelegate {
    // allow notifications to display banners and play sounds even when app is active in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

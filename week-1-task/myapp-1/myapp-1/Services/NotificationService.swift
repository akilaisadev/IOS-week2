//
//  NotificationService.swift
//  myapp-1
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
    
    private func loadPreferences() {
        isEnabled = UserDefaults.standard.bool(forKey: enabledKey)
        
        if let savedTime = UserDefaults.standard.object(forKey: timeKey) as? Date {
            reminderTime = savedTime
        } else {
            var components = DateComponents()
            components.hour = 20
            components.minute = 0
            if let defaultTime = Calendar.current.date(from: components) {
                reminderTime = defaultTime
            }
        }
    }
    
    func checkAuthorizationStatus() {
        center.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = (settings.authorizationStatus == .authorized)
            }
        }
    }
    
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
    
    func scheduleDailyChallenge(at date: Date) {
        center.removeAllPendingNotificationRequests()
        
        DispatchQueue.main.async {
            self.reminderTime = date
            self.isEnabled = true
            UserDefaults.standard.set(true, forKey: self.enabledKey)
            UserDefaults.standard.set(date, forKey: self.timeKey)
        }
        
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
    
    private func createNotificationRequest(for date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Daily Challenge Ready!"
        content.body = "Ready to beat your personal best today? Jump into Tap Frenzy, Light It Up, or Quiz Rush!"
        content.sound = .default
        content.badge = 1
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule daily challenge: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelDailyChallenge() {
        center.removeAllPendingNotificationRequests()
        
        DispatchQueue.main.async {
            self.isEnabled = false
            UserDefaults.standard.set(false, forKey: self.enabledKey)
        }
    }
}

extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

//
//  TimerViewController.swift
//  PowerNapTimer
//
//  Created by RYAN GREENBURG on 9/24/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
import UserNotifications

class TimerViewController: UIViewController {
    
    let myTimer = TimerController()
    fileprivate let userNotificationIdentifier = "timerNotification"
    
    // MARK: - Outlets
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        myTimer.delegate = self
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetTimer()
    }
    
    // MARK: - Actions
    @IBAction func startButtonTapped(_ sender: Any) {
        if myTimer.isOn {
            myTimer.stopTimer()
        } else {
            myTimer.startTimeWith(time: 10)
            scheduleNotifaction()
        }
        updateViews()
    }
    
    func updateViews() {
        // Upate the timer text label
        updateTimerTextLabel()
        if myTimer.isOn {
            startButton.setTitle("Stop Timer", for: .normal)
        } else {
            startButton.setTitle("Start Nap", for: .normal)
        }
    }
    
    func resetTimer() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            let timerLocalNotifications = requests.filter { $0.identifier == self.userNotificationIdentifier }
            guard let timerNotificationRequest = timerLocalNotifications.last,
                let trigger = timerNotificationRequest.trigger as? UNCalendarNotificationTrigger,
                let fireDate = trigger.nextTriggerDate() else { return }
            
            self.myTimer.stopTimer()
            self.myTimer.startTimeWith(time: fireDate.timeIntervalSinceNow)
        }
    }
    
    func updateTimerTextLabel() {
        // take timeRemaining and set the label.text appropriately
        timerLabel.text = myTimer.timeAsString()
    }
    
    // MARK: - AlertController
    func setUpAlerController() {
        var snoozeTextField: UITextField?
        let alert = UIAlertController(title: "Wake Up", message: "Put on a little makeup", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Snooze for how long...."
            textField.keyboardType = .numberPad
            snoozeTextField = textField
        }
        
        let snoozeAction = UIAlertAction(title: "Snooze", style: .default) { (_) in
            guard let snoozeTimeText = snoozeTextField?.text,
                let time = TimeInterval(snoozeTimeText)
                else { return }
            
            self.myTimer.startTimeWith(time: time)
            self.updateViews()
            self.scheduleNotifaction()
        }
        
        let dismissAction = UIAlertAction(title: "Dimsiss", style: .cancel) { (_) in
            self.updateViews()
        }
        
        alert.addAction(snoozeAction)
        alert.addAction(dismissAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Notifications
    func scheduleNotifaction() {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Wake up!"
        notificationContent.body = "Put on a little makeup"
        guard let timeRemaining = myTimer.timeRemaining else { return }
        let fireDate = Date(timeInterval: timeRemaining, since: Date())
        let dateComponents = Calendar.current.dateComponents([.minute, .second], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: userNotificationIdentifier, content: notificationContent, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
    
    func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [userNotificationIdentifier])
    }
}

// MARK: - Timer Delegate
extension TimerViewController: TimerDelegate {
    func timerSecondTick() {
        updateTimerTextLabel()
    }
    
    func timerCompleted() {
        updateViews()
        setUpAlerController()
        // handle notifications stuff
    }
    
    func timerStopped() {
        updateViews()
        cancelNotification()
    }
}

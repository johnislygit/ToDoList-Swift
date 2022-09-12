//
//  AddEditViewController.swift
//  ToDoList
//
//  Created by John Ly on 12/16/20.
//  Copyright © 2020 John Ly. All rights reserved.
//

import UIKit
import EventKit

class AddEditViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    public var task: Task?
    var priorityCheck: Bool = false
    @IBAction func priorityPressed() {
        priorityCheck = !priorityCheck
        if priorityCheck {
            taskPriority.setBackgroundImage(UIImage(named: "flagFILLED"), for: .normal)
        }
        else {
            taskPriority.setBackgroundImage(UIImage(named: "flagOUTLINE"), for: .normal)
        }
    }
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var taskName: UITextField!
    
    @IBOutlet weak var taskPriority: UIButton!
    
    @IBOutlet  var datePicked: UILabel!
    
    @IBOutlet var imageAttach: UIImageView!
    
    @IBAction func imageAttachButtonPressed() {
        //view image full screen?
        //edit photo that is attached.
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            } else {
                print("Camera is not available.")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func saveImageInDocumentDirectory(image: UIImage, fileName: String) -> URL? {

            let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
            let fileURL = documentsUrl.appendingPathComponent(fileName)
        if let imageData = image.pngData() {
                try? imageData.write(to: fileURL, options: .atomic)
                return fileURL
            }
            return nil
        }

    func loadImageFromDocumentDirectory(fileName: String) -> UIImage? {

            let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
            let fileURL = documentsUrl.appendingPathComponent(fileName)
            do {
                let imageData = try Data(contentsOf: fileURL)
                return UIImage(data: imageData)
            } catch {}
            return nil
        }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image =  info[UIImagePickerController.InfoKey.originalImage] as! UIImage?
        imageAttach.image = image
        saveImageInDocumentDirectory(image: image!, fileName: (task?.name ?? taskName.text)!)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func imageAttachButton(_ sender: Any) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let task = task {
            taskName.text = task.name
            //fix date and time notification set for
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = DateFormatter.Style.short
            dateFormatter.timeStyle = DateFormatter.Style.short
            let strDate = dateFormatter.string(from: task.notificationDateTime)
            datePicked.text = "Notification is set for \(strDate)"
            priorityCheck = task.priority
            if priorityCheck {
                taskPriority.setBackgroundImage(UIImage(named: "flagFILLED"), for: .normal)
            }
            else {
                taskPriority.setBackgroundImage(UIImage(named: "flagOUTLINE"), for: .normal)
            }
            imageAttach.image = loadImageFromDocumentDirectory(fileName: task.name)
        }
        updateSaveButtonStatus()
        // Do any additional setup after loading the view.
    }
    //create button to attach photo
    
    @IBAction func textEditingChanged (_ sender: UITextField) {
        updateSaveButtonStatus()
    }
    
    func updateSaveButtonStatus() {
        let nameText = taskName.text ?? ""
        
        saveButton.isEnabled = !nameText.isEmpty
    }
    
   

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
    super.prepare(for: segue, sender: sender)
     
    guard segue.identifier == "saveUnwind" else { return }
     
    let nameText = taskName.text ?? ""
    //fix date and time
    datePicker.datePickerMode = .dateAndTime
        task = Task(name: nameText, priority: priorityCheck, checked: false, notificationDateTime: datePicker.date)
    
        //move this to when a task is created
        //add notifications here
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert,.sound,.badge]) { (granted, error) in
        }
        
        //Customization of the Notification
        let content = UNMutableNotificationContent()
        content.title = "Your task is due soon!"
        content.body = "\(task?.name ?? "A task") is due soon at this time."
        
        //Trigger of Notification
        
        let triggerDate = task?.notificationDateTime
        let dateComponents = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute
        ], from: triggerDate!)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        //request
        let uuidString = UUID().uuidString
        
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        center.add(request) { (error) in
            
        }
        //Create a calendar view of the event in user Calendar
        let eventStore: EKEventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { (granted, error) in
            if (granted) && (error == nil){
                let event: EKEvent = EKEvent(eventStore: eventStore)
                
                event.title = self.task?.name
                event.startDate = self.task?.notificationDateTime
                event.endDate = self.task?.notificationDateTime.addingTimeInterval(300)
                if ((self.task?.priority) != nil) {
                    event.notes = "High Priority"
                }
                else{
                    event.notes = "No Priority"
                }
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let error as NSError {
                    print("Failed to save event with error \(error)")
                }
            }
            else {
                print("failed to save event")
            }
        }
    }
 

}

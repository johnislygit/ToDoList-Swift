//
//  Table.swift
//  ToDoList
//
//  Created by John Ly on 12/14/20.
//  Copyright © 2020 John Ly. All rights reserved.
//

import Foundation
import UIKit

class Task: Codable {
    var name = ""
    var priority = false
    var checked = false
    var notificationDateTime: Date
    //include ui image
    
    static let DocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("tasks").appendingPathExtension("plist")
    
    init (name: String, priority: Bool, checked: Bool, notificationDateTime: Date)
    {
        self.name = name
        self.priority = priority
        self.checked = checked
        self.notificationDateTime = notificationDateTime
    }
    
    static func saveToFile(tasks: [Task]) {
        //create a PropertyListEncoder for encoding purpose
        let propertyListEncoder = PropertyListEncoder()
        let encodedTasks = try? propertyListEncoder.encode(tasks)
        try? encodedTasks?.write(to: ArchiveURL, options: .noFileProtection)
       }
    
    static func loadFromFile() -> [Task]? {
        //use guard for exception handling, retrive the encoded data from local storage
        guard let encodedTasks = try? Data(contentsOf: ArchiveURL) else {return nil}
        //set up decoder
        let propertyListDecoder = PropertyListDecoder()
        return try? propertyListDecoder.decode(Array<Task>.self, from: encodedTasks)
    }
}
//enumeration and doing it by high and low priority

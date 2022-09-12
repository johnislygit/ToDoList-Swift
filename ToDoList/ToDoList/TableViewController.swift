//
//  TableViewController.swift
//  ToDoList
//
//  Created by John Ly on 12/14/20.
//  Copyright © 2020 John Ly. All rights reserved.
//

import UIKit
import UserNotifications

class TableViewController: UITableViewController {

    var task: [Task] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        if let savedTask = Task.loadFromFile() {
        task = savedTask
            
        } else {
            task.append(Task(name: "Example Task", priority: false, checked: false, notificationDateTime: Date(timeIntervalSinceNow: 0)))
        }

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return task.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TableViewCell
        let tasks = task[indexPath.row]
        // Configure the cell...
        //cell.taskName.text = task[indexPath.row].name
        if task[indexPath.row].checked {
            cell.taskCheckButton.setBackgroundImage(UIImage(named: "checkBoxFILLED"), for: .normal)
        }
        else {
            cell.taskCheckButton.setBackgroundImage(UIImage(named: "checkBoxOUTLINE"), for: .normal)
        }
        if task[indexPath.row].priority {
            cell.priorityButton.setBackgroundImage(UIImage(named: "flagFILLED"), for: .normal)
            task[indexPath.row].priority = true
        }
        else {
            cell.priorityButton.setBackgroundImage(UIImage(named: "flagOUTLINE"), for: .normal)
            task[indexPath.row].priority = false
        }
        cell.update(with: tasks)
        cell.showsReorderControl = true
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Tasks To Complete"
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            task.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            Task.saveToFile(tasks: task)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedTask = task.remove(at: fromIndexPath.row)
        task.insert(movedTask, at: to.row)
        tableView.reloadData()
        Task.saveToFile(tasks: task)
    }
    
    

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    
    
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            // Get the new view controller using segue.destination.
            // Pass the selected object to the new view controller.
            if segue.identifier == "AddEditTasks" {
                let indexPath = tableView.indexPathForSelectedRow!
                let tasks = task[indexPath.row]
                let navController = segue.destination as! UINavigationController
                let AddEditViewController = navController.topViewController as! AddEditViewController
                
                    AddEditViewController.task = tasks
            }
        }
        
        @IBAction func unwindToTaskTableView(segue: UIStoryboardSegue) {
            guard segue.identifier == "saveUnwind" else {
                return
            }
            
            let sourceViewController = segue.source as! AddEditViewController
            
            if let tasks = sourceViewController.task {
                if let selectedIndexPath = tableView.indexPathForSelectedRow { //update record
                    task[selectedIndexPath.row] = tasks
                    tableView.reloadRows(at: [selectedIndexPath], with: .none)
                } else { //create a new record
                    let newIndexPth = IndexPath(row: task.count, section: 0)
                    task.append(tasks)
                    tableView.insertRows(at: [newIndexPth], with: .automatic)
                }
            }
            
            Task.saveToFile(tasks: task)
        }
}

//
//  TableViewCell.swift
//  ToDoList
//
//  Created by John Ly on 12/14/20.
//  Copyright © 2020 John Ly. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    var taskDone: Bool = false
    var taskPriority: Bool = false
    @IBAction func PriorityButtonPressed() {
        if taskPriority {
            priorityButton.setBackgroundImage(UIImage(named: "flagFILLED"), for: .normal)
        }
        else {
            priorityButton.setBackgroundImage(UIImage(named: "flagOUTLINE"), for: .normal)
        }
    }
       
    @IBAction func TaskButtonPressed() {
        taskDone = !taskDone
        if taskDone {
               taskCheckButton.setBackgroundImage(UIImage(named: "checkBoxFILLED"), for: .normal)
            taskName.isHidden = true
            CompletedLabel.isHidden = false
        }
        else {
               taskCheckButton.setBackgroundImage(UIImage(named: "checkBoxOUTLINE"), for: .normal)
            taskName.isHidden = false
            CompletedLabel.isHidden = true
        }
    }
    //make button into UIImageView
       
    @IBOutlet weak var priorityButton: UIButton!
       
    @IBOutlet weak var taskCheckButton: UIButton!
       
    @IBOutlet weak var taskName: UILabel!
    
    @IBOutlet var taskImage: UIImageView!
    
    @IBOutlet weak var CompletedLabel: UILabel!
    
    func update(with task: Task) {
        taskName.text = task.name
        taskPriority = task.priority
        taskDone = task.checked
        taskImage.image = loadImageFromDocumentDirectory(fileName: task.name)
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  ViewController.swift
//  Foodiary
//
//  Created by Saavan Dhaliwal on 22/10/17.
//  Copyright © 2017 Saavan Dhaliwal. All rights reserved.
//

// Background Image Sourced From: https://pixabay.com/en/pasta-fettuccine-food-1181189/

// Background Image For The Launch Screen Sourced From: https://pixabay.com/en/floor-wood-hardwood-floors-1256804/

// Importing
import UIKit
import CoreML
import EventKit
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    // Defining the variable that is linked to the Machine Learning Model
    var model: Inceptionv3!
    
    // Defines the outlets for this ViewController so they can be edited and worked with
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var classifier: UILabel!
    @IBOutlet var confidence: UILabel!
    @IBOutlet var homeOutlet: UIButton!
    @IBOutlet var cameraOutlet: UIButton!
    @IBOutlet var chooseFromLibraryOutlet: UIButton!
    
    
    var foodTextField: UITextField?
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        model = Inceptionv3()
        
    }
    
    // When the page loads it will load the buttons to have rounded corners
    override func viewDidLoad() {
        super.viewDidLoad()
        homeOutlet.layer.cornerRadius = 6
        cameraOutlet.layer.cornerRadius = 6
        chooseFromLibraryOutlet.layer.cornerRadius = 6
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Allows the user to access the camera from the ViewController so they can take a photo to be analysed
    @IBAction func camera(_ sender: Any) {
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera){
            return
        }
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        cameraPicker.allowsEditing = false
        present(cameraPicker, animated: true)
    }
    
    // Allows the user to open their photo library so they can choose a photo they want to be analysed
    @IBAction func openLibrary(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
        
    }
    
    // After the image has been chosen this runs the detectImageContent function allowing the image to be analysed
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleToFill
            imageView.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
        
        detectImageContent()
    }
}

// An extension to the View Controller
extension ViewController: UIImagePickerControllerDelegate{ func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { dismiss(animated: true, completion: nil)
    
    }
    
    // Begins the process for image detection by firstly updating the classifier label and accesing the model
    func detectImageContent() {
        classifier.text = "Thinking"
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Failed to load model")
        }
        
        // Creates a vision request in which the top result for what the model thinks the image is collected and stored in the topResult variable for further use
        
        let request = VNCoreMLRequest(model: model) {[weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first
                else {
                    fatalError("Unexpected results")
                    
            }
            
            // After this image has been analysed the classifier label is updated with what the model thinks the food/object is. The confidence label is also updated showing the user a percentage representing how correct the model thinks it is.
            DispatchQueue.main.async { [weak self] in
                self?.classifier.text = "\(topResult.identifier)"
                
                self?.confidence.text = "\(Int(topResult.confidence * 100))% sure"
                
                self?.actionSheet()
                
            }
        }
        
        // Creates ciImage
        guard let ciImage = CIImage(image: self.imageView.image!)
            else { fatalError("Cant create CIImage from UIImage") }
        
        // This runs the GoogLeNetPlaces model classifier
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global().async {
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }
        }
    }
    
    // This function is used to update the Apple Calendar. Everytime this function runs it adds an event based on the time it was run.
    func saveFood() {
        let eventStore : EKEventStore = EKEventStore()
        
        // Requests permission to use the user's Calendar
        eventStore.requestAccess(to: EKEntityType.event) { (granted,error) in
            
            // If the permission is granted the app continues to add the event.
            if (granted) &&  (error == nil) {
                print("permission is granted")
                
                let event:EKEvent = EKEvent(eventStore: eventStore)
                
                // Sets the title of the event to the classifier label text
                event.title = "\(self.classifier.text!)"
                
                // Sets the start date and the end date of the event as the time and date it was logged
                event.startDate = NSDate() as Date!
                event.endDate = NSDate() as Date!
                event.notes = "This item was logged using Foodiary if you would like to add ingredients or calories please do so here"
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let specError as NSError {
                    print("A specific error occurred: \(specError)")
                } catch {
                    print("An error occurred")
                }
                print("Event saved")
                
                // If the user does not give permission to use the Calendar the else statement runs
            } else {
                print("need permission to create a event")
            }
        }
        
    }
    
    // When this button is clicked it takes the user from this ViewController to the home page of the application
    @IBAction func Home(_ sender: Any) {
        performSegue(withIdentifier: "cameraToHomeSegue", sender: nil)
    }
    
    // This is the alert that allows the user to correct Foodiary if it guesses what the food/object is incorrectly
    func alert() {
        
        // Asks the user to type in the correct food name
        let alert = UIAlertController(title: "Type in your food name", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            // Sets the placeholder text as the incorrect guess that the model made
            textField.text = "\(self.classifier.text!)"
        }
        
        // After the user corrects the food/object name  and clicks Ok the application updates the classifier label, sets the confidence to 100% as the user corrected it and runs the saveFood function(adding an event to the Apple Calendar)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            self.classifier.text! = "\(textField!.text!)"
            self.confidence.text! = "100% Sure"
            self.saveFood()
            // Takes the user to the Apple Calendar to show them their newly added food/object
            if let url = NSURL(string: "calshow://"){
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    // This is the action sheet that runs after the model has finished guessing what the food/object is. It asks the user if the food/object guess was correct
    func actionSheet() {
        let actionSheet = UIAlertController(title: "Foodiary thought you took a photo of a(n) \(classifier.text!). Was it correct?", message: nil, preferredStyle: .actionSheet)
        
        // If the user says the model's guess was correct it runs the saveFood function(adding an event to the Apple Calendar). It then takes the user to the Apple Calendar application
        let yes = UIAlertAction(title: "Yes", style: .default) { action in
            self.saveFood()
            if let url = NSURL(string: "calshow://"){
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            }
        }
        
        // If the user says the model's guess was incorrect then it runs the alert function allowing the user to correct the guess.
        let no = UIAlertAction(title: "No", style: .default) { action in
            self.alert()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(yes)
        actionSheet.addAction(no)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
        
    }
    
}

//
//  HomeController.swift
//  Foodiary
//
//  Created by Saavan Dhaliwal on 22/10/17.
//  Copyright © 2017 Saavan Dhaliwal. All rights reserved.
//


// Background Image Sourced From: https://pixabay.com/en/background-frame-food-kitchen-cook-1932466/


import UIKit

class HomeController: UIViewController {
    
    // Defines the outlets for this ViewController so they can be edited and worked with
    @IBOutlet var calendarButtonOutlet: UIButton!
    @IBOutlet var analysisButtonOutlet: UIButton!
    @IBOutlet var infoButtonOutlet: UIButton!
    
    
    // When the page loads it will load the buttons to have rounded corners
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarButtonOutlet.layer.cornerRadius = 6
        analysisButtonOutlet.layer.cornerRadius = 6
        infoButtonOutlet.layer.cornerRadius = 6
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // If the user clicks this button they will be taken to the Apple Calendar application
    @IBAction func calendarButtonAction(_ sender: Any) {
        if let url = NSURL(string: "calshow://"){
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    // If the user clicks this button they will be taken to the Analysis page
    @IBAction func analysisButtonActiom(_ sender: Any) {
        performSegue(withIdentifier: "cameraSegue", sender: nil)
    }
    
    // If the user clicks this button they will be taken to the Info page
    @IBAction func infoButtonAction(_ sender: Any) {
        performSegue(withIdentifier: "homeToInfoSegue", sender: nil)
    }
}

//
//  InfoViewController.swift
//  Foodiary
//
//  Created by Saavan Dhaliwal on 25/10/17.
//  Copyright © 2017 Saavan Dhaliwal. All rights reserved.
//

// Background Image Sourced From: https://pixabay.com/en/table-cover-red-detail-kitchen-2803275/

import UIKit

class InfoViewController: UIViewController {
    
    // Defines the outlets for this ViewController so they can be edited and worked with
    @IBOutlet var infoDescription: UILabel!
    @IBOutlet var infoToHomeButtonOutlet: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        infoToHomeButtonOutlet.layer.cornerRadius = 6
        
        // This code was sourced from: https://stackoverflow.com/questions/990221/multiple-lines-of-text-in-uilabel
        infoDescription.lineBreakMode = .byWordWrapping
        infoDescription.numberOfLines = 0
        // End of sourced code
        
        // The text that goes in the infoDescription label telling the user how the app is used
        infoDescription.text = "How to use: \n \nOnce launched the application will take you to the home screen where you will be able to choose from three options. \n - Calendar \n - Analysis \n - Info \n \nClicking Calendar will take you to the Apple Calendar which will allow you to view your logged food. \nClicking Anlaysis will take you to a page where you will be able to take a photo or choose one from your library. This photo will be analysed and Foodiary will guess what the photo is. If Foodiary guesses wrong you will be able to correct it by following the steps in the alert."
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // If the user clicks this button they will be taken to the Home Page
    @IBAction func infoToHomeButton(_ sender: Any) {
        performSegue(withIdentifier: "infoToHomeSegue", sender: nil)
    }
    
}

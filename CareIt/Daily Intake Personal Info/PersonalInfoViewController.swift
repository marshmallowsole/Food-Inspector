//
//  PersonalInfoViewController.swift
//  CareIt
//
//  Created by Annie Liang (student LM) on 1/29/19.
//  Copyright © 2019 Jason Kozarsky (student LM). All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import UIKit

class PersonalInfoViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    
    var sexOptions = ["Male", "Female", "Other"]
    var weightOptions = (1...1400).map{$0}
    var heightOptions = (1...100).map{$0}
    var activityLevelOptions = ["Low", "Medium", "High"]
    var sexChoice: String?
    var weightChoice: Int?
    var heightChoice: Int?
    var activityChoice: String?
    var birthDateChoice: String?
    var allergies: [String] = []
    var userInfo: [String : Any] = [:]
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var sex: UIPickerView!
    @IBOutlet weak var birthday: UIDatePicker!
    @IBOutlet weak var weight: UIPickerView!
    @IBOutlet weak var height: UIPickerView!
    @IBOutlet weak var activityLevel: UIPickerView!
    @IBOutlet weak var addAllergyTextField: UITextField!
    @IBOutlet weak var doneAllergyTextFieldOutlet: UIButton!
    
   
        
    // userInfo["Allergies"]
    
    
    
    @IBAction func doneAllergyTextField(_ sender: Any)  {
        
        if addAllergyTextField.hasText{
            
        
        var x: [String] = defaults.stringArray(forKey: "addAllergies") ?? [String]()
        
        x.append( addAllergyTextField.text!)
        
        defaults.set(x, forKey: "addAllergies")
        
        addAllergyTextField.text = ""
        
        
        }
        
     
        
    }
    
    @IBAction func backToPersonalInfoViewController(_ segue: UIStoryboardSegue) {
    }
    
    //When the done button is pressed on screen, this code uploads all personal info to
    // the Firebase Database and then segues to the calorie view controller
    @IBAction func doneButtonTouchedUp(_ sender: UIButton) {
        
        //getting the uid and setting that as the reference for the child in the database
        // so that each user's data can be pulled by their uid
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let database = Database.database().reference().child("users\(uid)")
        
        // the user's info gets stored in this dictionary
        var userObject: [String: Any] = [:]
        
        if let sexChoice = sexChoice{
            userObject["Sex"] = sexChoice
        }
        if let weightChoice = weightChoice{
            userObject["Weight"] = weightChoice
        }
        if let heightChoice = heightChoice{
            userObject["Height"] = heightChoice
        }
        if let activityChoice = activityChoice{
            userObject["Activity"] = activityChoice
        }
        if let birthDateChoice = birthDateChoice{
            userObject["BirthDate"] = birthDateChoice
        }
        //allergies array is not optional, always is at least an empty array
        userObject["Allergies"] = allergies
        
        //uploads the users info, as a dictionary, to the database
        database.setValue(userObject)
        
    }
    
    //called every time the user updates the picker view
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1{ //sex
            sexChoice = sexOptions[row]
        }
        else if pickerView.tag == 3{ //weight
            weightChoice = weightOptions[row]
        }
            
        else if pickerView.tag == 4{ //height
            heightChoice = heightOptions[row]
        }
            
        else if pickerView.tag == 5{ //activity
            activityChoice = activityLevelOptions[row]
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.tag == 1){
            return sexOptions.count
        }
        else if (pickerView.tag == 3){
            return weightOptions.count
        }
        else if (pickerView.tag == 4){
            return heightOptions.count
        }
        else {
            return activityLevelOptions.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var pickerLabel = UILabel()
        pickerLabel.font = UIFont(name: "Avenir Book", size: 18) // In this use your custom font
        if (pickerView.tag == 1){
            return sexOptions[row]
        }
        else if (pickerView.tag == 3){
            return "\(weightOptions[row]) lbs"
        }
        else if (pickerView.tag == 4){
            return "\(heightOptions[row]) inches"
        }
        else {
            return activityLevelOptions[row]
        }
    }
    
    //    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
    //
    //
    //        pickerLabel.textColor = UIColor.black
    //        pickerLabel.text = "PickerView Cell Title"
    //        // pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 15)
    //
    //        pickerLabel.textAlignment = NSTextAlignment.center
    //        return pickerLabel
    //    }
    
    //Sets up the default rows shown by the pickerviews
    //also sets the user's personal info choices if they did not move the pickerview
    func update(){
        let defaults = UserDefaults.standard
        var weightRow: Int
        var heightRow: Int
        var sexRow: Int
        var activityRow: Int
        
        if !userInfo.isEmpty && userInfo["Weight"] != nil{
            weightRow = userInfo["Weight"] as! Int
        }
        else if (defaults.integer(forKey: "defaultWeightPickerRow") != 0) {
            weightRow = defaults.integer(forKey: "defaultWeightPickerRow")
        }
        else{
            weightRow = 150
        }
        weightChoice = weightOptions[weightRow]
        
        print(userInfo["Height"] != nil)
        
        if !userInfo.isEmpty && userInfo["Height"] != nil{
            heightRow = userInfo["Height"] as! Int
            print("it worked")
        }
        else if (defaults.integer(forKey: "defaultHeightPickerRow") != 0) {
            heightRow = defaults.integer(forKey: "defaultHeightPickerRow")
            print("second")
        }
        else{
            heightRow = 70
            print("third")
        }
        heightChoice = heightOptions[heightRow]
        
        if !userInfo.isEmpty && userInfo["Sex"] != nil{
            sexRow = userInfo["Sex"] as! String == "Male" ? 0 : 1
        }
        else if (defaults.integer(forKey: "defaultSexPickerRow") != 0) {
            sexRow = defaults.integer(forKey: "defaultSexPickerRow")
        }
        else{
            sexRow = 0
        }
        sexChoice = sexOptions[sexRow]
        
        if !userInfo.isEmpty && userInfo["Activity"] != nil{
            activityRow = userInfo["Activity"] as! String == "Low" ? 0 : userInfo["Activity"] as! String == "Medium" ? 1 : 2
        }
        else if (defaults.integer(forKey: "defaultActivityLevelPickerRow") != 0) {
            activityRow = defaults.integer(forKey: "defaultActivityLevelPickerRow")
        }
        else{
            activityRow = 0
        }
        
        if !userInfo.isEmpty && userInfo["Allergies"] != nil{
            allergies = userInfo["Allergies"] as! [String]
        }
        
        activityChoice = activityLevelOptions[activityRow]
        
        weight.selectRow(weightRow, inComponent: 0, animated: false)
        height.selectRow(heightRow, inComponent: 0, animated: false)
        sex.selectRow(sexRow, inComponent: 0, animated: false)
        activityLevel.selectRow(activityRow, inComponent: 0, animated: false)
        
        if !userInfo.isEmpty{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MM yyyy"
            birthday.setDate(dateFormatter.date(from: userInfo["BirthDate"] as! String) ?? Date(), animated: false)
        }
        
        firstLoad = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !firstLoad{
            update()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = view.backgroundColor
        
        weight.selectRow(99, inComponent: 0, animated: true)
        height.selectRow(64, inComponent: 0, animated: true)
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let databaseRef = Database.database().reference().child("users\(uid)")
        
        databaseRef.observeSingleEvent(of: .value, with: {snapshot in
            self.userInfo = snapshot.value as? [String: Any] ?? [:]
            //update method must be called on completion
            self.update()
        })
        
        //calls the handler function whenever the birthday pickerview is updated
        birthday.addTarget(self, action: #selector(handler(sender:)), for: UIControlEvents.valueChanged)
        
        // This stores the user's birthdate if the user did not change the pickerview
        let components = Calendar.current.dateComponents([.year, .month, .day], from: birthday.date)
        //stores date as string in the format: (date) (month) (year)
        if let day = components.day, let month = components.month, let year = components.year {
            birthDateChoice = "\(day) \(month) \(year)"
        }
        
   
    }
    // called whenever the birthdate pickerview is updated by the user
    @objc func handler(sender: UIDatePicker) {
        
        //stores components of sender date
        let components = Calendar.current.dateComponents([.year, .month, .day], from: sender.date)
        
        //stores date as string in the format: (date) (month) (year)
        if let day = components.day, let month = components.month, let year = components.year {
            birthDateChoice = "\(day) \(month) \(year)"
        }
        
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        
        
        navigationController?.navigationBar.isHidden = true
        
        if segue.identifier == "allergyCategories" {
            if let navigationVC = segue.destination as? UINavigationController, let myViewController = navigationVC.topViewController as? AllergyTableViewController {
                myViewController.allAllergySection = false
                myViewController.tableViewData = ["Dairy", "Nuts", "Gluten", "Meat", "Grains", "Fruits", "Vegetables", "Seafood"]
            }
        }
        else if segue.identifier == "allAllergies" {
            if let navigationVC = segue.destination as? UINavigationController, let myViewController = navigationVC.topViewController as? AllergyTableViewController {
                myViewController.allAllergySection = true
                myViewController.tableViewData = defaults.stringArray(forKey: "addAllergies") ?? [String]()
            
            }
        }
        
    }
    
}


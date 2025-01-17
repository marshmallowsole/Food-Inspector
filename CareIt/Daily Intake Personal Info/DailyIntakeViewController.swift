//
//  DailyIntakeViewController.swift
//  CareIt
//
//  Created by Katherine Wang (student LM) on 2/25/19.
//  Copyright © 2019 Jason Kozarsky (student LM). All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

let date = Date()
let calendar = Calendar.current

var month = calendar.component(.month, from: date) - 1
var year = calendar.component(.year, from: date)
var day = calendar.component(.day, from: date)

class DailyIntakeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var Calendar: UICollectionView!
    
    @IBOutlet weak var Month: UILabel!
    
    @IBOutlet weak var recomCalories: UILabel!
    
    @IBOutlet weak var calDescLabel: UILabel!
    
    //as an outlet?
    @IBOutlet weak var addCalBox: UITextField!
    
    @IBAction func addCalButon(_ sender: UIButton) {
        calculateCalories()
    }
    
    let Months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var daysInMonths = [31,28,31,30,31,30,31,31,30,31,30,31]
    
    var firstWeekDayOfMonth = 0   //(Sunday-Saturday 1-7)
    
    //for getting stuff from firebase
    var userInfo: [String: Any]? = [:]
    
    //daily recommended calories, calculated from formula
    var calcCalories = 0.0
    //each food consumed adds to the consumed calories to be subtracted from calcCalories
    var consumedCalories = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        //hides navigation bar
        navigationController?.navigationBar.isHidden = true
        
        //sets the month text label to current month
        Month.text = "\(Months[month]) \(year)"
        
        //finds number of empty cells before first day of month
        firstWeekDayOfMonth=getFirstWeekDay()
        
        //for leap years, make february month of 29 days
        //CHECK
        if month == 1 && year % 4 == 0 {
            daysInMonths[month] = 29
        }
        
        recomCalories.text = "No Date Selected"
        
        addCalBox.leftAnchor.constraint(equalTo: view.leftAnchor, constant: (view.frame.width-200)/2).isActive = true
        
//        print("\(month) \(day) \(year)")
        
    }
    
    //hides navigation bar
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = view.backgroundColor
        navigationController?.navigationBar.isHidden = true
        
        
        
        //gets the personal data from firebase
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let databaseRef = Database.database().reference().child("users\(uid)")
        
        databaseRef.observeSingleEvent(of: .value, with: {snapshot in
            self.userInfo = snapshot.value as? [String: Any] ?? [:]
        })

        
        calculateCalories()
        
        
        
    }
    
    
    
    func calculateCalories(){
        
        if self.userInfo?["BirthDate"] != nil{
            //prints birthdate
//            print(self.userInfo?["BirthDate"] as! String)
            
            //sets birthdate as String
            var birthdate = self.userInfo?["BirthDate"] as! String
            let age = Double(year) - Double(birthdate.split(separator: " ")[2])!
            
            //pulls info from firebase for below calculations
            let weight = self.userInfo?["Weight"] as! Double
            let height = self.userInfo?["Height"] as! Double
            
            if let sex = self.userInfo?["Sex"]{
                if (sex as! String == "Female") {
                    calcCalories = 10*(weight/2.20462)
                    calcCalories += 6.25*(height/0.393701) - 5*age - 161
                }
                else {
                    calcCalories = 10*(weight/2.20462)
                    calcCalories += 6.25*(height/0.393701) - 5*age + 5
                }
            }
            
            if let activity = self.userInfo?["Activity"]{
                if (activity as! String == "Low") {
                    calcCalories *= 1.2
                }
                else if (activity as! String == "Medium") {
                    calcCalories *= 1.3
                }
                else {
                    calcCalories *= 1.4
                }
            }
            
            
            //add calories manually
//            print(calcCalories)
//            print(addCalBox.text)
            //check to see if textbox enter can be converted into an int
            if addCalBox.text != nil{
//                var manual = addCalBox!.text
                  print(addCalBox.text)
//                consumedCalories += Double(manual!)!
////                print(manual)
            }

            
            //can set the recomCalories label to the calcCalories - consumed
            
            //            if addCalBox.text != nil && addCalBox.text is Int{
            //
            ////                recomCalories.text = "\(NSString(format:"%.0f", calcCalories - addCalBox.text))"
            //                recomCalories.text = "\(Int(calcCalories) - Int(addCalBox.text))"
            //            }
            
            
        }
            
        else{
            print("nil")
        }
        
        //copied from personal info
        //getting the uid and setting that as the reference for the child in the database
        // so that each user's data can be pulled by their uid
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let database = Database.database().reference().child("users\(uid)")
        var userInfo: [String:Any] = [:]
        let databaseRef = Database.database().reference().child("users\(uid)")
        
        // the user's info gets stored in this dictionary
        
        databaseRef.observeSingleEvent(of: .value, with: {snapshot in
            userInfo = snapshot.value as? [String: Any] ?? [:]
        })
        
        userInfo["Calories"] = calcCalories
        
        database.setValue(userInfo)
    }
    
    
    
    
    
    
    //empty spaces before the first day of the month
    func getFirstWeekDay() -> Int {
        let day = ("\(year)-\(month+1)-01".date?.firstDayOfTheMonth.weekday)!
        return day
    }
    
    @IBAction func backToDailyIntakeViewController(_ segue: UIStoryboardSegue) {
    }
    
    //possibly get rid of this later, but calls when month is changed
    func didChangeMonth(monthIndex: Int, currYear: Int) {
        
        //for leap year, make february month of 29 days
        if month == 1 {
            if year % 4 == 0 {
                daysInMonths[month] = 29
            } else {
                daysInMonths[month] = 28
            }
        }
        
        firstWeekDayOfMonth=getFirstWeekDay()
        
        Calendar.reloadData()
    }
    
    
    
    
    
    //goes to next month
    @IBAction func next(_ sender: UIButton) {
        month += 1
        if month > 11 {
            month = 0
            year += 1
        }
        
        Month.text = "\(Months[month]) \(year)"
        didChangeMonth(monthIndex: month, currYear: year)
        
        Calendar.reloadData()
    }
    //goes to previous month
    @IBAction func back(_ sender: UIButton) {
        month -= 1
        if month < 0 {
            month = 11
            year -= 1
        }
        
        Month.text = "\(Months[month]) \(year)"
        didChangeMonth(monthIndex: month, currYear: year)
        
        Calendar.reloadData()
        
    }
    
    
    
    
    
    
    
    //number of items in the collection view, should be current month - 1 to get month index, plus the first days
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        print(DaysInMonths[month] + firstWeekDayOfMonth - 1)
        return daysInMonths[month] + firstWeekDayOfMonth - 1
    }
    
    
    
    
    
    
    //cell at each day in the collection view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Calendar", for: indexPath) as! DateCollectionViewCell
        
        
        cell.backgroundColor = UIColor.clear
        cell.DateLabel.textColor = UIColor.black
        
        
        if indexPath.item <= firstWeekDayOfMonth - 2 {
            cell.isHidden=true
        } else {
            let calcDate = indexPath.row-firstWeekDayOfMonth+2
            cell.isHidden=false
            cell.DateLabel.text="\(calcDate)"
        }
        
        
        //hides every cell smaller than one
        if Int(cell.DateLabel.text!)! < 1{
            cell.isHidden = true
        }
        
        
        //current date marked in red
        //        if month == Months[calendar.component(.month, from: date)-1] && year == calendar.component(.year, from: date) && indexPath.row + 1 + numberOfEmptyBox == day{
        //            cell.backgroundColor = UIColor.red
        //        }
        
        return cell
    }
    
    
    //Formats cells in calendar to different devices
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width/8
        return CGSize(width: width, height: width)
        
    }
    
    //did select cell: change cell background to red
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell=collectionView.cellForItem(at: indexPath)
        
        //deselect the current day ?
        //        if month == Months[calendar.component(.month, from: date)-1] && year == calendar.component(.year, from: date) && indexPath.row + 1 + numberOfEmptyBox == day{
        //            cell?.backgroundColor = UIColor.clear
        //        }
        cell?.backgroundColor=UIColor.red
        
        calculateCalories()
        
        //do display nutrient info stuff here
        print(month)
        print(calendar.component(.month, from: date)-1)
        print(day)
        print(firstWeekDayOfMonth)
        print(indexPath.row)
        
        
        if month == calendar.component(.month, from: date)-1 && year == calendar.component(.year, from: date) && indexPath.row == day{
            
            calDescLabel.text = "Calories Remaining Today:"
            recomCalories.text = "\(NSString(format:"%.0f", calcCalories - consumedCalories))"
            //or pull from firebase
        }
        else{
            calDescLabel.text = "Calories Consumed:"
            // if consumed, check if firebase has the date and pull, else put 0
            
            //month day year (space separated)
            
            
            //if firebase has this date
            if self.userInfo?["\(calendar.component(.month, from: date)-1) \(indexPath.row) \(calendar.component(.year, from: date))"] != nil{
                //prints birthdate
                //            print(self.userInfo?["BirthDate"] as! String)
                
                //sets birthdate as String
                let ca = self.userInfo?["\(calendar.component(.month, from: date)-1) \(indexPath.row) \(calendar.component(.year, from: date))"] as! Double
                recomCalories.text = "\(calcCalories - ca)"
            }
            else{
                recomCalories.text = "No activity logged"
            }
            
            
            
        }
        
        
    }
    
    
    //did deselect cell: change to clear
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell=collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor=UIColor.clear
    }
    
    
    
}






//get first day of the month
extension Date {
    var weekday: Int {
        return Calendar.current.component(.weekday, from: self)
    }
    var firstDayOfTheMonth: Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year,.month], from: self))!
    }
}

//get date from string
extension String {
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var date: Date? {
        return String.dateFormatter.date(from: self)
    }
}

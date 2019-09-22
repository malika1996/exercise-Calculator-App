//
//  ViewController.swift
//  CalculatorApp
//
//  Created by vinmac on 22/09/19.
//  Copyright © 2019 vinmac. All rights reserved.
//

import UIKit

enum Operators: Int {
    case Clear = 11, Divide, Multiply, Subtract, Add, EqualTo, Dot
}

class ViewController: UIViewController {

    @IBOutlet weak var btnAC: UIButton!
    @IBOutlet weak var label: UILabel!
    
    var currentNumber: Double = 0
    var previousNumber: Double = 0
    var calculationsOn = false
    var operationTag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func numberTapped(_ sender: CustomButton) {
        if calculationsOn == true {
            label.text = String(sender.tag-1)
            currentNumber = Double(label.text!)!
            calculationsOn = false
        }
            
        else { // Number preparation from digits
            if label.text == "0" {
                label.text = ""
            }
            if sender.tag == Operators.Dot.rawValue {
                label.text = label.text! + "."
            } else {
                label.text = label.text! + String(sender.tag-1)
            }
             currentNumber = Double(label.text!)!
        }
    }
    @IBAction func btnOperationTapped(_ sender: CustomButton) {
        if label.text != "" && sender.tag != Operators.Clear.rawValue && sender.tag != Operators.EqualTo.rawValue && label.text != "÷" && label.text != "*" && label.text != "+" && label.text != "-" {
            previousNumber = Double(label.text!)!
            if sender.tag == Operators.Divide.rawValue {
                label.text = "÷"
            }
            
            if sender.tag == Operators.Multiply.rawValue {
                label.text = "*"
            }
            if sender.tag == Operators.Subtract.rawValue {
                label.text = "-"
            }
            
            if sender.tag == Operators.Add.rawValue {
                label.text = "+"
            }
            operationTag = sender.tag
            calculationsOn = true
        }
            
        else if sender.tag == Operators.EqualTo.rawValue {
            if operationTag == Operators.Divide.rawValue {
                label.text = String(previousNumber / currentNumber)
            }
                
            else if operationTag == Operators.Multiply.rawValue {
                label.text = String(previousNumber * currentNumber)
            }
                
            else if operationTag == Operators.Subtract.rawValue {
                label.text = String(previousNumber - currentNumber)
            }
                
            else if operationTag == Operators.Add.rawValue {
                label.text = String(previousNumber + currentNumber)
            }
        }
            
        else if sender.tag == Operators.Clear.rawValue {
            label.text = "0"
            previousNumber = 0
            currentNumber = 0
            operationTag = 0
        }
    }
}

class CustomButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.height / 2.0
        self.titleLabel!.font = self.titleLabel?.font.withSize(35)
    }
}


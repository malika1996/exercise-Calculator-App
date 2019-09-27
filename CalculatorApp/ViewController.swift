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

    // MARK: Private IBOutlets
    @IBOutlet weak private var btnAC: UIButton!
    @IBOutlet weak private var label: UILabel!
    
    // MARK: Default values
    var currentNumber: Double = 0
    var previousNumber: Double = 0
    var calculationsOn = false
    var operationTag = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: IBActions
    @IBAction private func numberTapped(_ sender: CustomButton) {
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
    @IBAction private func btnOperationTapped(_ sender: CustomButton) {
        if label.text != "" && sender.tag != Operators.Clear.rawValue && sender.tag != Operators.EqualTo.rawValue && label.text != "÷" && label.text != "*" && label.text != "+" && label.text != "-" {
            self.computePreviousNumAndUpdateOperationOnLabel(tag: sender.tag)
        }
            
        else if sender.tag == Operators.EqualTo.rawValue {
            self.equalToOperatorTapped()
        }
            
        else if sender.tag == Operators.Clear.rawValue {
            label.text = "0"
            previousNumber = 0
            currentNumber = 0
            operationTag = 0
        }
    }
    
    private func equalToOperatorTapped() {
        switch self.operationTag {
        case Operators.Divide.rawValue:
            label.text = String(previousNumber / currentNumber)
        case Operators.Multiply.rawValue:
            label.text = String(previousNumber * currentNumber)
        case Operators.Subtract.rawValue:
            label.text = String(previousNumber - currentNumber)
        case Operators.Add.rawValue:
            label.text = String(previousNumber + currentNumber)
        default:
            break
        }
    }
    
    private func computePreviousNumAndUpdateOperationOnLabel(tag: Int) {
        previousNumber = Double(label.text!)!
        
        switch tag {
        case Operators.Divide.rawValue:
            label.text = "÷"
        case Operators.Multiply.rawValue:
            label.text = "*"
        case Operators.Subtract.rawValue:
            label.text = "-"
        case Operators.Add.rawValue:
            label.text = "+"
        default:
            print("")
        }
        operationTag = tag
        calculationsOn = true
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


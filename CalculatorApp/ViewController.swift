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
    private var currentNumber: Double = 0
    private var previousNumber: Double = 0
    private var calculationsOn = false
    private var operationTag = 0
    private var equalToOperationFinished = false
    private var numOfDigitsSoFar = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: IBActions
    @IBAction private func numberTapped(_ sender: CustomButton) {
        if self.equalToOperationFinished {
            self.checkForNewOrChainCalculation()
        }
        if calculationsOn {
            label.text = String(sender.tag-1)
            currentNumber = Double(label.text!)!
            calculationsOn = false
            self.numOfDigitsSoFar += 1
        }
        else { // Number preparation from digits
            if label.text == "0" {
                label.text = ""
            }
            self.restrictDigitsNum(tag: sender.tag)
            self.numOfDigitsSoFar += 1
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
        self.numOfDigitsSoFar = 0
    }
    
    private func restrictDigitsNum(tag: Int) {
        if self.numOfDigitsSoFar <= 7 {
            if tag == Operators.Dot.rawValue {
                // To have only one decimal in the number
                if !(label.text!.contains(".")) {
                    if label.text == "" {
                        // To avoid Double(.) -> nil case
                        label.text = "0."
                    } else {
                        label.text = label.text! + "."
                    }
                }
            } else {
                label.text = label.text! + String(tag-1)
            }
        }
    }
    
    private func checkForNewOrChainCalculation() {
        currentNumber = 0
        // Operation on previous result as first operand
        if label.text != "÷" && label.text != "*" && label.text != "+" && label.text != "-" {
            self.operationTag = 0
            self.previousNumber = 0
        }
        self.equalToOperationFinished = false
        label.text = ""
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
        // Result stored for chain calculations
        self.previousNumber = Double(label.text!)!
        self.currentNumber = 0
        self.equalToOperationFinished = true
    }
    
    private func computePreviousNumAndUpdateOperationOnLabel(tag: Int) {
        self.preparePreviousNumForChainCalculations()
        if self.previousNumber == 0 {
            previousNumber = self.currentNumber
        }
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
    
    private func preparePreviousNumForChainCalculations() {
        // Prepare previousNum by computing previous chain result
        if self.previousNumber != 0 && self.currentNumber != 0 {
            switch self.operationTag {
            case Operators.Divide.rawValue:
                self.previousNumber = previousNumber / currentNumber
            case Operators.Multiply.rawValue:
                self.previousNumber = previousNumber * currentNumber
            case Operators.Subtract.rawValue:
                self.previousNumber = previousNumber - currentNumber
            case Operators.Add.rawValue:
                self.previousNumber = previousNumber + currentNumber
            default:
                break
            }
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


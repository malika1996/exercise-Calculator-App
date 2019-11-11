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
    @IBOutlet private var btnOperations: [CustomButton]!
    
    // MARK: Class properties
    private var currentNumber: Double?
    private var previousNumber: Double?
    private var calculationsOn = false
    private var operationTag = 0
    private var equalToOperationFinished = false
    private var numOfDigitsSoFar = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let text = self.label.text else {return}
        guard let number = Double(text) else {return}
        
        if UIApplication.shared.statusBarOrientation == .portrait {
            if text.count > 8 {
                self.displayResultInScientificNotationFor(number: number)
            }
        } else {
            self.label.text = "\(Double(number))".removeExtraZeroAfterPoint()
        }
    }

    // MARK: IBActions
    @IBAction private func numberTapped(_ sender: CustomButton) {
        if self.equalToOperationFinished {
            self.checkForNewOrChainCalculation()
        }
        if calculationsOn {
            label.text = String(sender.tag-1)
            currentNumber = Double(label.text!)!
            for btn in self.btnOperations where btn.tag == self.operationTag {
                btn.backgroundColor = #colorLiteral(red: 0.7568627451, green: 0.5333333333, blue: 0.2078431373, alpha: 1)
                btn.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
            }
            calculationsOn = false
            self.numOfDigitsSoFar += 1
        }
        else { // Number preparation from digits
            if label.text == "0" {
                label.text = ""
            }
            self.restrictDigitsNum(tag: sender.tag)
            self.numOfDigitsSoFar += 1
            currentNumber = Double(label.text ?? "") ?? 0.0
        }
    }
    
    @IBAction private func btnOperationTapped(_ sender: CustomButton) {
        var previousOperationTag: Int?
        if self.calculationsOn {
            previousOperationTag = self.operationTag
        }
        if label.text != "" && sender.tag != Operators.Clear.rawValue && sender.tag != Operators.EqualTo.rawValue {
            self.computePreviousNumAndUpdateOperationOnLabel(tag: sender.tag)
        }
        else if sender.tag == Operators.EqualTo.rawValue {
            self.equalToOperatorTapped()
            self.numOfDigitsSoFar = 0
            return
        }
        else if sender.tag == Operators.Clear.rawValue {
            label.text = "0"
            previousNumber = nil
            currentNumber = nil
            operationTag = 0
        }
        self.numOfDigitsSoFar = 0
        sender.backgroundColor = .white
        sender.setTitleColor(#colorLiteral(red: 0.7568627451, green: 0.5333333333, blue: 0.2078431373, alpha: 1), for: .normal)
        guard let previousOpTag = previousOperationTag else {return}
        for btn in self.btnOperations where btn.tag == previousOpTag {
            btn.backgroundColor = #colorLiteral(red: 0.7568627451, green: 0.5333333333, blue: 0.2078431373, alpha: 1)
            btn.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        }
    }
    
    private func restrictDigitsNum(tag: Int) {
        guard let text = self.label.text else {return}
        if self.numOfDigitsSoFar <= 7 {
            if tag == Operators.Dot.rawValue {
                self.dotOperatorTapped(labelText: text)
            } else {
                label.text = text + String(tag-1)
            }
        }
    }
    
    private func checkForNewOrChainCalculation() {
        currentNumber = 0
        // Operation on previous result as first operand
        if !self.calculationsOn {//label.text != "÷" && label.text != "*" && label.text != "+" && label.text != "-" {
            self.operationTag = 0
            self.previousNumber = nil
        }
        self.equalToOperationFinished = false
        label.text = ""
    }
    
    private func equalToOperatorTapped() {
        
        if let secondOperand = self.currentNumber {
            switch self.operationTag {
            case Operators.Divide.rawValue:
                label.text = String(previousNumber! / secondOperand).removeExtraZeroAfterPoint()
            case Operators.Multiply.rawValue:
                label.text = String(previousNumber! * secondOperand).removeExtraZeroAfterPoint()
            case Operators.Subtract.rawValue:
                label.text = String(previousNumber! - secondOperand).removeExtraZeroAfterPoint()
            case Operators.Add.rawValue:
                label.text = String(previousNumber! + secondOperand).removeExtraZeroAfterPoint()
            default:
                break
            }
            // Result stored for chain calculations
            self.previousNumber = Double(label.text!) ?? 0.0
        } else { //incomplete state- both operands are not provided
            for btn in self.btnOperations where btn.tag == self.operationTag {
                btn.backgroundColor = #colorLiteral(red: 0.7568627451, green: 0.5333333333, blue: 0.2078431373, alpha: 1)
                btn.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
            }
            self.calculationsOn = false
        }
        self.currentNumber = nil
        self.equalToOperationFinished = true
    }
    
    private func computePreviousNumAndUpdateOperationOnLabel(tag: Int) {
        self.preparePreviousNumForChainCalculations()
        self.previousNumber = self.previousNumber == nil ? self.currentNumber : self.previousNumber
        guard let firstOperand = self.previousNumber else {return }
        switch tag {
        case Operators.Divide.rawValue:
            label.text = "\(firstOperand)".removeExtraZeroAfterPoint()
        case Operators.Multiply.rawValue:
            label.text = "\(firstOperand)".removeExtraZeroAfterPoint()
        case Operators.Subtract.rawValue:
            label.text = "\(firstOperand)".removeExtraZeroAfterPoint()
        case Operators.Add.rawValue:
            label.text = "\(firstOperand)".removeExtraZeroAfterPoint()
        default:
            print("")
        }
        operationTag = tag
        calculationsOn = true
        self.currentNumber = nil
    }
    
    private func  preparePreviousNumForChainCalculations() {
        
        // Prepare previousNum by computing previous chain result
        if self.previousNumber != nil && self.currentNumber != nil {
            switch self.operationTag {
            case Operators.Divide.rawValue:
                self.previousNumber = previousNumber! / currentNumber!
            case Operators.Multiply.rawValue:
                self.previousNumber = previousNumber! * currentNumber!
            case Operators.Subtract.rawValue:
                self.previousNumber = previousNumber! - currentNumber!
            case Operators.Add.rawValue:
                self.previousNumber = previousNumber! + currentNumber!
            default:
                break
            }
        }
        guard let text = self.label.text else {return}
        self.previousNumber = self.previousNumber ?? Double(text)
    }
    
    private func displayResultInScientificNotationFor(number: Double) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .scientific
        formatter.positiveFormat = "0.###E+0"
        formatter.exponentSymbol = "e"
        if let scientificFormatted = formatter.string(for: number) {
            self.label.text = scientificFormatted
            print(scientificFormatted)
        }
    }
    
    private func dotOperatorTapped(labelText: String) {
        // To have only one decimal in the number
        if !(labelText.contains(".")) {
            if self.label.text == "" {
                // To avoid Double(.) -> nil case
                self.label.text = "0."
            } else {
                self.label.text = labelText + "."
            }
        }
    }
}

class CustomButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height / 2.0
    }
    
    override func awakeFromNib() {
        self.clipsToBounds = true
        self.titleLabel!.font = self.titleLabel?.font.withSize(35)
    }
}

extension String {
    func removeExtraZeroAfterPoint() -> String {
        let decimalNumber = self.split(separator: ".")
        if !decimalNumber.isEmpty && decimalNumber.count == 2 {
            switch decimalNumber[1] {
            case "0", "00", "000", "0000", "00000", "000000":
                return String(decimalNumber[0])
            default:
                return self
            }
        }
        return self
    }
}


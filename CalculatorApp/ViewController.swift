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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.selectSameButtonOnOrientationChange()
        guard let resultString = self.label.text else {return}
        guard let number = Double(resultString) else {return}
        if UIDevice.current.orientation.isLandscape {
            self.label.text = "\(self.previousNumber ?? number)".removeExtraZeroAfterPoint()
        } else {
            label.text = self.setTextForPortraitMode(resultString: resultString).removeExtraZeroAfterPoint()
        }
    }

    // MARK: IBActions
    @IBAction private func numberTapped(_ sender: CustomButton) {
        let digit = sender.tag - 1
        if self.calculationsOn {
            self.prepareFirstDigitOfSecondOperand(tag: sender.tag, digit: digit)
        } else {
            self.prepareNumber(tag: sender.tag, digit: digit)
        }
        equalToOperationFinished = false
    }
    
    @IBAction private func btnOperationTapped(_ sender: CustomButton) {
        if sender.tag == Operators.Clear.rawValue {
            self.clearOperation()
        } else if sender.tag == Operators.EqualTo.rawValue {
            self.equalToOperation()
        } else { // +,-,/,* operations
            sender.backgroundColor = .white
            sender.setTitleColor(#colorLiteral(red: 0.7568627451, green: 0.5333333333, blue: 0.2078431373, alpha: 1), for: .normal)
            if sender.tag != operationTag {
                self.setButtonDefaultColor()
            }
            previousNumber = previousNumber != nil ? computePreviousNumForChainCalculations() : currentNumber
            operationTag = sender.tag
            calculationsOn = true
        }
        currentNumber = nil
        var resultString = "\(previousNumber ?? 0)".removeExtraZeroAfterPoint()
        if UIApplication.shared.statusBarOrientation.isPortrait {
            resultString = self.setTextForPortraitMode(resultString: resultString)
        }
        label.text = "\(resultString)".removeExtraZeroAfterPoint()
    }
    
    private func  computePreviousNumForChainCalculations() -> Double {
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
                previousNumber = currentNumber!
            }
        }
        return previousNumber!
    }
    
    private func displayResultInScientificNotationFor(number: Double) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .scientific
        formatter.positiveFormat = "0.#####E+0"
        formatter.exponentSymbol = "e"
        if let scientificFormatted = formatter.string(for: number) {
            return scientificFormatted
        }
        return nil
    }
    
    private func dotOperatorTapped() {
        guard let text = self.label.text else {return}
        // To have only one decimal in the number
        if !(text.contains(".")) {
            if text == "" {
                // To avoid Double(.) -> nil case
                self.label.text = "0."
            } else {
                self.label.text = text + "."
            }
        }
    }
    
    private func removeExtraDigitsAfterPointForPortraitMode(resultString: String) -> String {
        guard let stringIndex = resultString.firstIndex(of: ".") else {return ""}
        var resultString = resultString
        let index = resultString.distance(from: resultString.startIndex, to: stringIndex)
        if index >= 7 {
            resultString = (displayResultInScientificNotationFor(number: (previousNumber ?? 0))) ?? ""
        } else {
            resultString = String(resultString.prefix(8))
        }
        return resultString
    }
    
    private func setTextForPortraitMode(resultString: String) -> String {
        var resultString = resultString
        if resultString.count > 8 {
            if resultString.contains(".") {
                resultString = self.removeExtraDigitsAfterPointForPortraitMode(resultString: resultString)
            } else {
                resultString = (displayResultInScientificNotationFor(number: (previousNumber ?? 0))) ?? ""
            }
        }
        return resultString
    }
    
    private func setButtonDefaultColor() {
        for btn in self.btnOperations where btn.tag == self.operationTag {
            btn.backgroundColor = #colorLiteral(red: 0.7568627451, green: 0.5333333333, blue: 0.2078431373, alpha: 1)
            btn.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        }
    }
    
    private func selectSameButtonOnOrientationChange() {
        for btn in self.btnOperations where btn.tag == self.operationTag {
            btn.backgroundColor = .white
            btn.setTitleColor(#colorLiteral(red: 0.7568627451, green: 0.5333333333, blue: 0.2078431373, alpha: 1), for: .normal)
        }
    }
    
    private func equalToOperation() {
        previousNumber = previousNumber != nil ? computePreviousNumForChainCalculations() : currentNumber
        self.setButtonDefaultColor()
        operationTag = 0
        equalToOperationFinished = true
    }
    
    private func clearOperation() {
        self.setButtonDefaultColor()
        operationTag = 0
        currentNumber = nil
        previousNumber = nil
    }
    
    private func prepareFirstDigitOfSecondOperand(tag: Int, digit: Int) {
        if tag == Operators.Dot.rawValue {
            label.text = "0."
        } else {
            label.text =  "\(digit)"
        }
        calculationsOn = false
        currentNumber = Double(label.text ?? "") ?? 0.0
        self.setButtonDefaultColor()
    }
    
    private func prepareNumber(tag: Int, digit: Int) {
        if label.text == "0" { //Remove unneccessary zero at start
            label.text = ""
        }
        guard let text = self.label.text else {return}
        if text.count <= 7 || equalToOperationFinished {
            if tag == Operators.Dot.rawValue {
                label.text = equalToOperationFinished ? "0." : label.text!
                dotOperatorTapped()
            } else {
                label.text = equalToOperationFinished ? "\(digit)" : (label.text! + "\(digit)")
            }
            currentNumber = Double(label.text ?? "") ?? 0.0
        }
    }
}

class CustomButton: UIButton {
    override func awakeFromNib() {
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.height / 2.0
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


//
//  ViewController.swift
//  Calculator2.0
//
//  Created by FRANZETTI-LAPTOP on 27/11/17.
//  Copyright © 2017 FRANZETTI-LAPTOP. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var operandSequence: UILabel!

    var userIsInTheMiddleOfTyping = false
    
    // Action executed in case of digit button press
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            if !(digit == "." && textCurrentlyInDisplay.contains(".")) {
                display.text = textCurrentlyInDisplay + digit
            }
        } else {
            display.text = (digit == ".") ? "0." : digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    // computed-value variable
    var  displayValue: Double {
        set {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.usesGroupingSeparator = false
            //numberFormatter.maximumFractionDigits = Constants.numberOfDigitsAfterDecimalPoint
            numberFormatter.maximumFractionDigits = 6
            display.text = numberFormatter.string(from: NSNumber(value: newValue))
        }
        get {
            return Double(display.text!)!
        }
    }

    //link to the MODEL
    private var brain = CalculatorBrain()

    // Action executed in case of operation button pressed
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        if let result = brain.result {
            displayValue = result
        }
        if let description = brain.description {
            operandSequence.text = description + (brain.resutIsPending ? " …" : " =")
        }
    }
    
    
    @IBAction func clear(_ sender: UIButton) {
        brain = CalculatorBrain()
        operandSequence.text = " "
        displayValue = 0
    }
    
    
    
}


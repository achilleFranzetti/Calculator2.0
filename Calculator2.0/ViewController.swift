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
    var userIsInTheMiddleOfTyping = false
    
    @IBOutlet weak var operandSequence: UILabel!
    
    
    //link to the MODEL
    private var brain = CalculatorBrain()
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        let textCurrentlyInDisplay = display.text!
        let pressedPoint = textCurrentlyInDisplay.contains(".")
        
        
        operandSequence.text = "resultIsPending = \(brain.resutIsPending)"
        
        // User press "0" multiple times
        if (textCurrentlyInDisplay == "0" && digit == "0") {
            display.text = "0"
            userIsInTheMiddleOfTyping = false
        } else {
            if userIsInTheMiddleOfTyping {
                if !(pressedPoint && digit == ".") {
                    display.text = textCurrentlyInDisplay + digit
                }
            } else {
                userIsInTheMiddleOfTyping = true
                if digit == "." {
                    display.text = "0."
                }  else {
                    display.text =  digit
                }
            }
        }
    }
    
    // computed-value variable
    var  displayValue: Double {
        set {
            // Display "0" instead of "0.0"
            display.text = newValue == 0.0 ? "0" : String(newValue)
        }
        get {
            return Double(display.text!)!
        }
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        
                operandSequence.text = "resultIsPending = \(brain.resutIsPending)"
        
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
    }
}


//
//  CalculatorBrain.swift
//  Calculator2.0
//
//  Created by FRANZETTI-LAPTOP on 28/11/17.
//  Copyright © 2017 FRANZETTI-LAPTOP. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    // Numeric and text accumulator, to store operation result and string
    private var accumulator: Double?
    private var accumulatorText: String?
    
    private enum Operation {
        case constant(Double, String)
        case nullOperation(() -> Double, () -> String)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case equals
    }
    
    // This dictionary contains the list of all operations permitted on the calculator
    // together with their string representation
    private var operations: Dictionary<String,Operation> = [
        "𝛑":   Operation.constant(Double.pi, "𝛑"),
        "e":   Operation.constant(M_E,       "e"),
        "rnd": Operation.nullOperation({drand48()}, {"rnd"}),
        "1/x": Operation.unaryOperation({1/$0},     {"(\($0))⁻¹"}),
        "√":   Operation.unaryOperation(sqrt,       {"√(\($0))"}),
        "cos": Operation.unaryOperation(cos,        {"cos(\($0))"}),
        "sin": Operation.unaryOperation(sin,        {"sin(\($0))"}),
        "x³":  Operation.unaryOperation({$0*$0*$0}, {"(\($0))³"}),
        "tan": Operation.unaryOperation(tan,        {"tan(\($0))"}),
        "ln":  Operation.unaryOperation(log2,       {"log(\($0))"}),
        "±":   Operation.unaryOperation({-$0},      {"-\($0)"}),
        "x²":  Operation.unaryOperation({$0 * $0},  {"(\($0))²"}),
        "+":   Operation.binaryOperation({$0 + $1}, {"\($0) + \($1)"}),
        "-":   Operation.binaryOperation({$0 - $1}, {"\($0) - \($1)"}),
        "×":   Operation.binaryOperation({$0 * $1}, {"\($0) × \($1)"}),
        "÷":   Operation.binaryOperation({$0 / $1}, {"\($0) ÷ \($1)"}),
        "=":   Operation.equals
    ]
    
    // This function is called any time an operation must be performed
    // It updates both the accumulator and the string sequence
    mutating func performOperation(_ symbol: String){
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value, let text):
                accumulator = value
                accumulatorText = text
            case .nullOperation(let function, let textFunction):
                accumulator = function()
                accumulatorText = textFunction()
            case .unaryOperation(let function, let textFunction):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                    accumulatorText = textFunction(accumulatorText!)
                }
            case .binaryOperation(let function, let textFunction):
                performPendingBinaryOperation()
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: function,
                                                                    firstOperand: accumulator!,
                                                                    descriptionFunction: textFunction,
                                                                    descriptionOperand: accumulatorText!)
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            accumulatorText = pendingBinaryOperation!.buildDescription(with: accumulatorText!)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation{
        let function: (Double, Double) -> Double
        let firstOperand: Double
        let descriptionFunction: (String, String) -> String
        let descriptionOperand: String
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
        
        func buildDescription(with secondOperand: String) -> String {
            return descriptionFunction(descriptionOperand, secondOperand)
        }
    }
    
    // This function is called any time a new operand must be memorized into the calculator brain
    mutating func setOperand(_ operand: Double){
        accumulator = operand
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.usesGroupingSeparator = false
        numberFormatter.maximumFractionDigits = Constants.numberOfDigitsAfterDecimalPoint
        accumulatorText = numberFormatter.string(from: NSNumber(value: operand))!
    }
    
    // Calculated value
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    // Calculated value
    var resutIsPending: Bool {
        get {
            return pendingBinaryOperation != nil
        }
    }
    
    // Operation string sequence description (read only)
    var description: String? {
        get {
            if pendingBinaryOperation != nil {
                return pendingBinaryOperation!.descriptionFunction(pendingBinaryOperation!.descriptionOperand,
                                                                   /*accumulatorText ??*/ "")
            } else {
                return accumulatorText
            }
        }
    }
}



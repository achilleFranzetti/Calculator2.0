//
//  CalculatorBrain.swift
//  Calculator2.0
//
//  Created by FRANZETTI-LAPTOP on 28/11/17.
//  Copyright © 2017 FRANZETTI-LAPTOP. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    // Numeric and text accumulator, to store operation result
    private var accumulator: Double?
    private var accumulatorText: String?
    
    private enum Operation {
        case constant(Double, String)
        case nullOperation(() -> Double, () -> String)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case equals
        //case clear
    }
    
    private var operations: Dictionary<String,Operation> = [
        //"AC":  Operation.clear,
        "𝛑":   Operation.constant(Double.pi, "𝛑"),
        "e":   Operation.constant(M_E, "e"),
        "Rand": Operation.nullOperation({drand48()}, {"Rand"}),
        "1/x": Operation.unaryOperation({1/$0}, {"(\($0))⁻¹"}),
        "√":   Operation.unaryOperation(sqrt,  {"√(\($0))"}),
        "cos": Operation.unaryOperation(cos,   {"cos(\($0))"}),
        "sin": Operation.unaryOperation(sin,   {"sin(\($0))"}),
        "tan": Operation.unaryOperation(tan,   {"tan(\($0))"}),
        "ln":  Operation.unaryOperation(log2,  {"log(\($0))"}),
        "±":   Operation.unaryOperation({-$0}, {"-\($0)"}),
        "+":   Operation.binaryOperation({$0 + $1}, {"\($0) + \($1)"}),
        "-":   Operation.binaryOperation({$0 - $1}, {"\($0) - \($1)"}),
        "×":   Operation.binaryOperation({$0 * $1}, {"\($0) × \($1)"}),
        "÷":   Operation.binaryOperation({$0 / $1}, {"\($0) ÷ \($1)"}),
        "=":   Operation.equals
    ]
    
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

                
                /*
                 case .clear:
                 accumulator = 0
                 accumulatorText = " "
                 pendingBinaryOperation = nil
                 */
                
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
    
    mutating func setOperand(_ operand: Double){
        accumulator = operand
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.usesGroupingSeparator = false
        //numberFormatter.maximumFractionDigits = Constants.numberOfDigitsAfterDecimalPoint
        numberFormatter.maximumFractionDigits = 6
        accumulatorText = numberFormatter.string(from: NSNumber(value: operand))!
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    var resutIsPending: Bool {
        get {
            return pendingBinaryOperation != nil
        }
    }
    
    // Operation string sequence description
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

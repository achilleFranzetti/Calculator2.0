//
//  CalculatorBrain.swift
//  Calculator2.0
//
//  Created by FRANZETTI-LAPTOP on 28/11/17.
//  Copyright © 2017 FRANZETTI-LAPTOP. All rights reserved.
//

import Foundation

// This function calculates factorial of a Natural number
private func factorial(factorialNumber: UInt) -> UInt {
    if factorialNumber == 0 {
        return 1
    } else {
        return factorialNumber * factorial(factorialNumber: factorialNumber - 1)
    }
}

//This function is a wrapper for the factorial() function
private func fattor(argument: Double) -> Double {
    let x = UInt(trunc(abs(argument)))
    return Double(factorial(factorialNumber: x))
}

struct CalculatorBrain {
    
    private var accumulator: Double?
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case noParameterOperation(() -> Double)
        case equals
    }
    
    private var operations = [
        "1/x": Operation.unaryOperation({1/$0}),
        "𝛑": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "rnd": Operation.noParameterOperation(drand48),
        "AC": Operation.constant(0),
        "√": Operation.unaryOperation(sqrt),
        "cos": Operation.unaryOperation(cos),
        "sin": Operation.unaryOperation(sin),
        "tan": Operation.unaryOperation(tan),
        "ln": Operation.unaryOperation(log2),
        "x!": Operation.unaryOperation(fattor),
        "±": Operation.unaryOperation({-$0}),
        "+": Operation.binaryOperation({$0+$1}),
        "-": Operation.binaryOperation({$0-$1}),
        "×": Operation.binaryOperation({$0*$1}),
        "÷": Operation.binaryOperation({$0/$1}),
        "=": Operation.equals
    ]
    
    mutating func performOperation(_ symbol: String){
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
            case .unaryOperation(let function):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                }
            case .binaryOperation(let function):
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                }
            case .equals:
                performPendingBinaryOperation()
            case .noParameterOperation(let function):
                accumulator = function()
            
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    var resutIsPending: Bool {
        get {
            if pendingBinaryOperation != nil { return true }
            else { return false}
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation{
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    
    
    mutating func setOperand(_ operand: Double){
        accumulator = operand
    }
    
    var result: Double? {
        get {
         return accumulator
        }
    }
}

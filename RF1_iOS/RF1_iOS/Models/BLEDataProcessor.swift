//
//  BLEDataProcessor.swift
//  RF1_iOS
//
//  Created by Keegan Jebb on 2018-03-27.
//  Copyright © 2018 Keegan Jebb. All rights reserved.
//

import Foundation

protocol BLEDataProcessorDelegate {
    func didTakeStep()
}


class BLEDataProcessor {
    
    private var fsrDataArray = [Int16]()
    
    private var processorDelegate: BLEDataProcessorDelegate?
    
    var forefootVoltage: Int = 0
    
    var heelVoltage: Int = 0
    
    private var newForefootDown: Bool = false
    private var oldForefootDown: Bool = false
    
    private var newHeelDown: Bool = false
    private var oldHeelDown: Bool = false
    
    init(delegate: BLEDataProcessorDelegate) {
        
        processorDelegate = delegate
        initializeFsrDataArray()
    }
    
    private func initializeFsrDataArray() {
        
        for _ in 0..<PeripheralDevice.numberOfSensors {
            fsrDataArray.append(0)
        }
    }
    
    
    func processNewData(updatedData data: Data) {
        
        saveFsrData(dataToBeSaved: data)
        
        newForefootDown = forefootVoltage > 2500 ? true : false

        newHeelDown = heelVoltage > 2500 ? true : false
        
        if (oldForefootDown || oldHeelDown) && (!newForefootDown && !newHeelDown) {
            processorDelegate?.didTakeStep()
        }
        
        oldForefootDown = newForefootDown
        oldHeelDown = newHeelDown
    }
    
    
    private func saveFsrData(dataToBeSaved data: Data) {
        
        //1. Get a pointer (ptr) to the data value (size of Int16) in the Data buffer
        //2. Advance the pointer if necessary
        //3. Put the value ptr points to into the appropriate index of fsrDataArray
        for i in 0...(fsrDataArray.count - 1) {
            fsrDataArray[i] = data.withUnsafeBytes { (ptr: UnsafePointer<Int16>) in
                ptr.advanced(by: i).pointee
            }
        }
        
        forefootVoltage = Int(fsrDataArray[0])
        heelVoltage = Int(fsrDataArray[1])
    }
    
    
}

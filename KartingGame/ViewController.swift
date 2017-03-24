//
//  ViewController.swift
//  KartingGame
//
//  Created by Yuhsuan on 24/03/2017.
//  Copyright © 2017 cgua. All rights reserved.
//

import UIKit
import CoreBluetooth
import HBFramework

class ViewController: UIViewController {
    
    @IBOutlet var label: UILabel!
    
    @IBAction func selectDevice( _ sender: Any) {
        
        
    }
    
    var _address = ""
    
    var _ble_central: HBCentral!
    
    var _ble: HBPeripheral!
    
    var _write_data: String?
    
    var _can_communicate: Bool = false
    
    var _ready_to_connect: [HBPeripheral] = []
    
    var _timer: Timer?
    
    var _connect_peripheral: HBPeripheral?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.label.layer.cornerRadius = 15.0
        
        self.label.clipsToBounds = true
        
        self.label.layer.borderWidth = 2
        
        self.label.layer.borderColor = UIColor(red: 255.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: HBCentralDelegate {
    
    func readyToScan() {
        
        _ble_central.scan()
        
    }
    
    func readyForConnect(peripheral: CBPeripheral, willAutoConnect will_auto_connect: Bool) {
        
        if will_auto_connect {
            
            return
            
        }
        
        _ready_to_connect.append(HBPeripheral(peripheral: peripheral, delegate: self))
        
    }
    
    func connected(peripheral: CBPeripheral) {
        
        _ble = HBPeripheral(peripheral: peripheral, delegate: self)
        
        _ble.setCommunicateCharacteristic(service: CBUUID(string: "FFE0"), characteristic: CBUUID(string: "FFE1"))
        
        //label.text = "已連接上\(_connect_peripheral!.peripheral.name!)"
        
    }
    
    func scanningTimeOut(peripherals: Set<String>) {
        
        if peripherals.contains(_address) {
            
            let alert = UIAlertController(title: _address, message: NSLocalizedString("連線逾時", comment: "time out"), preferredStyle: .alert)
            
            let rescan = UIAlertAction(title: NSLocalizedString("重新連線", comment: "reconnect") , style: .default) { _ in
                
                self._ble_central.scan()
                
            }
            
            let cancel_action = UIAlertAction(title: NSLocalizedString("取消", comment: "cancel"), style: .cancel) { _ in
                
                self._address = ""
                
            }
            
            alert.addAction(rescan)
            
            alert.addAction(cancel_action)
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
}

extension ViewController: HBPeripheralDelegate {
    
    func readyForCommunicate(peripheral: HBPeripheral) {
        
        _can_communicate = true
        
        print("readyForCommunicate")
        
    }
    
    func receive(peripheral: HBPeripheral, data: Data?, fromCharacteristic characteristic: CBCharacteristic) {
        
        print("data")
        
    }
    
}


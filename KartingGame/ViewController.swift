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

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var label: UILabel!
    
    @IBOutlet var btn_connect: UIButton!
    
    @IBAction func selectDevice( _ sender: Any) {
        
        showPickerView()
        
    }
    
    var _address = ""
    
    var _ble_central: HBCentral!
    
    var _ble: HBPeripheral!
    
    var _write_data: String?
    
    var _can_communicate: Bool = false
    
    var _ready_to_connect: [HBPeripheral] = []
    
    var _connect_peripheral: HBPeripheral?
    
    var toolBar = UIToolbar()
    
    var myPickerView = UIPickerView()
    
    var full_size: CGSize!
    
    var my_uiview: UIView!
    
    var knob_view: UIView!
    
    var circle_uiview: UIView!
    
    var center_of_circle: CGPoint! //圓心座標
    
    var radius: CGFloat = 0 //半徑
    
    var last_data = "無"

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.label.layer.cornerRadius = 15.0
        
        self.label.clipsToBounds = true
        
        self.label.layer.borderWidth = 2
        
        self.label.layer.borderColor = UIColor(red: 255.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
        
        self.btn_connect.layer.cornerRadius = 15.0
        
        self.btn_connect.clipsToBounds = true
        
        _ble_central = HBCentral(delegate: self , timeOutInterval: TimeInterval(5.0), autoConnect: false)
        
        //showKnob()
        
    }
    
    func showKnob() {
        
        // 方向搖桿
        
        full_size = UIScreen.main.bounds.size
        
        circle_uiview = UIView(frame: CGRect(x: 25, y: full_size.height / 2, width: full_size.width - 50, height: full_size.width - 50))
        
        circle_uiview.backgroundColor = UIColor.darkGray
        
        circle_uiview.layer.cornerRadius = circle_uiview.frame.size.width/2
        
        circle_uiview.clipsToBounds = true
        
        radius = (full_size.width - 50) / 2
        
        print("半徑: \(radius)")
        
        center_of_circle = CGPoint(x: 25 + radius, y: (full_size.height / 2) + radius)
        
        print("圓心： \(center_of_circle.x) ,\(center_of_circle.y)")
        
        self.view.addSubview(circle_uiview)
        
        knob_view = UIView(frame: CGRect(x: center_of_circle.x, y: center_of_circle.y, width: 100, height: 100))
        
        knob_view.backgroundColor = UIColor.red
        
        knob_view.layer.cornerRadius = knob_view.frame.size.width/2
        
        circle_uiview.clipsToBounds = true
        
        self.view.addSubview(knob_view)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(ViewController.pan))
        
        pan.minimumNumberOfTouches = 1
        
        pan.maximumNumberOfTouches = 1
        
        knob_view.addGestureRecognizer(pan)
        
    }
    
    func pan(recognizer: UIPanGestureRecognizer){
        
        let current_position = recognizer.location(in: self.view)
        
        print(current_position)
        
        let distance = distanceBetweenPoints(p1: center_of_circle, p2: current_position)
        
        print("距離為：\(distance)")
        
        //當手指距離已超出範圍，就不在更新搖桿畫面
        
        if distance <= radius {
            
            print("手指距離在範圍內")
            
            knob_view.center = current_position
            
        }
        else {
            
            print("手指距離不在範圍內")
            
            let vector = String(format: "%.3f",( radius / distance))
            
            print("向量： \(vector)")
            
            let x = ((current_position.x - center_of_circle.x) * CGFloat(NumberFormatter().number(from: vector)!)) + center_of_circle.x
            
            let y = ((current_position.y - center_of_circle.y) * CGFloat(NumberFormatter().number(from: vector)!)) + center_of_circle.y
            
            print("在圓上的 x 座標： \(x), \(y)")
            
            knob_view.center.x = x
            
            knob_view.center.y = y
            
        }
        
        if recognizer.state == UIGestureRecognizerState.ended {
            
            knob_view.center = center_of_circle
            
            _write_data = "0"
            
            _ble.write(data: _write_data!.data(using: .utf8)!)
            
        }
        
        let _angle = angle(point: current_position)
        
        print("角度為：\(angle(point: current_position))")
        
        var write_date = ""
        
        switch _angle {
            
        case 135...180, (-180)..<(-135) :
            
            write_date = "前進"
            
            _write_data = "1"
            
            //_ble.write(data: _write_data!.data(using: .utf8)!)
            
        case 46..<136 :
            
            write_date = "右"
            
            _write_data = "3"
            
            //_ble.write(data: _write_data!.data(using: .utf8)!)
            
        case (-45)..<46 :
            
            write_date = "後退"
            
            _write_data = "2"
            
            //_ble.write(data: _write_data!.data(using: .utf8)!)
            
        case (-135)...(-46) :
            
            write_date = "左"
            
            _write_data = "4"
            
            //_ble.write(data: _write_data!.data(using: .utf8)!)
            
        default :
            
            print("此角度不在範圍")
            
        }
        
        if last_data != write_date {
            
            print("改變方向 ------------------------ ")
            
            print("-->\(write_date)")
            
            _ble.write(data: _write_data!.data(using: .utf8)!)
            
        }
        
        last_data = write_date
        
    }

    func showPickerView() {
        
        let fullScreenSize = UIScreen.main.bounds.size
        
        myPickerView = UIPickerView(frame: CGRect(x: 0, y: fullScreenSize.height * 0.7, width: fullScreenSize.width, height: 150))
        
        myPickerView.dataSource = self
        
        myPickerView.delegate = self
        
        self.view.addSubview(myPickerView)
        
        toolBar = UIToolbar(frame: CGRect(x: 0, y: fullScreenSize.height * 0.7 - 50, width: fullScreenSize.width, height: 50))
        
        toolBar.barStyle = UIBarStyle.default
        
        toolBar.isTranslucent = true
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil);
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.hidePickerView))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        
        self.view.addSubview(toolBar)
        
    }
    
    func hidePickerView() {
        
        self.view.endEditing(true)
        
        self.myPickerView.isHidden = true
        
        self.toolBar.isHidden = true
        
        if _connect_peripheral == nil {
            
            let alert = UIAlertController(title: "請選擇欲連接藍芽", message: nil, preferredStyle: .alert)
            
            let alert_btn = UIAlertAction(title: "關閉", style: .default) { _ in
                
                self.showPickerView()
                
            }
            
            alert.addAction(alert_btn)
            
            OperationQueue.main.addOperation {
                
                self.present(alert, animated: true, completion: nil)
                
            }
            
            return
            
        }
        
        _ble_central.connect(peripheral: _connect_peripheral!.peripheral)
        
    }
    
    //計算距離
    
    func distanceBetweenPoints(p1: CGPoint, p2: CGPoint) -> CGFloat {
        
        let dx = p1.x - p2.x
        
        let dy = p1.y - p2.y
        
        return sqrt((dx * dx) + (dy * dy))
        
    }
    
    let p1 = CGPoint(x: 10, y: 10)
    
    let p2 = CGPoint(x: 10, y: 5)
    
    override func viewDidAppear(_ animated: Bool) {
        
        print(distanceBetweenPoints(p1: p1, p2: p2))
        
    }
    
    //算角度
    
    func angle(point: CGPoint) -> CGFloat {
        
        let originX = center_of_circle.x
        
        let originY = center_of_circle.y
        
        let a = point.x - originX
        
        let b = point.y - originY
        
        let atanA = atan2(a,b)
        
        return (atanA) * 180 / CGFloat(M_PI)
        
    }
    
    //MARK: - PickerView setting
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return _ready_to_connect.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return _ready_to_connect[row].peripheral.name!
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        _connect_peripheral = _ready_to_connect[row]
        
    }

}

//MARK: - extension

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
        
        label.text = "已連接上\(_connect_peripheral!.peripheral.name!)"
        
        self.label.layer.borderColor = UIColor(red: 0.0, green: 128.0, blue: 0.0, alpha: 1.0).cgColor
        
        self.label.textColor = UIColor(red: 0.0, green: 128.0, blue: 0.0, alpha: 1.0)
        
        showKnob()
        
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


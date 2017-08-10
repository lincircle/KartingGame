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
    
    //TODO: 連結按鈕改變位置, 按下斷線時，可以讓裝置斷線
    
    @IBAction func selectDevice( _ sender: Any) {
        
        if !is_connected {
            
            showPickerView()
            
        }
        else {
            /*
            if let _ = self.knob_view {
                
                self.knob_view = nil
                
            }
            
            if let _ = self.circle_uiview {
                
                self.circle_uiview = nil
                
            }
            */
            _ble_central.disconnect(peripheral: _ble.peripheral)
            
            is_connected = false
            
            label.text = "未連結任何裝置"
            
            self.label.layer.borderColor = UIColor(red: 255.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
            
            self.label.textColor = UIColor(red: 255.0, green: 0.0, blue: 0.0, alpha: 1.0)
            
            self.knob_view!.isHidden = true
            
            self.circle_uiview!.isHidden = true
            
            self.btn_connect.setTitle("連線裝置", for: .normal)
            
            print("已斷線")
            
        }
        
    }
    
    @IBAction func goSetting(_ sender: Any) {
        
        self.performSegue(withIdentifier: "toSetting", sender: nil)
        
    }
    
    var _address = ""
    
    var _ble_central: HBCentral!
    
    var _ble: HBPeripheral!
    
    var _write_data: String? = "-1"
    
    var _can_communicate: Bool = false
    
    var _ready_to_connect: [HBPeripheral] = []
    
    var _connect_peripheral: HBPeripheral?
    
    var toolBar = UIToolbar()
    
    var myPickerView = UIPickerView()
    
    let shopPicker = UIPickerView()
    
    var full_size: CGSize!
    
    var knob_view: UIView?
    
    var circle_uiview: UIView?
    
    var center_of_circle: CGPoint! //圓心座標
    
    var radius: CGFloat = 0 //半徑
    
    var last_data = "無"
    
    var tmp_last_data = "-1"
    
    var is_connected: Bool = false
    
    var hide: Bool = false
    
    private var _timer: Timer?

    //開啟App
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.label.layer.cornerRadius = 15.0
        
        self.label.clipsToBounds = true
        
        self.label.layer.borderWidth = 2
        
        self.label.layer.borderColor = UIColor(red: 255.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
        
        self.btn_connect.layer.cornerRadius = 15.0
        
        self.btn_connect.clipsToBounds = true
        
        _ble_central = HBCentral(delegate: self , timeOutInterval: TimeInterval(5.0), autoConnect: false)
        
        // 增加一個觸控事件
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.hideKeyboard(tapG:)))
        
        tap.cancelsTouchesInView = false
        
        // 加在最基底的 self.view 上
        self.view.addGestureRecognizer(tap)
        
        /*
        let button: UIButton = UIButton.buttonWithType(UIButtonType.custom) as! UIButton
        
        button.setImage(UIImage(named: "fb.png"), for: .normal)
        
        button.addTarget(self, action: "fbButtonPressed", for: UIControlEvents.touchUpInside)
        //set frame
        button.frame = CG CGRectMake(0, 0, 53, 31)
        
        let barButton = UIBarButtonItem(customView: button)
        //assign button to navigationbar
        self.navigationItem.rightBarButtonItem = barButton
        */
    }
    
    func showKnob() {
        
        // 畫面顯示方向搖桿
        
        full_size = UIScreen.main.bounds.size
        
        circle_uiview = UIView(frame: CGRect(x: 25, y: full_size.height / 2, width: full_size.width - 50, height: full_size.width - 50))
        
        circle_uiview!.backgroundColor = UIColor.darkGray
        
        circle_uiview!.layer.cornerRadius = circle_uiview!.frame.size.width/2
        
        circle_uiview!.clipsToBounds = true
        
        radius = (full_size.width - 50) / 2
        
        print("半徑: \(radius)")
        
        center_of_circle = CGPoint(x: 25 + radius, y: (full_size.height / 2) + radius)
        
        print("圓心： \(center_of_circle.x) ,\(center_of_circle.y)")
        
        self.view.addSubview(circle_uiview!)
        
        knob_view = UIView(frame: CGRect(x: center_of_circle.x, y: center_of_circle.y, width: 100, height: 100))
        
        knob_view!.backgroundColor = UIColor.red
        
        knob_view!.layer.cornerRadius = knob_view!.frame.size.width/2
        
        knob_view!.center = CGPoint(x: center_of_circle.x, y:center_of_circle.y)
        
        circle_uiview!.clipsToBounds = true
        
        self.view.addSubview(knob_view!)
        
        //設定手勢
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(ViewController.pan))
        
        pan.minimumNumberOfTouches = 1
        
        pan.maximumNumberOfTouches = 1
        
        knob_view!.addGestureRecognizer(pan)
        
    }
    
    func pan(recognizer: UIPanGestureRecognizer){
        
        let current_position = recognizer.location(in: self.view)
        
        print(current_position)
        
        let distance = distanceBetweenPoints(p1: center_of_circle, p2: current_position)
        
        //print("距離為：\(distance)")
        
        //當手指距離已超出範圍，就不在更新搖桿畫面
        
        if distance <= radius {
            
            //print("手指距離在範圍內")
            
            knob_view!.center = current_position
            
        }
        else {
            
            print("手指距離不在範圍內")
            
            let vector = String(format: "%.3f",( radius / distance))
            
            //print("向量： \(vector)")
            
            let x = ((current_position.x - center_of_circle.x) * CGFloat(NumberFormatter().number(from: vector)!)) + center_of_circle.x
            
            let y = ((current_position.y - center_of_circle.y) * CGFloat(NumberFormatter().number(from: vector)!)) + center_of_circle.y
            
            //print("在圓上的 x 座標： \(x), \(y)")
            
            knob_view!.center.x = x
            
            knob_view!.center.y = y
            
        }
        
        if recognizer.state == UIGestureRecognizerState.ended {
            
            knob_view!.center = center_of_circle
            
            _write_data = "0"
            
            tmp_last_data = "0"
            
            print("停止")
            
            _ble.write(data: _write_data!.data(using: .utf8)!)
            
            return
            
        }
        
        let _angle = angle(point: current_position)
        
        print("角度為：\(angle(point: current_position))")
        
        switch _angle {
            
        case 135...180, (-180)..<(-135) :
            
            print("前進")
            
            _write_data = "1"
            
        case 46..<136 :
            
            print("右")
            
            _write_data = "3"
            
        case (-45)..<46 :
            
            print("後退")
            
            _write_data = "2"
            
        case (-135)...(-46) :
            
            print("左")
            
            _write_data = "4"
            
        default :
            
            print("此角度不在範圍")
            
        }
        
        if tmp_last_data != _write_data {
            
            _ble.write(data: _write_data!.data(using: .utf8)!)
            
            tmp_last_data = _write_data!
            
            print("tmp_last_data = \(tmp_last_data)")
            
            print("_write_data = \(_write_data!)")
            
            print("有更換")
            
        }
        
    }

    func showPickerView() {
        
        print("showPickerView")
        
        if hide == true {
            
            print("preHide=",hide)
            
            self.myPickerView.isHidden = false
            
            let fullScreenSize = UIScreen.main.bounds.size
            
            myPickerView.frame = CGRect(x: 0, y: fullScreenSize.height * 0.7, width: fullScreenSize.width, height: 150)
            
            myPickerView.dataSource = self
            
            myPickerView.delegate = self
            
            myPickerView.backgroundColor = UIColor.white
            
            myPickerView.selectRow(0, inComponent: 0, animated: true)
            
            //myPickerView.showsSelectionIndicator = true
            
            self.view.addSubview(myPickerView)
            
            toolBar = UIToolbar(frame: CGRect(x: 0, y: fullScreenSize.height * 0.7 - 50, width: fullScreenSize.width, height: 40))
            
            toolBar.barStyle = UIBarStyle.default
            
            toolBar.isTranslucent = true
            
            //        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil);
            
            let doneButton = UIBarButtonItem(title: "完成", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.hidePickerView))
            
            let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            
            let cancelButton = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelClick))
            
            toolBar.setItems([doneButton, spaceButton, cancelButton], animated: false)
            
            self.view.addSubview(toolBar)
            
            hide = false
            
        }else{
            
            let fullScreenSize = UIScreen.main.bounds.size
            
            myPickerView.frame = CGRect(x: 0, y: fullScreenSize.height * 0.7, width: fullScreenSize.width, height: 150)
            
            myPickerView.dataSource = self
            
            myPickerView.delegate = self
            
            myPickerView.backgroundColor = UIColor.white
            
            myPickerView.selectRow(0, inComponent: 0, animated: true)
            
            //myPickerView.showsSelectionIndicator = true
            
            self.view.addSubview(myPickerView)
            
            toolBar = UIToolbar(frame: CGRect(x: 0, y: fullScreenSize.height * 0.7 - 50, width: fullScreenSize.width, height: 40))
            
            toolBar.barStyle = UIBarStyle.default
            
            toolBar.isTranslucent = true
            
            //        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil);
            
            let doneButton = UIBarButtonItem(title: "完成", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.hidePickerView))
            
            let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            
            let cancelButton = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelClick))
            
            toolBar.setItems([doneButton, spaceButton, cancelButton], animated: false)
            
            self.view.addSubview(toolBar)

        }
        
        
        
    }
    
    func cancelClick(){
        
        if hide == false{
        
            self.view.endEditing(true)
                
            self.myPickerView.isHidden = true
            
            self.toolBar.isHidden = true
            
            hide = true
            
        }
        
    }

    
    
    // 按空白處會隱藏編輯狀態
    func hideKeyboard(tapG:UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    func hidePickerView() {
        
        if hide == false {
        
        hide = true
           
        self.view.endEditing(true)
            
        self.myPickerView.isHidden = true
        
        self.toolBar.isHidden = true
        
        if _connect_peripheral == nil {
            
            let alert = UIAlertController(title: "請選擇欲連接藍芽", message: nil, preferredStyle: .alert)
            
            let alert_btn = UIAlertAction(title: "關閉", style: .default) { _ in
                
//                self.showPickerView()
                
            }
            
            alert.addAction(alert_btn)
            
            OperationQueue.main.addOperation {
                
                self.present(alert, animated: true, completion: nil)
                
            }
            
            return
            
        }
        
        _ble_central.connect(peripheral: _connect_peripheral!.peripheral)
            
        }
        
    }
    
    //計算距離
    
    func distanceBetweenPoints(p1: CGPoint, p2: CGPoint) -> CGFloat {
        
        let dx = p1.x - p2.x
        
        let dy = p1.y - p2.y
        
        return sqrt((dx * dx) + (dy * dy))
        
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
    
    //檢查現在藍牙有沒有斷線
    
    func checkConnection() {
        
        if _connect_peripheral!.peripheral.state == CBPeripheralState.disconnected {
            
            print("\(_connect_peripheral!.peripheral.name!) 已經斷線")
            
            if let t = _timer {
                
                t.invalidate()
                
                _timer = nil
                
            }
            
            let alert = UIAlertController(title: "錯誤", message: "\(_connect_peripheral!.peripheral.name!) 已經斷線", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "關閉", style: .default) { _ in
                
                if let _ = self.knob_view {
                    
                    self.knob_view = nil
                    
                }
                
                if let _ = self.circle_uiview {
                    
                    self.circle_uiview = nil
                    
                }
                
            }
            
            alert.addAction(action)
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    //MARK: - PickerView setting
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return _ready_to_connect.count + 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if row == 0 {
            
            return "請選擇連接裝置"
        }
        
        return _ready_to_connect[row - 1].peripheral.name!
        
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if row > 0 {
            
            _connect_peripheral = _ready_to_connect[row - 1]
            
        }
        
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
        
        label.text = "已連接上 \(_connect_peripheral!.peripheral.name!)"
        
        self.label.layer.borderColor = UIColor(red: 0.0, green: 128.0, blue: 0.0, alpha: 1.0).cgColor
        
        self.label.textColor = UIColor(red: 0.0, green: 128.0, blue: 0.0, alpha: 1.0)
        
        is_connected = true
        
        btn_connect.setTitle("斷線此裝置", for: .normal)
        
        showKnob()
        
        //藍牙連接上時，將呼叫 showknob func 將搖桿顯示出來
        
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


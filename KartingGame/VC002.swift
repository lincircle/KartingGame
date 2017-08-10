//
//  VC002.swift
//  KartingGame
//
//  Created by yorker Lin on 2017/8/6.
//  Copyright © 2017年 cgua. All rights reserved.
//

import UIKit

class VC002: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var pvBtnTapped: UIButton!
    
    let shopPicker = UIPickerView()
    
    let shop = ["一口田芝麻館",
                "德廣堂",
                "快樂關鍵",
                "華珍",
                "虎林商行",
                "左手香",
                "中央畜牧場",
                "打狗餅舖",
                "徐記醬鴨",
                "亞瑪薩",
                "玉心承",
                "其他"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func btnTapped(_ sender: Any) {
        
        showPickerView2()
        
    }
    
    @IBAction func dismissTapped(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showPickerView2() {
        
        print("showPickerView2")
        
        shopPicker.delegate = self
        
        pvBtnTapped.inputView = shopPicker
        
        //toolbar
        let toolbar = UIToolbar()
        
        toolbar.sizeToFit()
        
        //bar  button item
        let doneButton = UIBarButtonItem(title: "完成",style: .done, target: nil, action: #selector(self.shopDonePress))
        
        toolbar.setItems([doneButton], animated: false)
        
        hopPickerText.inputAccessoryView = toolbar
        
        
    }
    
    func shopDonePress(){
        
        self.view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 0    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return shop[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

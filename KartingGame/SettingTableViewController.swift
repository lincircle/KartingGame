//
//  SettingTableViewController.swift
//  KartingGame
//
//  Created by Yuhsuan Lin on 2017/6/11.
//  Copyright © 2017年 cgua. All rights reserved.
//

import UIKit
import MessageUI

class SettingTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    let setting_title = ["意見回饋/合作機會","關於我們","操作說明","目前版本"]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.setting_title.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "setting_cell", for: indexPath) as! SettingTableViewCell
        
        cell.title_label.text = setting_title[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            _sentMail()
            
            //TODO: - 開啟寄信功能
        }
    }
    
    private func _sentMail() {
        
        if MFMailComposeViewController.canSendMail() {
            
            let mail = MFMailComposeViewController()
            
            mail.mailComposeDelegate = self
            
            mail.setToRecipients(["gamennovation@gmail.com"])
            
            mail.setSubject("[Arduino GO] 意見回饋")
            
            let systemVersion = UIDevice.current.systemVersion
            
            if let app_version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                
                mail.setMessageBody("請於下方告訴我們您的需求或想法：\n\n\n\n\nDevice: iPhone\n iOS: \(systemVersion)\n AppVersion: \(app_version) ", isHTML: false)
                
            }
            
            present(mail, animated: true, completion: nil)
            
        }
        else {
            
            print("不能開啟 mail VC")
            
        }
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true, completion: nil)
        
    }

}

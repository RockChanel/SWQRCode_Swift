//
//  ViewController.swift
//  SWQRCode_Swift
//
//  Created by zhuku on 2018/4/10.
//  Copyright © 2018年 selwyn. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let titles = ["扫一扫"];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tbv = UITableView(frame: self.view.bounds, style: .plain)
        tbv.delegate = self
        tbv.dataSource = self
        self.view.addSubview(tbv)
        
        tbv.register(UITableViewCell.self, forCellReuseIdentifier: "cell_id")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_id", for: indexPath)
        cell.textLabel?.text = self.titles[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let qrcodeVC = SWQRCodeViewController()
            self.navigationController?.pushViewController(qrcodeVC, animated: true)
        default:
            break
        }
    }
}






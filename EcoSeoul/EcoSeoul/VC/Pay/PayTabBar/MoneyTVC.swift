//
//  MoneyTVC.swift
//  EcoSeoul
//
//  Created by 조예은 on 2018. 9. 21..
//  Copyright © 2018년 GGOMMI. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class MoneyTVC: UITableViewController, APIService {
    
    let userIdx = UserDefaults.standard.integer(forKey: "userIdx")
    let userMoney = UserDefaults.standard.integer(forKey: "userMoney")
    
    var moneyListDataArr: [MoneyListData]?
    
    //적립 머니, 사용 머니 레이블, 현재 머니 레이블
    @IBOutlet weak var depositMoney: UILabel!
    @IBOutlet weak var withdrawMoney: UILabel!
    @IBOutlet weak var currentMoney: UILabel!
    var deposit = 0
    var withdraw = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        network()
        currentMoney.text = String(userMoney)
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        network()
        currentMoney.text = String(userMoney)
    }
    
    func network(){
         getMoneyData(url: url("/mypage/usage/\(userIdx)/1"))
    }
    
    
    func getMoneyData(url : String){

        MoneyListService.shareInstance.getMoneyData(url: url, completion: { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .networkSuccess(let data):
                self.moneyListDataArr = data.moneyTotalUsage
                self.tableView.reloadData()
                break
            case .networkFail :
                self.simpleAlert(title: "network", message: "check")
            default :
                break
            }

        })

    }
    
}

extension MoneyTVC{
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let arr = moneyListDataArr else {return 3}
        return arr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoneyTVCell", for: indexPath) as! MoneyTVCell
        let row = indexPath.row
        cell.selectionStyle = .none
        
        if let moneyArr = moneyListDataArr {
            
            cell.usageTitleLB.text = moneyArr[row].moneyUsage
            cell.usageDateLB.text = moneyArr[row].moneyDate
            
            if moneyArr[row].moneyDeposit != nil {
                deposit += moneyArr[row].moneyDeposit!
                cell.plusminusLB.text = String("+\(moneyArr[row].moneyDeposit!)")
            }
            else {
                withdraw += moneyArr[row].moneyWithdraw!
                cell.plusminusLB.text = String("-\(moneyArr[row].moneyWithdraw!)")
                cell.plusminusLB.textColor = #colorLiteral(red: 1, green: 0.5333333333, blue: 0.5333333333, alpha: 1)
                cell.moneyIcon.image = #imageLiteral(resourceName: "my-mileage-use")
            }
            
            depositMoney.text = "\(deposit)"
            withdrawMoney.text = "\(withdraw)"
            
        }
        
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 63
    }
    
    
}


extension MoneyTVC: IndicatorInfoProvider{
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo.init(title: "에코 머니")
    }
}


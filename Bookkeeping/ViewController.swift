//  ViewController.swift
//  Bookkeeping
//  Created by claire chang on 2024/3/12.
//

import UIKit
var total:Double = 0  //暫存計算結果的變數

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var dataArray = [[String:Any]]() //空的 [String:Any] dictionary array 來儲存消費資料
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return dataArray.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //從storyboard中的table view尋找有identifier為"Basic Cell"的 cell 範例，如果之前有相同identifier的Cell被宣告出來且沒有在⽤的話，重複使⽤以節省記憶體
    let cell = tableView.dequeueReusableCell(withIdentifier: "Basic Cell", for: indexPath)
    
    //取得dictionary取得要顯⽰的資料的key的值
    let name = dataArray[indexPath.row]["name"] as? String ?? "No name" //取得key為name的資料條件轉型成String，如果沒有這個key value pair 或轉型不成功，使⽤"No name"字串取代
    let cost = dataArray[indexPath.row]["cost"] as? Double ?? 0.0  //取得key為cost的資料條件轉型成Double，如果沒有這個key value pair 或轉型不成功，使⽤0.0取代
            
    //設定cell的內容
    cell.textLabel?.text = name        //把name設定到cell的title
    cell.detailTextLabel?.text = "\(cost)"        //把cost設定到cell的detail title
    
    return cell
    }
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var newCostField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()  // Do any additional setup after loading the view.
    }
    
    @IBAction func addData(_ sender: Any) {
        guard let newCostString = newCostField.text, !newCostString.isEmpty else { return }  //檢查輸入匡有沒有⽂字，如果沒有，離開function
        guard let newCost = Double(newCostString) else { return }  //檢查輸入的⽂字可不可以轉成 Double，如果不能，離開function
        guard let newName = nameField.text, !newName.isEmpty else { return }  //檢查、取得輸入的名字
        let newDate = Date()   //取得輸入資料當下的時間
        dataArray.append(["name":newName,"cost":newCost,"date":newDate])  //創造新的Dictionary加入array

        let refreshIndexPath = IndexPath.init(row: dataArray.count-1, section: 0)  //創立指向新增資料所在的table位置的IndexPath物件
        tableView.insertRows(at:[refreshIndexPath], with: .top)  //告訴table view要插入這些位置(array)的row，使⽤從上插入的動畫
        //tableView.reloadData()  //叫table view 重新讀取⼀次資料(有前兩行就不需要這一行了)
        newCostField.text = ""  //準備下次輸入，將輸入匡清空
        nameField.text = ""
        newCostField.resignFirstResponder()  //將鍵盤收起
        nameField.resignFirstResponder()
        
        updateTotal()
        totalCostLabel.text = "\(total)"   //將計算的結果顯⽰在 totalCostLabel
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath:IndexPath) -> Bool { return true }  //讓edit的功能在每個位置的row都啟⽤
    
    func tableView(_ tableView: UITableView, commit editingStyle:UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
            case .delete: //如果是 commit delete 的動作
            dataArray.remove(at: indexPath.row ) //從 array 移除資料
            tableView.deleteRows(at: [indexPath], with: .top) //告訴table view要刪掉這些位置(array)的資料的row，使⽤往上刪除的動畫
            updateTotal()
            totalCostLabel.text = "\(total)"   //將計算的結果顯⽰在 totalCostLabel
            default: break  //其他edit的動作不做任何事
        }
    }
    
    func updateTotal(){
        total = 0
        for item in dataArray {
            if let cost = item["cost"] as? Double { total = total + cost }
        }
    totalCostLabel.text = "\(total)"   //將計算的結果顯⽰在 totalCostLabel
    }
}


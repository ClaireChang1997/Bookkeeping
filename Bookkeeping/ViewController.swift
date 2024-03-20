//  ViewController.swift
//  Bookkeeping
//  Created by claire chang on 2024/3/12.
//

import UIKit
var total:Double = 0  //暫存計算結果的變數

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var dataArray = [[String:Any]]() //空的 [String:Any] dictionary array 來儲存消費資料
    var groupByDate = Dictionary<String, [Array<[String : Any]>.Element]>()
    var keys = [String]()
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return groupByDate[keys[section]]!.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //從storyboard中的table view尋找有identifier為"Basic Cell"的 cell 範例，如果之前有相同identifier的Cell被宣告出來且沒有在⽤的話，重複使⽤以節省記憶體
        let cell = tableView.dequeueReusableCell(withIdentifier: "Basic Cell", for: indexPath)
        
        //取得dictionary取得要顯⽰的資料的key的值
        if keys.count > 0{
            let name = groupByDate[keys[indexPath.section]]![indexPath.row]["name"] as? String ?? "No name" //取得key為name的資料條件轉型成String，如果沒有這個key value pair 或轉型不成功，使⽤"No name"字串取代
            let cost = groupByDate[keys[indexPath.section]]![indexPath.row]["cost"] as? Double ?? 0.0  //取得key為cost的資料條件轉型成Double，如果沒有這個key value pair 或轉型不成功，使⽤0.0取代
            
            //設定cell的內容
            cell.textLabel?.text = name        //把name設定到cell的title
            cell.detailTextLabel?.text = "\(cost)"        //把cost設定到cell的detail title
            
            return cell
        } else {
            cell.textLabel?.text = "No name"        //把name設定到cell的title
            cell.detailTextLabel?.text = "\(0.0)"        //把cost設定到cell的detail title
            
            return cell
        }
    }
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var newCostField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()  // Do any additional setup after loading the view.
        loadDataArray()
        groupingDate()
    }
    
    @IBAction func addData(_ sender: Any) {
        guard let newCostString = newCostField.text, !newCostString.isEmpty else { return }  //檢查輸入匡有沒有⽂字，如果沒有，離開function
        guard let newCost = Double(newCostString) else { return }  //檢查輸入的⽂字可不可以轉成 Double，如果不能，離開function
        guard let newName = nameField.text, !newName.isEmpty else { return }  //檢查、取得輸入的名字
        let newDate = Date()   //取得輸入資料當下的時間
        
        let formatter = DateFormatter() //宣告要拿來轉換時間的formatter
        formatter.dateFormat = "yyyy/MM/dd hh:mm" //設定字串轉換要⽤的格式
        let newDateString = formatter.string(from:newDate) //轉換時間成字串
        
        dataArray.append(["name":newName,"cost":newCost,"date":newDateString])  //創造新的Dictionary加入array
        
//        let refreshIndexPath = IndexPath.init(row: dataArray.count-1, section: 0)  //創立指向新增資料所在的table位置的IndexPath物件
//        tableView.insertRows(at:[refreshIndexPath], with: .top)  //告訴table view要插入這些位置(array)的row，使⽤從上插入的動畫
        newCostField.text = ""  //準備下次輸入，將輸入匡清空
        nameField.text = ""
        newCostField.resignFirstResponder()  //將鍵盤收起
        nameField.resignFirstResponder()
        
        updateTotal()
        groupingDate()
        tableView.reloadData() //叫table view 重新讀取⼀次資料 (與59.60行同義)
        saveDataArray()
    }
    
    //回傳有幾個section
    func numberOfSections(in tableView: UITableView) -> Int {
        return keys.count
    }
    
    //回傳不同位置的section header要顯⽰什麼title
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if keys.count > 0{
            return keys[section]
        }else{
            return " "
        }
    }
    
    //讓edit的功能在每個位置的row都啟⽤
    func tableView(_ tableView: UITableView, canEditRowAt indexPath:IndexPath) -> Bool { return true }
    
    func tableView(_ tableView: UITableView, commit editingStyle:UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: //如果是 commit delete 的動作
            print("Deleting from dataArray:",indexPath.section,indexPath.row  )
            print("Deleting from dataArray:", groupByDate[keys[indexPath.section]]![indexPath.row] )
//            dataArray.remove(at: indexPath.row ) //從 array 移除資料
            
            let nameToRemove:String = groupByDate[keys[indexPath.section]]![indexPath.row]["name"] as! String
            let dateToRemove:String = groupByDate[keys[indexPath.section]]![indexPath.row]["date"] as! String
            
            for (idx, item) in dataArray.enumerated() {
                if let strName = item["name"] as? String, strName == nameToRemove {
                    if let strDate = item["date"] as? String, strDate == dateToRemove {
                        dataArray.remove(at:idx)
                        break
                    }
                }
            }
//            tableView.deleteRows(at: [indexPath], with: .top) //告訴table view要刪掉這些位置(array)的資料的row，使⽤往上刪除的動畫
            updateTotal()
            groupingDate()
            tableView.reloadData()
            saveDataArray()
        default: break  //其他edit的動作不做任何事
        }
    }
    
    func updateTotal(){
        total = 0
        for item in dataArray {
            if let cost = item["cost"] as? Double {
                total = total + cost
            }
        }
        totalCostLabel.text = "\(total)"   //將計算的結果顯⽰在 totalCostLabel
    }
    
    func groupingDate(){
        groupByDate = Dictionary.init(grouping: dataArray) {
            (DateGroup:Dictionary<String,Any>) -> String in
            return DateGroup["date"] as! String
        }
        keys = Array(groupByDate.keys).sorted()
    }
    
    // 將字串寫入檔案的 method 需要有 file name 及要寫入的 string 兩種 input
    func writeStringToFile(writeString:String, fileName:String) {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else{ return }  //取得app專⽤資料夾路徑，並且確定檔案路徑存在
        let fileURL = dir.appendingPathComponent(fileName)  //在路徑後加上檔名，組合成要寫入的檔案路徑
        
        //嘗試使⽤utf8格式寫入檔案，若寫入錯誤print錯誤
        do{ try writeString.write(to: fileURL, atomically: false, encoding: .utf8) } catch { print("write error") }
    }
    
    // 將檔案讀出成字串的 method 只需要 input 檔名，return 讀取出來的 string
    func readFileToString(fileName:String) -> String {
        guard let dir = FileManager.default.urls(for: .documentDirectory,in: .userDomainMask).first else{ return "" }  //取得app專⽤資料夾路徑，並且確定檔案路徑存在，如果不存在，return空字串
        let fileURL = dir.appendingPathComponent(fileName)  //在路徑後加上檔名，組合成要讀取的檔案路徑
        var readString = ""  //宣告要儲存讀取出來的string的變數
        
        //嘗試使⽤utf8格式讀取字串，若讀取錯誤print錯誤
        do{ try readString = String.init(contentsOf: fileURL, encoding: .utf8) } catch { print("read error") }
        return readString //return讀取出的string
    }
    
    // 將 Dictionary 轉成csv字串格式，並且寫入檔案的功能包成⼀個 method
    func saveDataArray(){
        var finalString = "" //宣告儲存最後string的變數
        var csvString = ""
        for dictionary in dataArray {
            let date = dictionary["date"] as! String
            let name = dictionary["name"] as! String
            let cost = dictionary["cost"] as! Double
            
            csvString = "\(date),\(name),\(cost)\n"
            finalString.append(csvString)
        }
        //let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        //print("[saveDataArray] writing to dir=", dir)  //檢查txt檔存放位置
        
        writeStringToFile(writeString: finalString, fileName:"data.txt")  //寫入data.txt檔案
    }
    
    //載入 Dictionary Array 的 function
    func loadDataArray() {
        var finalArray = [[String:Any]]()  //宣告儲存Array最後的結果的變數
        let csvString = readFileToString(fileName: "data.txt")  //讀取data.txt的檔案內容/
        let lineOfString = csvString.components(separatedBy: "\n")  //⽤"\n"將每⼀筆資料分開
        
        let a = lineOfString.count
        
        //iterate 每⼀筆資料的string
        if a > 1 {
            for count in 0...a-2 {
                let pendingArray = lineOfString[count].components(separatedBy: ",")
                
                let oldDate = String(pendingArray[0])
                let oldName = String(pendingArray[1])
                let oldCost = Double(pendingArray[2])
                finalArray.append(["date":oldDate,"name":oldName,"cost":oldCost!])
            }
        }
        
        dataArray = finalArray //將讀取出的finalArray取代掉原本的dataArray
        tableView.reloadData() //更新 tableview 與 介⾯資料
        updateTotal()
    }
}

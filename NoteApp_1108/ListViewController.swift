//  ListViewController.swift
//  NoteApp_1108

import UIKit
import CoreData

class ListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,NoteViewControllerDelegate {
    
    //Model
    var data : [Note] = []
    
    //View
    @IBOutlet weak var tableView: UITableView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadFromCoreData()
    }
    deinit {
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        self.tableView.setEditing(editing, animated: true)
        
    }
    
    //新刪改查，方法一：
    //MARK: Core Data
    func saveToCoreData(){
        CoreDataHelper.shared.saveContext()
    }
    func loadFromCoreData(){
        let moc = CoreDataHelper.shared.managedObjectContext()
        let fetchRequest = NSFetchRequest<Note>(entityName: "Note")
        moc.performAndWait {
            do{
                let result = try moc.fetch(fetchRequest)
                self.data = result
            } catch {
                print("error\(error)")
            }
        }
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath)
        let note = self.data[indexPath.row]
        cell.textLabel?.text = note.text
        cell.showsReorderControl = true
        cell.imageView?.image = note.thumbnailImage()
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let noteRemove = self.data.remove(at: indexPath.row)
            CoreDataHelper.shared.managedObjectContext().delete(noteRemove)
            self.saveToCoreData()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    
    //編輯>拖拉排序放開後才呼叫到下面這個
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let note =  self.data.remove(at: sourceIndexPath.row)
        self.data.insert(note, at: destinationIndexPath.row)
        self.saveToCoreData()
    }
    
    @IBAction func addNote(_ sender: Any) {
        let moc = CoreDataHelper.shared.managedObjectContext()
        let note = Note(context: moc)
        note.text = "New Note"
        self.data.insert(note, at: 0)
        self.saveToCoreData()

        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "noteSegue"{
            let noteVC = segue.destination as! NoteViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
                noteVC.currentNote = self.data[indexPath.row]
                noteVC.noteDelegate = self
            }
        }
    }
    
    
    //在Note頁面按下done時被通知的方法
    func didFinishUpdate(note: Note) {
        self.saveToCoreData()

        if let index = self.data.firstIndex(of: note) {

            let indexPath = IndexPath(row: index, section: 0)
            
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        print("didFinishUpdate")
    }
    

}


////////////////////////////ＥＮＤ/////////////////////////////////////////////////////

//Notification步驟一、
//對done事件有興趣，通知的名稱為"NoteUpdated" 老師說這次考試不要用這個太簡單，要用Delegate方式
//這段放required init?裡面
//        NotificationCenter.default.addObserver(self, selector: #selector(ListViewController.updateNote(notification:)), name: Notification.Name("NoteUpdated"), object: nil)

//Notification步驟二、
//這段放deinit裡面
//        NotificationCenter.default.removeObserver(self)

//Notification步驟三、
//通知方法的參數是固定的，要馬沒有參數，要馬就是一個參數Notification物件
//    @objc func updateNote(notification: Notification) {
//        if let note = notification.userInfo?["note"] as? Note {
//            if let index = self.data.firstIndex(of: note) { //swift 4.2
//                //  取得在data中位置
//                let indexPath = IndexPath(row: index, section: 0)//組成IndexPath
//                //reload特定位置
//                self.tableView.reloadRows(at: [indexPath], with: .automatic)
//            }
//        }
//    }



//連結畫面拉的button(Item) 點了之後可以編輯項目，但字樣不會變done，故老師改教上面寫一行ＣＯＤＥ
//    @IBAction func edit(_ sender: Any) {
//        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
//    }


    //新刪改查，方法二：
    //MARK:Archiving
//    func saveToFile(){
//        //把self.data存到檔案
//        do {
//            let data = try NSKeyedArchiver.archivedData(withRootObject: self.data, requiringSecureCoding: false)
//            //把data寫到檔案
//            let home = URL(fileURLWithPath:NSHomeDirectory())
//            let documents = home.appendingPathComponent("Documents")
//            let fileName = documents.appendingPathComponent("notes.archive")//檔名notes.archive
//            try data.write(to: fileName, options: [.atomicWrite])
//
//        }catch{
//            print("error \(error)")
//
//        }
//
//    }
//    func loadFromFile() {
//        let home = URL(fileURLWithPath:NSHomeDirectory())
//        let documents = home.appendingPathComponent("Documents")
//        let fileName = documents.appendingPathComponent("notes.archive")//檔名notes.archive
//        do{
//            //從檔案轉成Data
//            let data = try Data(contentsOf: fileName)
//            //解成[Note]放回self.data
//            self.data = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as! [Note]
//
//        }catch{
//            print("loadFromFile error \(error)")
//
//        }
//
//    }


    //不靠拉畫面也可以到第二組畫面
    //MAEK: UITableViewDelegate
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        print("row=\(indexPath.row)")
    //        tableView.deselectRow(at: indexPath, animated: true)
    //        //只有在這個controller是storyboard產生的，self.storyboard才會有值，才能找到storyboard物件
    //        //透過storyboard id 產生第二組畫面
    //        //new NoteViewController
    //        if let noteVC = self.storyboard?.instantiateViewController(withIdentifier: "noteVC"){
    //        self.navigationController?.pushViewController(noteVC, animated: true)
    //        }
    //    }
    
    //    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        return "This is Header"
    //    }
    //
    //    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    //        return "This is Footer"
    //    }
    //    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //        return UISwitch()
    //    }


    //    @IBAction func upload(_ sender: Any) {
    //        let item = sender as! UIBarButtonItem
    //
    //        let activityView = UIActivityIndicatorView(style: .gray)
    //        activityView.translatesAutoresizingMaskIntoConstraints = false
    //        item.customView = activityView
    //        activityView.startAnimating() //開始旋轉
    //
    //        DispatchQueue.global().async {//背景執行，非主執行緒1
    //            Thread.sleep(forTimeInterval: 3)//模擬網路下載
    //            DispatchQueue.main.async{
    //            item.customView = nil //恢復成原本的按鈕
    //            }
    //        }
    //    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation

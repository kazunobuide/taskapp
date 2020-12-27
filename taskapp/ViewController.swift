//
//  ViewController.swift
//  taskapp
//
//  Created by 井手　和宣 on 2020/12/27.
//  Copyright © 2020 kazunobu.ide. All rights reserved.
//
import UIKit
import RealmSwift //←追加した
import UserNotifications//追加

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    //Realmインスタンスを取得する
    let realm = try! Realm()// ←追加した
    
    //DB内のタスクが格納されるリスト。
    //日付の近い順でソート：昇順
    //以降内容をアップデートするとリスト内は自動的に更新される
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)//←追加した
    //（課題）
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        //（課題）
        searchBar.delegate = self
        searchBar.enablesReturnKeyAutomatically = false
    }

    // データの数（＝セルの数）を返すメソッド
    //tableView(_:numberOfRowsInSection:)メソッドはデータの数を返すメソッドなのでデータの配列であるtaskArrayの要素数を返すようにします。
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count//修正した
    }

    // 各セルに内容を返すメソッド
    //tableView(_:cellForRowAtIndexPath:)メソッドは各セルの内容を返すメソッドです。データの配列であるtaskArrayから該当するデータを取り出してセルに設定します。ここで登場するDateFormatterクラスは日付を表すDateクラスを任意の形の文字列に変換する機能を持ちます。
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //Cellに値を設定する。
        let task = taskArray[indexPath.row]
        //（課題）カテゴリもテキストに追加
        cell.textLabel?.text = "【"+task.category+"】" + task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }

    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil) // ← 追加した
    }

    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }

    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            //削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            //ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            //データベースから削除する
            try! realm.write{
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            //未通知のローカル通知一覧とログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests{
                    print("/----------")
                    print(request)
                    print("----------/")
                }
            }
        }
    }
    
    //（課題）テキスト変更時の呼び出しメソッド
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if(searchBar.text == "") {
            //検索文字列が空の場合はすべてを表示する。
            taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending:  false)
        } else {
            taskArray = try! Realm().objects(Task.self).filter("category CONTAINS '\(searchText)'").sorted(byKeyPath: "date", ascending: false)
        }
        //テーブルを再読み込みする。
        tableView.reloadData()
    }
    //segueで画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        if segue.identifier == "cellSegue"{
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        }else{
            let task = Task()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    //入力画面から戻ってきた時にTableViewを更新させる
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
}


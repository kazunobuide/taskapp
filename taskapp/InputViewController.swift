//
//  InputViewController.swift
//  taskapp
//
//  Created by 井手　和宣 on 2020/12/27.
//  Copyright © 2020 kazunobu.ide. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    //課題で追加。categoryのTextFieldを追加、Outletをつなげる
    @IBOutlet weak var categoryTextField: UITextField!
    let realm = try! Realm()//追加した
    var task: Task!//←追加した
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    //背景をタップしたらdismissKeyboardメソッドを呼ぶように設定
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        //（課題）
        categoryTextField.text = task.category
        datePicker.date = task.date
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool){
        try! realm.write{
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.realm.add(self.task, update: .modified)
            //（課題）categoryの値を代入
            self.task.category = self.categoryTextField.text!
            
        }
        
        setNotification(task: task)//追加
        
        super.viewWillDisappear(animated)
    }
        
    //タスクのローカル通知を登録する
    func setNotification(task: Task){
        let content = UNMutableNotificationContent()
        //タイトルと内容を設定（中身がない場合メッセージ無しで音だけの通知になるので「（××なし）」を表示する）
        if task.title == ""{
            content.title = "(タイトルなし)"
        }else{
            content.title = task.title
        }
        if task.contents == ""{
            content.body = "(内容なし)"
        }else{
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default
        
        //ローカル通知が発動するtrigger(日付マッチ)を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from : task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        //idntifier, content, triggerからローカル通知を作成(identifierが同じだとローカル通知を上書き保存)
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        
        //ローカル通知を記録
        let center = UNUserNotificationCenter.current()
        center.add(request){(error) in
            print(error ?? "ローカル通知記録 OK")//errorがnilならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
            
        //未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (request: [UNNotificationRequest]) in
                for request in request{
                    print("/-----------")
                    print(request)
                    print("-----------/")
                }
            }
        
        
        }
    }
        
        @objc func dismissKeyboard(){
            //キーボードを閉じる
            view.endEditing(true)
        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

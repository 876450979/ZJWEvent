//
//  EventViewController.swift
//  日历提醒
//
//  Created by 赵建卫 on 2018/6/12.
//  Copyright © 2018年 zhaojianwei. All rights reserved.
//

import UIKit
import EventKit
class EventViewController: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.green
        
        //判断日历授权的话,弹出框出不来,这种方式不适用
        
        //获取当前时间戳 (测试获取时间戳)
        let dat = Date(timeIntervalSinceNow: 7200)  //当前时间之后的一个小时
        let a = dat.timeIntervalSince1970    //格式话成1970
        print(String(format: "%.f", a))
        //转换为时间
        let time:TimeInterval = TimeInterval(a)
        let date = Date(timeIntervalSince1970: time)
        //格式话输出
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        print("对应的日期时间：\(dformatter.string(from: date))")
        
    }
    
    
}

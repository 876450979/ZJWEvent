//
//  ViewController.swift
//  日历提醒
//
//  Created by 赵建卫 on 2018/6/11.
//  Copyright © 2018年 zhaojianwei. All rights reserved.
//

import UIKit
import EventKit
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
        
    }
    
    func configUI() {
        let addEvent = UIButton(frame: CGRect(x: 10, y: 100, width: 150, height: 50))
        addEvent.backgroundColor = UIColor.green
        addEvent.setTitleColor(UIColor.red, for: .normal)
        addEvent.setTitle("添加提醒", for: .normal)
        view.addSubview(addEvent)
        addEvent.addTarget(self, action: #selector(clickAddEvent), for: .touchUpInside)
        
        let remveEvent = UIButton(frame: CGRect(x: 10, y: 200, width: 150, height: 50))
        remveEvent.backgroundColor = UIColor.green
        remveEvent.setTitleColor(UIColor.red, for: .normal)
        remveEvent.setTitle("删除提醒", for: .normal)
        view.addSubview(remveEvent)
        remveEvent.addTarget(self, action: #selector(clickRemoveEvent), for: .touchUpInside)
    }
    
    @objc func clickAddEvent() {
        //开始时间和结束时间  传后台给你的时间戳
        createEventCalendarTitle(title: "日历提醒标题测试", location: "北京市北京市北京市", startDate: Date(timeIntervalSince1970: 1528863915), endDate: Date(timeIntervalSince1970: 1528867711), allDay: false, alarmArray: ["-60"])
    }
    
    @objc func clickRemoveEvent() {
        removeAllEventCalendar(startDate: Date(timeIntervalSince1970: 1528863915), endDate: Date(timeIntervalSince1970: 1528867711))
    }
    
    
    
    /**
     *  将App事件添加到系统日历提醒事项，实现闹铃提醒的功能
     *
     *  @param title      事件标题
     *  @param location   事件位置
     *  @param startDate  开始时间
     *  @param endDate    结束时间
     *  @param allDay     是否全天
     *  @param alarmArray 闹钟集合(最多传两个 秒)
     */
    func createEventCalendarTitle(title: String, location: String, startDate: Date, endDate: Date, allDay: Bool, alarmArray: Array<String>) {
        
        EventCalendar.eventStore.requestAccess(to: EKEntityType.event) { [unowned self] (granted, error) in
            DispatchQueue.main.async {
                
                //用户没授权
                if !granted {
                    let alertViewController = UIAlertController(title: "提示", message: "请在iPhone的\"设置->隐私->日历\"选项中,允许***访问你的日历。", preferredStyle: .alert)
                    let actionCancel = UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
                    })
                    let actinSure = UIAlertAction(title: "设置", style: .default, handler: { (action) in
                        //跳转到系统设置主页
                        if let url = URL(string: UIApplicationOpenSettingsURLString) {
                            //根据iOS系统版本，分别处理
                            if #available(iOS 10, *) {
                                UIApplication.shared.open(url)
                            } else {
                                UIApplication.shared.openURL(url)
                            }
                        }
                    })
                    alertViewController.addAction(actionCancel)
                    alertViewController.addAction(actinSure)
                    self.present(alertViewController, animated: true, completion: nil)
                    return
                }
                //允许
                if granted {
                    //过滤重复事件
                    let predicate = EventCalendar.eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)  //根据时间段来筛选
                    let eventsArray = EventCalendar.eventStore.events(matching: predicate)
                    if eventsArray.count > 0 {
                        for item in eventsArray {
                            //根据事件唯一性,如果已经插入的就不再插入了
                            if let start = item.startDate, let end = item.endDate {
                                if start == startDate && end == endDate {
                                    return
                                }
                            }
                        }
                    }
                    
                    let event = EKEvent(eventStore: EventCalendar.eventStore)
                    event.title = title
                    event.location = location
                    event.startDate = startDate
                    event.endDate = endDate
                    event.isAllDay = allDay
                    
                    //添加提醒时间(提前)
                    if alarmArray.count > 0 {
                        
                        for timeString in alarmArray {
                            if let time = TimeInterval(timeString) {
                                event.addAlarm(EKAlarm(relativeOffset: TimeInterval(time)))
                            }
                        }
                        
                    }
                    
                    event.calendar = EventCalendar.eventStore.defaultCalendarForNewEvents  //必须设置系统的日历
                    
                    do {
                        try EventCalendar.eventStore.save(event, span: EKSpan.thisEvent)
                    }catch{}
                    
                    print("事件ID--\(event.eventIdentifier)")  //(只读)系统随机生成的,需要保存下来,下次删除使用
                    self.eventId = event.eventIdentifier  //保存本次事件id   可以通过后台返回的id做这次保存的key值,偏好设置保存
                    print("成功添加到系统日历中")
                }
            }
        }
    }
    
    var eventId: String?
    ///删除指定事件 根据事件id来删除
    func removeEventCalendar(idfer: String) {
        
        guard let event = EventCalendar.eventStore.event(withIdentifier: idfer) else {
            return
        }
        do {
            try EventCalendar.eventStore.remove(event, span: EKSpan.thisEvent)
        } catch {}
        
        print("删除成功")
    }
    
    ///删除某个时间段所有的事件(会删除这个时间段所有时间,包括用户自己添加的)
    func removeAllEventCalendar(startDate: Date, endDate: Date) {
        
        let predicate = EventCalendar.eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)  //根据时间段来筛选
        let eventsArray = EventCalendar.eventStore.events(matching: predicate)
        if eventsArray.count > 0 {
            
            for item in eventsArray {
                //删除老版本插入的提醒
                do {
                    try EventCalendar.eventStore.remove(item, span: EKSpan.thisEvent, commit: true)
                }catch{}
                print("删除过期时间成功")
            }
        }
    }

}


//
//  EventCalendar.swift
//  日历提醒
//
//  Created by 赵建卫 on 2018/6/11.
//  Copyright © 2018年 zhaojianwei. All rights reserved.
//

import UIKit
import EventKit
class EventCalendar: NSObject {
    //单例
    static let eventStore = EKEventStore()
    
    ///用户是否授权使用日历
    func isEventStatus() -> Bool {
        let eventStatus = EKEventStore.authorizationStatus(for: EKEntityType.event)
        if eventStatus == .denied || eventStatus == .restricted {
            return false
        }
        return true
    }
}

//
//  Date+Extension.swift
//  TimerDemo
//
//  Created by mmh on 2020/3/23.
//  Copyright © 2020 mmh. All rights reserved.
//

import UIKit

public extension Date {
    /// 将TimeInterval转化成指定格式的字符串
    /// - Parameter time: 目标时间戳
    /// - Parameter formate: m格式化字符串
    static func getTimeStyle(time: TimeInterval, formate: String) -> String {
        let targetDate = Date.init(timeIntervalSince1970: time)
        return targetDate.stringWithFormat(formate)
    }
    
    /// 将Date转化成指定格式的字符串
    /// - Parameter format: 格式化字符串
    func stringWithFormat(_ format: String) -> (String) {
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale.current
        dateformatter.dateFormat = format
        return dateformatter.string(from: self)
    }
    
    /// 比较当前时间是否晚于目标时间
    /// - Parameter otherDate: 目标时间
    func laterThan(_ otherDate: Date) -> Bool {
        return compare(otherDate) == ComparisonResult.orderedDescending
    }
}

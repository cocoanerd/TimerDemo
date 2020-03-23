//
//  ViewController.swift
//  TimerDemo
//
//  Created by mmh on 2020/3/23.
//  Copyright © 2020 mmh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        timeLabel.frame = view.bounds;
        view.addSubview(timeLabel)
        
        
        Gatling.sharedGatling.loadWithTarget(self, timeInterval: 1, shootsImmediately: true, needCatchUp: true)

    }
    
    func timeChange(sleepTime: TimeInterval){
        //未来时间-当前时间，这里是随便写的例子
        var space = (Date().timeIntervalSince1970 * 1000 - 1582462875000)/1000
        if space < 0 { space = 0 }
        var interval = TimeInterval(space)
        if sleepTime > 0 {
            interval -= sleepTime
        } else {
            interval -= 1
        }
        var time = interval
        if time <= 0 {
            time = 0
        }
        let hour = Int(time / 3600)
        time = time - Double(hour) * 3600
        let minute = Int(time / 60)
        time = time - Double(minute) * 60
        let second = Int(time)
        
        let hourStr = String(format: "%02ld", hour)
        let minuteStr = String(format: "%02ld", minute)
        let secondsStr = String(format: "%02ld", second)
        self.timeLabel.text = "\(hourStr)小时\(minuteStr)分\(secondsStr)秒"
    }
    
    deinit {
        Gatling.sharedGatling.stopShootingTarget(self)
    }

    fileprivate lazy var timeLabel:UILabel = {
        let label = UILabel()
        label.textColor = UIColor.blue
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()

}

// MARK:
extension ViewController: GatlingTarget {
    func shotWithBullet(_ bullet: Bullet?, ofGatling gatling: Gatling, sleepTime: TimeInterval) {
        timeChange(sleepTime: sleepTime)
    }
}


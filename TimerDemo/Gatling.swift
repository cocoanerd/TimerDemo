//
//  Timer.swift
//  TimerDemo
//
//  Created by mmh on 2020/3/23.
//  Copyright © 2020 mmh. All rights reserved.
//

import Foundation

public typealias Bullet = [String: AnyObject]


@objc
public protocol GatlingTarget: NSObjectProtocol {
    /// 实现其中一个即可
    @objc optional func shotWithBullet(_ bullet: Bullet?, ofGatling gatling: Gatling)
    /// 实现其中一个即可
    @objc optional func shotWithBullet(_ bullet: Bullet?, ofGatling gatling: Gatling, sleepTime: TimeInterval)
}


public class Gatling: NSObject {
    
    fileprivate var timer: Timer?
    fileprivate var missions: [Mission] = [Mission]()
    
    @objc public class var sharedGatling: Gatling {
        struct Singleton {
            static let sharedGatling = Gatling()
        }
        
        return Singleton.sharedGatling
    }
    
    
    @objc func timerFired(_ timer: Timer) {
        self.shoot()
    }
    
    
    func shoot() {
        self.missions = self.missions.filter({ (mission: Mission) -> Bool in
            return mission.target.stillAlive()
        })
        
        let now = Date()
        for mission in self.missions {
            let result = mission.timeStrategy.timeToGo(now)
            if result.canGo {
                self.performMission(mission, timeSpace: result.timeSpace)
            }
        }
    }
    
    
    func performMission(_ mission: Mission, timeSpace: TimeInterval) {
        if mission.target.stuff?.shotWithBullet?(mission.bullet, ofGatling: self) == nil {
            mission.target.stuff?.shotWithBullet?(mission.bullet, ofGatling: self, sleepTime: timeSpace)
        }
    }
    
}


// MARK: - Nested classes


extension Gatling {
    
    /// 开启定时器后，将外部代理包装一层
    class Mission {
        let target: WeakStuff<GatlingTarget>
        let bullet: Bullet?
        let timeStrategy: TimeStrategy
        
        init(target: WeakStuff<GatlingTarget>, timeInterval: TimeInterval, needCatchUp: Bool, bullet: Bullet?) {
            self.target = target
            self.bullet = bullet
            self.timeStrategy = TimeStrategy(timeInterval: timeInterval, needCatchUp: needCatchUp)
        }
    }
    
    
    /// 记录时间间隔 和 下一次时间
    class TimeStrategy {
        let startDate: Date
        let timeInterval: TimeInterval
        /// 是否需要追上当前时间，例：进入后台，倒计时停止的时间段
        var needCatchUp: Bool

        fileprivate var nextFireDate: Date
        
        init(timeInterval: TimeInterval, needCatchUp: Bool) {
            self.needCatchUp = needCatchUp
            let now = Date()
            self.startDate = now
            self.timeInterval = timeInterval
            self.nextFireDate = now.addingTimeInterval(timeInterval)
        }
        
        func timeToGo(_ date: Date) -> (canGo: Bool, timeSpace: TimeInterval) {
            var canGo = false
            var timeSpace: TimeInterval = 0
            if date.laterThan(self.nextFireDate)||(date == self.nextFireDate)  {
                if needCatchUp {
                    let space = date.timeIntervalSince(self.nextFireDate)
                    /// 如果时间间隔大于 定时器的事件间隔 需要追上时间
                    if space > self.timeInterval {
                        timeSpace = space
                        self.nextFireDate = date
                    } else {
                        timeSpace = 0
                    }
                }
                self.nextFireDate = self.nextFireDate.addingTimeInterval(self.timeInterval)
                canGo = true
            }
            
            return (canGo, timeSpace)
        }
    }
    
}


// MARK: - APIs


@objc extension Gatling {
    
    /// 开启定时器
    public func loadWithTarget(_ target: GatlingTarget, timeInterval: TimeInterval, shootsImmediately: Bool, bullet: Bullet? = nil) {
        self.loadWithTarget(target, timeInterval: timeInterval, shootsImmediately: shootsImmediately, needCatchUp: false, bullet: bullet)
    }
    
    public func loadWithTarget(_ target: GatlingTarget, timeInterval: TimeInterval, shootsImmediately: Bool, needCatchUp: Bool, bullet: Bullet? = nil) {
        if self.timer == nil {
            let timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerFired(_:)), userInfo: nil, repeats: true)
            RunLoop.current.add(timer, forMode: RunLoop.Mode.common);
            self.timer = timer
        }
        
        let mission = Mission(target: WeakStuff(stuff: target), timeInterval: timeInterval, needCatchUp: needCatchUp, bullet: bullet)
        self.missions.append(mission)
        if shootsImmediately {
            self.performMission(mission, timeSpace: 0)
        }
    }
    
    /// 关闭定时器
    public func stopShootingTarget(_ target: GatlingTarget) {
        self.missions = self.missions.filter({ (mission: Mission) -> Bool in
            if !mission.target.stillAlive() {
                return false
            }
            
            // TODO: use a safe identifier
            if Unmanaged.passUnretained(mission.target.stuff!).toOpaque() != Unmanaged.passUnretained(target).toOpaque() {
                return true
            }
            
            return false
        })
    }
    
    
}

class WeakStuff<T: AnyObject> {
    
    weak var stuff: T?
    
    init(stuff: T) {
        self.stuff = stuff
    }
    
    func stillAlive() -> Bool {
        if self.stuff == nil {
            return false
        }
        
        return true
    }
    
}

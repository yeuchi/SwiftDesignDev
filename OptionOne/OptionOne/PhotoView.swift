//
//  PhotoView.swift
//  SwiftDesignDev10
//
//  Created by yeuchi on 6/12/20.
//  Copyright © 2020 yeuchi. All rights reserved.
//

import UIKit

class PhotoView: UIImageView {
    var lastTouchTime:NSDate? = nil
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if let touch = touches.first {
            let location = touch.location(in: self)
            print("x:\(location.x) y:\(location.y)")
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
       super.touchesCancelled(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
       super.touchesEnded(touches, with: event)
        
        let currentTime = NSDate()
        if let previousTime = lastTouchTime {
            
            let diff = currentTime.timeIntervalSince(previousTime as Date)
            if  diff < 0.5 {
                print("Double Tap!")
                
                lastTouchTime = nil
            }
            else {
                lastTouchTime = currentTime
            }
        }
        else {
            lastTouchTime = currentTime
        }
    }

}

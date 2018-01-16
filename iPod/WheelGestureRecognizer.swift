//
//  WheelGestureRecognizer.swift
//  iPod
//
//  Created by Jonathan French on 05/12/2016.
//  Copyright © 2016 Jonathan French. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass

class WheelGestureRecognizer: UIGestureRecognizer {

    public var currentAngle : Float = 0.0
    public var previousAngle : Float = 0.0
    public var touchFrame : UIView!
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent)
    {
        super.touchesBegan(touches, with: event)
        if (touches.count > 1)
        {
            self.state = UIGestureRecognizerState.failed
            return
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent)
    {
        super.touchesEnded(touches, with: event)
        self.state = UIGestureRecognizerState.ended
    }
    
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent)
    {
        super.touchesCancelled(touches, with: event)
        self.state = UIGestureRecognizerState.cancelled
    }
    
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent)
    {
        super.touchesMoved(touches, with: event)
        // 1
        if state == .failed {
            return
        }
        
        // 2
        //let window = view?.window
        let touch = touches.first
        let loc = touch?.location(in: touchFrame)
        let pre = touch?.previousLocation(in: touchFrame)

        currentAngle = StaticFunctions.getTouchAngle(touch: loc!, frame : touchFrame.frame)
        previousAngle = StaticFunctions.getTouchAngle(touch: pre!, frame : touchFrame.frame)

        state = .changed
    }

    
}

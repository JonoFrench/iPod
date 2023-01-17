//
//  StaticFunctions.swift
//  Animations
//
//  Created by Jonathan French on 04/07/2016.
//  Copyright © 2016 Jonathan French. All rights reserved.
//

import UIKit

class StaticFunctions {
  
    static let NSEC_PER_SEC:Int = 1000000000

    
    static func blaf()
    {
        
    }
    
    static func delay(_ delay:Double, closure:@escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
//    static func delay(delay:Double, closure:()->()) {
//        dispatch_time(
//            dispatch_time_t(DISPATCH_TIME_NOW),
//            Int64(delay * Double(NSEC_PER_SEC))
//            ).after(
//                when: dispatch_get_main_queue(), execute: closure)
//    }
    
    static func toRadian(value: Int) -> CGFloat {
        return CGFloat(Double(value) / 180.0 * M_PI)
    }
    
    static func yRotation(angle:CGFloat) -> CATransform3D
    {
        return CATransform3DMakeRotation(angle,0.0, 1.0, 0.0)
    }
    
    static func perspectiveTransformForContainerView(containerView:UIView)
    {
        var perspectiveTransform = CATransform3DIdentity
        perspectiveTransform.m34 = 1 / -900
        containerView.layer.sublayerTransform = perspectiveTransform
    }
    
    static func getTouchAngle( touch : CGPoint, frame : CGRect) -> Float {
        
        // Translate into cartesian space with origin at the center of the frame
        let x : CGFloat = touch.x - CGFloat(frame.width/2)
        let y : CGFloat = -(touch.y - CGFloat(frame.height/2))
        
        // Take care not to divide by zero!
        if (y == 0) {
            if (x > 0) {
                return Float(M_PI_2)
            }
            else {
                return 3 * Float(M_PI_2)
            }
        }
        
        let arctan = atanf(Float(x) / Float(y))
        
        // Figure out which quadrant we're in
        
        // Quadrant I
        if ((x >= 0) && (y > 0)) {
            //print("Quadrant I")
            return arctan
        }
            // Quadrant II
        else if ((x < 0) && (y > 0)) {
            //print("Quadrant II")
            return arctan + Float(2 * M_PI)
        }
            // Quadrant III
        else if ((x <= 0) && (y < 0)) {
            //print("Quadrant III")
            return arctan + Float(M_PI)
        }
            // Quadrant IV
        else if ((x > 0) && (y < 0)) {
            //print("Quadrant IV")
            return arctan + Float(M_PI)
        }
        
        return -1;
    }
    
    
}

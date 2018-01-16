//
//  UIExtensions.swift
//  Animations
//
//  Created by Jonathan French on 21/05/2016.
//  Copyright © 2016 Jonathan French. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func Shake()
    {
        StaticFunctions.perspectiveTransformForContainerView(containerView: self)
        
        let translation = CAKeyframeAnimation(keyPath: "transform.translation.x");
        translation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        translation.values = [-5, 5, -5, 5, -3, 3, -2, 2, 0]
 
        let rotation = CAKeyframeAnimation(keyPath: "transform.translation.y");

        rotation.values = [-5, 5, -5, 5, -3, 3, -2, 2, 0].map {
            StaticFunctions.toRadian(value: $0)
        }
        
        let shakeGroup: CAAnimationGroup = CAAnimationGroup()
        shakeGroup.animations = [translation, rotation]
        shakeGroup.duration = 0.6
        self.layer.add(shakeGroup, forKey: "shakeIt")
    }
    
    func animateToAngle(angle: Int, duration: TimeInterval, spring: CGFloat)
    {
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: spring, initialSpringVelocity: 0.2, options: UIViewAnimationOptions.allowAnimatedContent, animations: {
            let transform = CATransform3DIdentity
            self.layer.transform = CATransform3DRotate(transform, StaticFunctions.toRadian(value: angle),1.0,0.0,0.0)
            }, completion: nil)
    }
 
    func animateToAngle(angle: Int, duration: TimeInterval, container: UIView)
    {
        container.layer.zPosition = 0
        self.layer.zPosition = 100
        StaticFunctions.perspectiveTransformForContainerView(containerView: container)

        UIView.animate(withDuration: duration, animations: {
            var transform = CATransform3DIdentity
            transform.m34 = 1.0 / -900
            
            self.layer.transform = CATransform3DRotate(transform, StaticFunctions.toRadian(value: angle),1.0,0.0,0.0)
        }
        )
    }
    
    func setToAngle(angle: Int, container: UIView)
    {
            StaticFunctions.perspectiveTransformForContainerView(containerView: container)
            var transform = CATransform3DIdentity
            transform.m34 = 1.0 / -900
            
            self.layer.transform = CATransform3DRotate(transform, StaticFunctions.toRadian(value: angle),1.0,0.0,0.0)

    }
    
    func rotateToAngle(angle: Int)
    {
        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.2, options: UIViewAnimationOptions.allowAnimatedContent, animations: {
            let transform = CATransform3DIdentity
            self.layer.transform = CATransform3DRotate(transform, StaticFunctions.toRadian(value: angle),0.0,0.0,1.0)
            }, completion: nil)
    }
    
    
    func tapFunction (myTarget: AnyObject, selector: Selector)
    {
        //let selector = #selector(f?())
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: myTarget, action: selector)
        self.addGestureRecognizer(tapGesture)
    }
    
    func bounceCenter()
    {
        print("bounceCenter")
        self.layer.zPosition = 200
        UIView.animate(withDuration: 0.25, animations: {
            //self.contentScaleFactor = 0.75
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { (Bool) in
            UIView.animate(withDuration: 0.25, animations: {
                //self.contentScaleFactor = 1.0
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: nil)
        })
    }
    
    func bounceLeft(container: UIView)
    {
        container.layer.zPosition = 0
        self.layer.zPosition = 100
        UIView.animate(withDuration: 0.25, animations: {
            let transform = CATransform3DIdentity
            self.layer.transform = CATransform3DRotate(transform, StaticFunctions.toRadian(value: -10),0.0,1.0,0.0)
        }, completion: { (Bool) in
            UIView.animate(withDuration: 0.25, animations: {
                let transform = CATransform3DIdentity
                self.layer.transform = CATransform3DRotate(transform, StaticFunctions.toRadian(value: 0),0.0,1.0,0.0)

            }, completion: nil)
        })
    }
    
    
    func bounceRight(container: UIView)
    {
        container.layer.zPosition = 0
        self.layer.zPosition = 100
        UIView.animate(withDuration: 0.25, animations: {
            let transform = CATransform3DIdentity
            self.layer.transform = CATransform3DRotate(transform, StaticFunctions.toRadian(value: 10),0.0,1.0,0.0)
        }, completion: { (Bool) in
            UIView.animate(withDuration: 0.25, animations: {
                let transform = CATransform3DIdentity
                self.layer.transform = CATransform3DRotate(transform, StaticFunctions.toRadian(value: 0),0.0,1.0,0.0)
                
            }, completion: nil)
        })
    }
    
    
    func bounceTop(container: UIView)
    {
        container.layer.zPosition = 0
        self.layer.zPosition = 100
        UIView.animate(withDuration: 0.25, animations: {
            let transform = CATransform3DIdentity
            self.layer.transform = CATransform3DRotate(transform, StaticFunctions.toRadian(value: 10),1.0,0.0,0.0)
        }, completion: { (Bool) in
            UIView.animate(withDuration: 0.25, animations: {
                let transform = CATransform3DIdentity
                self.layer.transform = CATransform3DRotate(transform, StaticFunctions.toRadian(value: 0),1.0,0.0,0.0)
                
            }, completion: nil)
        })
    }
    
    func bounceBottom(container: UIView)
    {
        container.layer.zPosition = 0
        self.layer.zPosition = 100
        UIView.animate(withDuration: 0.25, animations: {
            let transform = CATransform3DIdentity
            self.layer.transform = CATransform3DRotate(transform, StaticFunctions.toRadian(value: -10),1.0,0.0,0.0)
        }, completion: { (Bool) in
            UIView.animate(withDuration: 0.25, animations: {
                let transform = CATransform3DIdentity
                self.layer.transform = CATransform3DRotate(transform, StaticFunctions.toRadian(value: 0),1.0,0.0,0.0)
                
            }, completion: nil)
        })
    }
}

extension UIButton {
    
    func flipToTitle(text:String)
    {
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.allowAnimatedContent, animations: {
            let transform = CATransform3DIdentity
            self.layer.transform = CATransform3DRotate(transform, StaticFunctions.toRadian(value: -90),1.0,0.0,0.0)
            }, completion: { (Bool) in
                UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.allowAnimatedContent, animations: {
                    self.setTitle(text, for: UIControlState.normal)
                    let transform = CATransform3DIdentity
                    self.layer.transform = CATransform3DRotate(transform, StaticFunctions.toRadian(value: 0),1.0,0.0,0.0)
                    }, completion: nil)
        })
        
    }
    
    func animateTitleIn(text:String, direction:String, color:UIColor? )
    {
        let transition: CATransition = CATransition.init()
        transition.type = kCATransitionPush
        transition.subtype = direction
        transition.duration = 0.5
        self.titleLabel?.layer.add(transition, forKey: "CATransition")
        self.setTitle(text, for: UIControlState.normal)
        if color != nil {self.setTitleColor(color, for: UIControlState.normal)}
    }
   
    func animateAttributedTitleIn(text:NSAttributedString, direction:String)
    {
        let transition: CATransition = CATransition.init()
        transition.type = kCATransitionPush
        transition.subtype = direction
        transition.duration = 0.5
        self.titleLabel?.layer.add(transition, forKey: "CATransition")
        self.setAttributedTitle(text, for: UIControlState.normal)
    }
    
}


extension UILabel {
    
    func flipToText(text:String)
    {
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.allowAnimatedContent, animations: {
            let transform = CATransform3DIdentity
            self.layer.transform = CATransform3DRotate(transform, StaticFunctions.toRadian(value: -90),1.0,0.0,0.0)
            }, completion: { (Bool) in
                UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.allowAnimatedContent, animations: {
                    self.text = text
                    let transform = CATransform3DIdentity
                    self.layer.transform = CATransform3DRotate(transform, StaticFunctions.toRadian(value: 0),1.0,0.0,0.0)
                    }, completion: nil)
        })
        
    }
    
    func animateTextIn(text:String, direction:String, color:UIColor? )
    {
        let transition: CATransition = CATransition.init()
        transition.type = kCATransitionPush
        transition.subtype = direction
        transition.duration = 0.5
        self.layer.add(transition, forKey: "CATransition")
        self.text = text
        if color != nil { self.textColor = color}
    }
    
    func animateAttributedTextIn(text:NSAttributedString, direction:String)
    {
        let transition: CATransition = CATransition.init()
        transition.type = kCATransitionPush
        transition.subtype = direction
        transition.duration = 0.5
        self.layer.add(transition, forKey: "CATransition")
        self.attributedText = text
    }
    
    func willBeTruncated() -> Bool {
        let label:UILabel = UILabel(frame: CGRect(x: 0,y: 0,width: self.bounds.width,height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = self.font
        label.text = self.text
        label.sizeToFit()
        if label.frame.height > self.frame.height {
            return true
        }
        return false
    }
    
}

 //.filter({$0.isUserInteractionEnabled})
extension UITabBarController {
    
    func tabBarItemViews() -> [UIView] {
        let tabViews = tabBar.subviews
        for object in tabViews {
         print ("tab view \(object.description) \(object.layer.frame)")
        }
        return tabViews.sorted(by: {$0.frame.minX < $1.frame.minX})
    }
    
    func tabBarView(tab: Int) -> UIView {
        var tabViews = tabBar.subviews.filter({$0.isUserInteractionEnabled})
        tabViews = tabViews.sorted(by: {$0.frame.minX < $1.frame.minX})
        print (tabViews[tab].frame)
        return tabViews[tab]
    }
}


extension Int {
    func format(f: String) -> String {
        return String(format: "%\(f)d", self)
    }
}

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}


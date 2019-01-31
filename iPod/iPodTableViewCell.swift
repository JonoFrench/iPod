//
//  iPodTableViewCell.swift
//  iPod
//
//  Created by Jonathan French on 05/12/2016.
//  Copyright © 2016 Jonathan French. All rights reserved.
//

import UIKit
import MediaPlayer

class iPodTableViewCell: UITableViewCell {

    
    public var mpMedaItem = MPMediaItem()
    var timer = Timer()
    var originalString = String()
    var scrollString = String()
    var scrollPos : Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    override func prepareForReuse() {
        self.backgroundColor = UIColor.white
        self.textLabel?.textColor = UIColor.black
        self.isSelected = false
        self.selectionStyle = UITableViewCellSelectionStyle.none
        timer.invalidate()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.layoutIfNeeded()
        //print("setSelected \(self.textLabel?.frame)")
        
//        guard (self.textLabel?.frame.width)! > 0 else {
//            return
//        }
        timer.invalidate()

        if (selected){
        // Configure the view for the selected state
            if #available(iOS 10.0, *) {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                
            }
        self.backgroundColor = UIColor.blue
        self.textLabel?.textColor = UIColor.white
            
        //print("Needs Truncating \(self.textLabel?.text) \(self.textLabel?.willBeTruncated())")
            if (self.textLabel?.willBeTruncated())!
            {
                timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(iPodTableViewCell.scrollText), userInfo: nil, repeats: true)
            timer.fire()
            }
            
        } else{
            print("unselecting")
            self.textLabel?.text? = originalString
            self.backgroundColor = UIColor.white
            self.textLabel?.textColor = UIColor.black
//            self.setNeedsDisplay()
        }
    }
    
    
    public func configure( label: String )
    {
        timer.invalidate()
        scrollPos = 0
        originalString = label
        self.textLabel?.font = UIFont(name: "ChicagoFLF", size: 16.0)
        self.backgroundColor = UIColor.white
        self.textLabel?.textColor = UIColor.black
        self.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.textLabel?.lineBreakMode = NSLineBreakMode.byClipping
        self.setNeedsDisplay()
    }
    
    public func configure()
    {
        timer.invalidate()
        scrollPos = 0
        originalString = (self.textLabel?.text)!
        self.textLabel?.font = UIFont(name: "ChicagoFLF", size: 16.0)
        self.backgroundColor = UIColor.white
        self.textLabel?.textColor = UIColor.black
        self.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.textLabel?.lineBreakMode = NSLineBreakMode.byClipping
        self.setNeedsDisplay()
    }
    public func configure(mediaItem : MPMediaItem)
    {
        self.mpMedaItem = mediaItem
        configure()
    }
    
    func scrollText()
    {
        let index1 = originalString.index(originalString.startIndex, offsetBy: scrollPos)
        scrollString = originalString.substring(from: index1) + " " + originalString.substring(to: index1)
        self.textLabel?.text? = scrollString
        scrollPos += 1
        if scrollPos > originalString.characters.count
        {
            scrollPos = 0
        }
    }
    
}

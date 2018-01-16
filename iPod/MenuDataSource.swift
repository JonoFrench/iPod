//
//  MenuDataSource.swift
//  iPod
//
//  Created by Jonathan French on 16/12/2016.
//  Copyright © 2016 Jonathan French. All rights reserved.
//

import UIKit
import MediaPlayer

class MenuDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    
    public var MenuItems: [String]?
    public var count : Int = 0
    public var selectedRow : Int = 0
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (MenuItems?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : iPodTableViewCell = tableView.dequeueReusableCell(withIdentifier: "iPodTableViewCell", for: indexPath as IndexPath) as! iPodTableViewCell
        //let artist = artists?[indexPath.row]

        return cell
    }
  
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let c : iPodTableViewCell = cell as! iPodTableViewCell
        let menuItem = MenuItems?[indexPath.row]
        c.textLabel?.text =  menuItem
        c.configure()
        if indexPath.row == selectedRow {
            c.setSelected(true, animated: false)
        }
        
    }
    
}

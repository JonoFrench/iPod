//
//  PlaylistDataSource.swift
//  iPod
//
//  Created by Jonathan French on 25/07/2017.
//  Copyright © 2017 Jonathan French. All rights reserved.
//

import UIKit

import UIKit
import MediaPlayer

class PlaylistDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    
    public var playlistItems: [MPMediaItem] = []
    public var count : Int = 0
    public var selectedRow : Int = 0
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlistItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : iPodTableViewCell = tableView.dequeueReusableCell(withIdentifier: "iPodTableViewCell", for: indexPath as IndexPath) as! iPodTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let c : iPodTableViewCell = cell as! iPodTableViewCell
        let playlistItem = playlistItems[indexPath.row]
        c.textLabel?.text =  playlistItem.artist! + " " + playlistItem.title!
        c.configure(mediaItem: playlistItem)
        
        if indexPath.row == selectedRow {
            c.setSelected(true, animated: false)
        }
        
    }
}

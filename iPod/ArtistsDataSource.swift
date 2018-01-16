//
//  iPodDataSource.swift
//  iPod
//
//  Created by Jonathan French on 05/12/2016.
//  Copyright © 2016 Jonathan French. All rights reserved.
//

import UIKit
import MediaPlayer

class ArtistsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    
    public var artistItems: [MPMediaItem]?
    public var count : Int = 0
    public var selectedRow : Int = 0

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (artistItems?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : iPodTableViewCell = tableView.dequeueReusableCell(withIdentifier: "iPodTableViewCell", for: indexPath as IndexPath) as! iPodTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let c : iPodTableViewCell = cell as! iPodTableViewCell
        let artistItem = artistItems?[indexPath.row]
        c.textLabel?.text =  artistItem?.albumArtist //  .artist! // + " " + artist.albumTitle!
        c.configure(mediaItem: artistItem!)
        
        if indexPath.row == selectedRow {
            c.setSelected(true, animated: false)
        }
        
    }
}

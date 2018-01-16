//
//  iPodDataSource.swift
//  iPod
//
//  Created by Jonathan French on 05/12/2016.
//  Copyright © 2016 Jonathan French. All rights reserved.
//

import UIKit
import MediaPlayer

class TracksDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    
    public var tracks : [MPMediaItem] = []
    public var count : Int = 0
    public var selectedRow : Int = 0
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tracks.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : iPodTableViewCell = tableView.dequeueReusableCell(withIdentifier: "iPodTableViewCell", for: indexPath as IndexPath) as! iPodTableViewCell

        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let c : iPodTableViewCell = cell as! iPodTableViewCell
        let track = tracks[indexPath.row]
        c.textLabel?.text =  String(track.albumTrackNumber) + " " + track.title! //  .artist! // + " " + artist.albumTitle!
        c.configure(mediaItem: track)
        
        if indexPath.row == selectedRow {
            c.setSelected(true, animated: false)
        }
        
    }
    
}

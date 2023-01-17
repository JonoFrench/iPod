//
//  ViewController.swift
//  iPod
//
//  Created by Jonathan French on 05/12/2016.
//  Copyright © 2016 Jonathan French. All rights reserved.
//

import UIKit
import MediaPlayer
import AudioToolbox

class iPodViewController: UIViewController,UITableViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var iPodScrollView: UIScrollView!
    @IBOutlet weak var wheelImage: UIImageView!
    @IBOutlet weak var centerButton: UIImageView!
    
    var tblMenu: UITableView!
    var tblArtists: UITableView!
    var tblPlaylists: UITableView!
    var tblAlbums: UITableView!
    var tblTracks: UITableView!
    let player = MPMusicPlayerController.systemMusicPlayer
    var fxplayer: AVAudioPlayer?
    let menuDataSource = MenuDataSource()
    let playlistDataSource = PlaylistDataSource()
    let artistsDataSource = ArtistsDataSource()
    let albumsDataSource = AlbumsDataSource()
    let tracksDataSource = TracksDataSource()
    var wheelRecognizer : WheelGestureRecognizer!
    var centerRecognizer : UITapGestureRecognizer!
    var controlRecognizer : UITapGestureRecognizer!
    var bearing : Float = 0
    var selectedMenuRow : Int = 0
    var selectedArtistRow : Int = 0
    var selectedAlbumRow : Int = 0
    var selectedTrackRow : Int = 0
    var centerView : UIView!
    var playlistView : UIView!
    var artistView : UIView!
    var albumView : UIView!
    var trackView : UIView!
    var playingView : UIView!
    var aboutView : UIView!
    var artists = Set<String>()
    var currentPage : iPodPage = iPodPage.MenuPage
    var menuView : UIView!
    var nowPlaying : UIView!
    var nowPlayingCover : UIImageView!
    var nowPlayingArtist : UILabel!
    var nowPlayingAlbum : UILabel!
    var nowPlayingTrack : UILabel!
    var nowPlayingTrackTime : UILabel!
    var nowPlayingTrackCurrent : UILabel!
    var nowPlayingPlayPause : UIImageView!
    var trackPosBack : UIView!
    var trackPosFront : UIView!
    var oldSector : Int = -1
    var playingTimer : Timer!
    var activityTimer : Timer!
    var url : URL!
    var playViewLength : CGFloat = 0.0
    let headerHeight : CGFloat = 30
    var frameWidth : CGFloat = 0.0
    var frameHeight : CGFloat = 0.0
    var fullFrameHeight : CGFloat = 0.0
    var playMode : PlayMode!// = PlayMode.Track
    var aboutText : UITextView!
    var aboutPos : CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        UIFont.familyNames.map {UIFont.fontNames(forFamilyName: $0)}
//            .forEach {(n:[String]) in n.forEach {print($0)}}
        
        setNeedsStatusBarAppearanceUpdate()
        url = Bundle.main.url(forResource: "clicksound", withExtension: "mp3")!
        do {
        self.fxplayer = try AVAudioPlayer(contentsOf: self.url)
        } catch {
            
        }
        fxplayer?.prepareToPlay()

        player.stop()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(iPodViewController.nowPlayingItemIsChanged),
                                                         name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange,
                                                         object: nil)
        


    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print ("viewWillAppear")
        self.view.layoutIfNeeded()
        frameWidth = iPodScrollView.frame.width
        frameHeight = iPodScrollView.frame.height - headerHeight
        fullFrameHeight = iPodScrollView.frame.height
        setupMenu()
        setupArtists()
        setupAlbums()
        setupTracks()
        setupNowPlaying()
        setupAbout()
        setupiPod()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        //tblMenu.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: UITableViewScrollPosition.top)
        
    }
    
    func addHeader(text: String) -> UILabel
    {
        var header : UILabel!
        header = UILabel(frame: CGRect(x: 0, y: 0, width: frameWidth, height: headerHeight))
        header.text = text
        header.backgroundColor = UIColor.lightGray
        header.font = UIFont(name: "ChicagoFLF", size: 16.0)
        header.textColor = UIColor.black
        header.textAlignment = NSTextAlignment.center
        return header
    }
    
    func setupiPod()
    {
        centerButton.isUserInteractionEnabled = true
        
        //Setup the scroll view
        iPodScrollView.layer.cornerRadius = 10.0
        iPodScrollView.layer.borderColor = UIColor.black.cgColor
        iPodScrollView.layer.borderWidth = 1.0
        iPodScrollView.isUserInteractionEnabled = false
        iPodScrollView.bounces = false
        iPodScrollView.delegate = self

        iPodScrollView.contentSize = CGSize(width: frameWidth * 5, height: fullFrameHeight)
        print ("frameWidth \(frameWidth) iPodScrollView \(iPodScrollView.frame.width)")
        
        iPodScrollView.addSubview(artistView)
        iPodScrollView.addSubview(albumView)
        iPodScrollView.addSubview(trackView)
        iPodScrollView.addSubview(playingView)
        iPodScrollView.addSubview(menuView)
        
        wheelRecognizer = WheelGestureRecognizer(target: self, action: #selector(iPodViewController.wheelMoved))
        wheelRecognizer.touchFrame = wheelImage
        wheelImage.addGestureRecognizer(wheelRecognizer)
        wheelImage.isUserInteractionEnabled = true
        centerView = UIView(frame: CGRect(x:0,y:0,width:88,height:88))
        centerView.backgroundColor = UIColor.clear
        centerView.layer.cornerRadius = 88 / 2
        centerView.isUserInteractionEnabled = true
        controlRecognizer = UITapGestureRecognizer(target: self, action: #selector(iPodViewController.controlTapped))
        controlRecognizer.canPrevent(wheelRecognizer)
        wheelImage.addGestureRecognizer(controlRecognizer)
        
        centerRecognizer = UITapGestureRecognizer(target: self, action: #selector(iPodViewController.centerTapped))
        centerRecognizer.canPrevent(wheelRecognizer)
        centerButton.addGestureRecognizer(centerRecognizer)
        centerButton.addSubview(centerView)
        centerButton.layer.zPosition = 200 //Make sure we are at the top
    }
    
    
    func setupMenu()
    {
        menuView = UIView(frame: CGRect(x: 0, y: 0, width: frameWidth, height: fullFrameHeight))
        tblMenu = UITableView(frame: CGRect(x: 0, y: headerHeight, width: frameWidth, height: frameHeight))
        tblMenu.register( UINib(nibName: "iPodTableViewCell",bundle : nil), forCellReuseIdentifier: "iPodTableViewCell")
        menuDataSource.MenuItems = ["Music","Playlists","Options","About","Shuffle Songs"]
        tblMenu.allowsSelection = true
        tblMenu.allowsMultipleSelection = false
        tblMenu.dataSource = menuDataSource
        tblMenu.delegate = menuDataSource
        tblMenu.rowHeight = 25
        tblMenu.tableFooterView = nil
        tblMenu.isUserInteractionEnabled = false
        tblMenu.separatorStyle = UITableViewCellSeparatorStyle.none
        tblMenu.showsVerticalScrollIndicator = true
        menuDataSource.selectedRow = 0
        selectedMenuRow = 0
        menuView.addSubview(addHeader(text: "iPod"))
        menuView.addSubview(tblMenu)
        tblMenu.selectRow(at: IndexPath(row: selectedMenuRow, section: 0), animated: false, scrollPosition: UITableViewScrollPosition.middle)
    }
 
    func setupPlaylists()
    {
        playlistDataSource.playlistItems = getPlaylists()
        playlistView = UIView(frame: CGRect(x:frameWidth, y: 0, width: frameWidth, height: fullFrameHeight))
        tblPlaylists = UITableView(frame: CGRect(x: 0, y: headerHeight, width: frameWidth, height: frameHeight))
        tblPlaylists.register( UINib(nibName: "iPodTableViewCell",bundle : nil), forCellReuseIdentifier: "iPodTableViewCell")
        tblPlaylists.allowsSelection = true
        tblPlaylists.dataSource = playlistDataSource
        tblPlaylists.delegate = playlistDataSource
        tblPlaylists.rowHeight = 25
        tblPlaylists.tableFooterView = nil
        tblPlaylists.reloadData()
        tblPlaylists.isUserInteractionEnabled = false
        tblPlaylists.separatorStyle = UITableViewCellSeparatorStyle.none
        tblPlaylists.showsVerticalScrollIndicator = true
        playlistView.addSubview(addHeader(text: "Playlists"))
        playlistView.addSubview(tblPlaylists)
        iPodScrollView.addSubview(playlistView)
    }
    
    func setupArtists()
    {
        artistsDataSource.artistItems = getArtists()
        artistView = UIView(frame: CGRect(x:frameWidth, y: 0, width: frameWidth, height: fullFrameHeight))
        tblArtists = UITableView(frame: CGRect(x: 0, y: headerHeight, width: frameWidth, height: frameHeight))
        tblArtists.register( UINib(nibName: "iPodTableViewCell",bundle : nil), forCellReuseIdentifier: "iPodTableViewCell")
        tblArtists.allowsSelection = true
        tblArtists.dataSource = artistsDataSource
        tblArtists.delegate = artistsDataSource
        tblArtists.rowHeight = 25
        tblArtists.tableFooterView = nil
        tblArtists.isUserInteractionEnabled = false
        tblArtists.separatorStyle = UITableViewCellSeparatorStyle.none
        tblArtists.showsVerticalScrollIndicator = true
        artistsDataSource.selectedRow = 0
        selectedArtistRow = 0
        artistView.addSubview(addHeader(text: "Artists"))
        artistView.addSubview(tblArtists)
        tblArtists.selectRow(at: IndexPath(row: selectedArtistRow, section: 0), animated: false, scrollPosition: UITableViewScrollPosition.middle)
    }
    
    func setupAlbums()
    {
        albumView = UIView(frame: CGRect(x: frameWidth * 2, y: 0, width: frameWidth, height: iPodScrollView.frame.height))
        tblAlbums = UITableView(frame: CGRect(x: 0, y: headerHeight, width: frameWidth, height: frameHeight))
        tblAlbums.register( UINib(nibName: "iPodTableViewCell",bundle : nil), forCellReuseIdentifier: "iPodTableViewCell")
        tblAlbums.allowsSelection = true
        tblAlbums.dataSource = albumsDataSource
        tblAlbums.delegate = albumsDataSource
        albumsDataSource.selectedRow = 0
        selectedAlbumRow = 0
        tblAlbums.rowHeight = 25
        tblAlbums.tableFooterView = nil
        tblAlbums.isUserInteractionEnabled = false
        tblAlbums.separatorStyle = UITableViewCellSeparatorStyle.none
        tblAlbums.setNeedsLayout()
        albumView.addSubview(addHeader(text: "Albums"))
        albumView.addSubview(tblAlbums)
    }
    
    func setupTracks()
    {
        trackView = UIView(frame: CGRect(x: frameWidth * 3, y: 0, width: frameWidth, height: iPodScrollView.frame.height))
        tblTracks = UITableView(frame: CGRect(x: 0, y: headerHeight, width: frameWidth, height: frameHeight))
        tblTracks.register( UINib(nibName: "iPodTableViewCell",bundle : nil), forCellReuseIdentifier: "iPodTableViewCell")
        tblTracks.allowsSelection = true
        tblTracks.dataSource = tracksDataSource
        tblTracks.delegate = tracksDataSource
        tblTracks.rowHeight = 25
        tblTracks.tableFooterView = nil
        tblTracks.isUserInteractionEnabled = false
        tblTracks.separatorStyle = UITableViewCellSeparatorStyle.none
        tblTracks.reloadData()
        trackView.addSubview(addHeader(text: "Tracks"))
        trackView.addSubview(tblTracks)
    }
    
    func setupNowPlaying()
    {
        playingView = UIView(frame: CGRect(x: frameWidth * 4, y: 0, width: frameWidth, height: iPodScrollView.frame.height))
        
        nowPlaying = UIView(frame: CGRect(x: 0, y: headerHeight , width: frameWidth, height: frameHeight))
        nowPlaying.backgroundColor = UIColor.white
        
        nowPlayingCover = UIImageView(frame: CGRect(x: 10, y: 20, width: 80, height: 80))
        
        nowPlayingArtist = UILabel(frame: CGRect(x: 100, y: 20, width: 180, height: 25))
        //nowPlayingArtist.backgroundColor = UIColor.gray
        nowPlayingArtist.font = UIFont(name: "ChicagoFLF", size: 16.0)
        nowPlayingArtist.textAlignment = NSTextAlignment.left
        nowPlayingArtist.textColor = UIColor.black
        
        nowPlayingTrack = UILabel(frame: CGRect(x: 100, y: 50, width: 180, height: 25))
        //nowPlayingTrack.backgroundColor = UIColor.gray
        nowPlayingTrack.font = UIFont(name: "ChicagoFLF", size: 16.0)
        nowPlayingTrack.textAlignment = NSTextAlignment.left
        nowPlayingTrack.textColor = UIColor.black
        
        nowPlayingAlbum = UILabel(frame: CGRect(x: 100, y: 80, width: 180, height: 25))
        //nowPlayingAlbum.backgroundColor = UIColor.gray
        nowPlayingAlbum.font = UIFont(name: "ChicagoFLF", size: 16.0)
        nowPlayingAlbum.textAlignment = NSTextAlignment.left
        nowPlayingAlbum.textColor = UIColor.black
        
        nowPlayingTrackTime = UILabel(frame: CGRect(x: 10, y: 180, width: 60, height: 25))
        //nowPlayingTrackTime.backgroundColor = UIColor.gray
        nowPlayingTrackTime.font = UIFont(name: "ChicagoFLF", size: 10.0)
        nowPlayingTrackTime.textAlignment = NSTextAlignment.left
        nowPlayingTrackTime.textColor = UIColor.black
        
        nowPlayingTrackCurrent = UILabel(frame: CGRect(x: frameWidth - 70, y: 180, width: 60, height: 25))
        //nowPlayingTrackCurrent.backgroundColor = UIColor.gray
        nowPlayingTrackCurrent.font = UIFont(name: "ChicagoFLF", size: 10.0)
        nowPlayingTrackCurrent.textAlignment = NSTextAlignment.right
        nowPlayingTrackCurrent.textColor = UIColor.black
 
        nowPlayingPlayPause = UIImageView(frame: CGRect(x: 10, y: 5, width: 20, height: 20))
        //nowPlayingTrack.backgroundColor = UIColor.gray
        //nowPlayingPlayPause.font = UIFont(name: "Symbol", size: 20.0)
        nowPlayingPlayPause.image = UIImage(imageLiteralResourceName: "playButton")

        
        
        let tpWidth = frameWidth - 120
        trackPosBack = UIView(frame: CGRect(x: 60, y: 180, width: tpWidth, height: 25))
        trackPosFront = UIView(frame: CGRect(x: 61, y: 190, width: 1, height: 5))
        trackPosBack.backgroundColor = UIColor.lightGray
        trackPosBack.layer.borderColor = UIColor.black.cgColor
        trackPosBack.layer.borderWidth = 1.0
        trackPosBack.layer.cornerRadius = 10
        trackPosFront.backgroundColor = UIColor.blue
        
        nowPlaying.addSubview(nowPlayingAlbum)
        nowPlaying.addSubview(nowPlayingCover)
        nowPlaying.addSubview(nowPlayingTrack)
        nowPlaying.addSubview(nowPlayingArtist)
        nowPlaying.addSubview(nowPlayingTrackTime)
        nowPlaying.addSubview(nowPlayingTrackCurrent)
        nowPlaying.addSubview(trackPosBack)
        nowPlaying.addSubview(trackPosFront)
        
        playingView.addSubview(addHeader(text: "Now Playing"))
        playingView.addSubview(nowPlaying)
        playingView.addSubview(nowPlayingPlayPause)
    }
    
    func setupAbout()
    {
        aboutView = UIView(frame: CGRect(x:frameWidth, y: 0, width: iPodScrollView.frame.width, height: iPodScrollView.frame.height))
        
        aboutView.backgroundColor = UIColor.white
        aboutText = UITextView(frame: CGRect(x: 10, y: headerHeight, width: frameWidth - 20, height: frameHeight))

        aboutText.isUserInteractionEnabled = false
        aboutText.showsVerticalScrollIndicator = true
        aboutText.font = UIFont(name: "ChicagoFLF", size: 14.0)
        aboutText.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc fermentum non dui non posuere. Cras sed consequat erat, nec commodo magna. Vestibulum vitae ante non lacus pellentesque pharetra nec eget metus. In volutpat facilisis sem sit amet pharetra. Donec ac elit tortor. Aenean laoreet, magna at molestie porttitor, libero urna mattis est, in elementum sem nulla ut dui. Curabitur dictum condimentum lectus in bibendum. Curabitur dapibus, justo a gravida feugiat, elit arcu iaculis nisl cras amet. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc fermentum non dui non posuere. Cras sed consequat erat, nec commodo magna. Vestibulum vitae ante non lacus pellentesque pharetra nec eget metus. In volutpat facilisis sem sit amet pharetra. Donec ac elit tortor. Aenean laoreet, magna at molestie porttitor, libero urna mattis est, in elementum sem nulla ut dui. Curabitur dictum condimentum lectus in bibendum. Curabitur dapibus, justo a gravida feugiat, elit arcu iaculis nisl cras amet. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc fermentum non dui non posuere. Cras sed consequat erat, nec commodo magna. Vestibulum vitae ante non lacus pellentesque pharetra nec eget metus. In volutpat facilisis sem sit amet pharetra. Donec ac elit tortor. Aenean laoreet, magna at molestie porttitor, libero urna mattis est, in elementum sem nulla ut dui. Curabitur dictum condimentum lectus in bibendum. Curabitur dapibus, justo a gravida feugiat, elit arcu iaculis nisl cras amet."
        
        aboutView.addSubview(aboutText)
        aboutView.addSubview(addHeader(text: "About"))
        aboutPos = 0.0
    }
    
    @objc func centerTapped(t: UITapGestureRecognizer)
    {
        print("center Tapped")
        setInactivityTimer()
        centerButton.bounceCenter()
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
        } else {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
        
        switch currentPage {
            
        case .AboutPage:
            break
        case .PlaylistPage:
            break
        case .MenuPage:

            if selectedMenuRow == 0
            {
                currentPage = .ArtistsPage
                iPodScrollView.scrollRectToVisible(CGRect(x: frameWidth, y: 0, width: frameWidth, height: iPodScrollView.frame.height), animated: true)
               
            }

            if selectedMenuRow == 1
            {
                setupPlaylists()
                currentPage = .PlaylistPage
                tblPlaylists.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: UITableViewScrollPosition.none)
                iPodScrollView.scrollRectToVisible(CGRect(x: frameWidth, y: 0, width: frameWidth, height: iPodScrollView.frame.height), animated: true)
                
            }

            
            if selectedMenuRow == 3
            {
                currentPage = .AboutPage
                iPodScrollView.addSubview(aboutView)
                iPodScrollView.scrollRectToVisible(CGRect(x: frameWidth, y: 0, width: frameWidth, height: iPodScrollView.frame.height), animated: true)
            }
            
            if selectedMenuRow == 4
            {
                shuffleSongs()
            }
            break

        case .AlbumPage:
            let ip : IndexPath = IndexPath(row: selectedAlbumRow, section: 0)
            
            let cell : iPodTableViewCell =  tblAlbums.cellForRow(at: ip) as! iPodTableViewCell
            //print ("Selected Album \(cell.textLabel?.text)")
            tracksDataSource.tracks = getAlbumTracks(albumItem: cell.mpMedaItem)
            tblTracks.reloadData()
            currentPage = .TracksPage
            tblTracks.setNeedsLayout()
            tracksDataSource.selectedRow = 0
            tblTracks.deselectRow(at: IndexPath(row: selectedTrackRow, section: 0), animated: false)
            selectedTrackRow = 0
            tblTracks.selectRow(at: IndexPath(row: selectedTrackRow, section: 0), animated: false, scrollPosition: UITableViewScrollPosition.none)
            iPodScrollView.scrollRectToVisible(CGRect(x: frameWidth * 3, y: 0, width: frameWidth, height: iPodScrollView.frame.height), animated: true)
            break

        case .ArtistsPage:
            
            let ip : IndexPath = IndexPath(row: selectedArtistRow, section: 0)
            
            let cell : iPodTableViewCell =  tblArtists.cellForRow(at: ip) as! iPodTableViewCell
            //print ("Selected Artist \(cell.textLabel?.text)")
            currentPage = .AlbumPage
            tblAlbums.setNeedsLayout()
            albumsDataSource.albums = getArtistAlbums(artistItem: cell.mpMedaItem)
            tblAlbums.reloadData()
            tblAlbums.deselectRow(at: IndexPath(row: selectedAlbumRow, section: 0), animated: false)
            selectedAlbumRow = 0

            tblAlbums.selectRow(at: IndexPath(row: selectedAlbumRow, section: 0), animated: false, scrollPosition: UITableViewScrollPosition.none)
            iPodScrollView.scrollRectToVisible(CGRect(x: frameWidth * 2, y: 0, width: frameWidth, height: iPodScrollView.frame.height), animated: true)
            break

        case .TracksPage:
            break
        case .PlayPage:
            break
        }
    }
    
    
    @objc func controlTapped(t: UITapGestureRecognizer)
    {
        setInactivityTimer()
        //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
        }
        let currentAngle = StaticFunctions.getTouchAngle(touch: t.location(in: wheelImage), frame : wheelImage.frame)
        print("Control Tapped \(currentAngle)")
        
        if (currentAngle >= 5.25 || currentAngle <= 0.75)
        {
            wheelImage.bounceTop(container : self.view)
            var scrollToPage : CGFloat = 0.0
            print("Menu clicked")
            switch currentPage {
            case .AboutPage:
                currentPage = .MenuPage
                scrollToPage = 0.0
                break
            case .PlaylistPage:
                break
            case .MenuPage:
                break
            case .PlayPage:
                switch playMode! {
                case .Shuffle:
                    scrollToPage = 0.0
                    currentPage = .MenuPage
                    break
                case .Track:
                    scrollToPage = 2.0
                    currentPage = .AlbumPage
                    break
                case .Album:
                    scrollToPage = 1.0
                    currentPage = .ArtistsPage
                    break
                }
                break
            case .TracksPage:
                tblTracks.deselectRow(at: IndexPath(row: selectedTrackRow, section: 0), animated: false)
                tblTracks.setNeedsDisplay()
                scrollToPage = 2.0
                currentPage = .AlbumPage
                break
            case .AlbumPage:
                tblAlbums.deselectRow(at: IndexPath(row: selectedAlbumRow, section: 0), animated: false)
                tblAlbums.setNeedsDisplay()
                scrollToPage = 1.0
                currentPage = .ArtistsPage
                break
            case .ArtistsPage:
                scrollToPage = 0.0
                currentPage = .MenuPage
                break
            }
            
            iPodScrollView.scrollRectToVisible(CGRect(x: frameWidth * scrollToPage, y: 0, width: frameWidth, height: iPodScrollView.frame.height), animated: true)
            
        }
        else if (currentAngle >= 0.75 && currentAngle <= 2.25)
        {
            print("Right clicked")
            
            if player.playbackState == MPMusicPlaybackState.playing
            {
                player.skipToNextItem()
            }
            wheelImage.bounceRight(container : self.view)
           
        }
        else if (currentAngle >= 2.25 && currentAngle <= 3.75)
        {
            print("Play clicked")
            wheelImage.bounceBottom(container : self.view)
       
            if currentPage == .PlayPage
            {
            
            if player.playbackState == MPMusicPlaybackState.playing
            {
                player.pause()
                nowPlayingPlayPause.image = UIImage(imageLiteralResourceName: "pauseButton")
                return
            } else if player.playbackState == MPMusicPlaybackState.paused
            {
                player.play()
                nowPlayingPlayPause.image = UIImage(imageLiteralResourceName: "playButton")
                return
            }
            }
            
            player.beginGeneratingPlaybackNotifications()
           
            
            if currentPage == .AlbumPage
            {
                playMode = .Album
                player.stop()
                currentPage = .PlayPage

                let album = albumsDataSource.albums[selectedAlbumRow]
                
                let property: MPMediaPropertyPredicate = MPMediaPropertyPredicate( value: album.albumPersistentID, forProperty: MPMediaItemPropertyAlbumPersistentID )
                
                let query: MPMediaQuery = MPMediaQuery()
                query.addFilterPredicate( property )
                
                player.setQueue(with: query)
                player.play()
                setNowPLaying(track: player.nowPlayingItem!)
                iPodScrollView.scrollRectToVisible(CGRect(x: iPodScrollView.frame.width * 4, y: 0, width: iPodScrollView.frame.width, height: iPodScrollView.frame.height), animated: true)

            }
            
            if currentPage == .TracksPage
            {
                playMode = .Track
                player.stop()
                let track : MPMediaItem = tracksDataSource.tracks[selectedTrackRow]
                currentPage = .PlayPage

                let property: MPMediaPropertyPredicate = MPMediaPropertyPredicate( value: track.persistentID, forProperty: MPMediaItemPropertyPersistentID )
                
                let query: MPMediaQuery = MPMediaQuery()
                query.addFilterPredicate( property )
                
                player.setQueue(with: query)
                player.play()
                setNowPLaying(track: track)
                iPodScrollView.scrollRectToVisible(CGRect(x: frameWidth * 4, y: 0, width: frameWidth, height: iPodScrollView.frame.height), animated: true)

            }
            
            
        }
        else if (currentAngle >= 3.75 && currentAngle <= 5.25)
        {
            print("Left clicked")
            if player.playbackState == MPMusicPlaybackState.playing
            {
                player.skipToPreviousItem()
            }
            wheelImage.bounceLeft(container : self.view)
        }
    }
    

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // remove the about view
        if currentPage == .MenuPage
        {
            aboutView.removeFromSuperview()
        }

    }
    
    
    
    @objc func wheelMoved(c: WheelGestureRecognizer) {
        let direction : Float = c.currentAngle - c.previousAngle
        bearing += 180 * direction / Float(Double.pi)
        
        if (bearing < -0.5) {
            bearing += 360;
        }
        else if (bearing > 359.5) {
            bearing -= 360;
        }
        //print("Wheeled \(bearing.rounded())  direction \(direction))")
        let sector : Int = Int(bearing) / 6
        
        if (sector != oldSector)
        {
            playClick()
            switch currentPage {
            case .AboutPage:
                if (direction > 0){
                    if aboutPos < aboutText.contentSize.height - aboutText.frame.height
                    {
                    aboutPos += 20
                    }
                } else {
                    if aboutPos > 0
                    {
                    aboutPos -= 20
                    } else {
                        aboutPos = 0
                    }
                }
                let sRect = CGRect(x: 0.0, y: aboutPos, width: aboutText.frame.width, height: aboutText.frame.height)
                aboutText.scrollRectToVisible(sRect, animated: true)
                break
                
            case .MenuPage:
                if (direction > 0){
                    if (selectedMenuRow + 1 < menuDataSource.MenuItems.count)
                    {
                        selectedMenuRow += 1
                        menuDataSource.selectedRow = selectedMenuRow
                        tblMenu.selectRow(at: IndexPath(row: selectedMenuRow, section: 0), animated: false, scrollPosition: UITableViewScrollPosition.middle)
                    }
                }
                else {
                    if (selectedMenuRow > 0)
                    {
                        selectedMenuRow -= 1
                        menuDataSource.selectedRow = selectedMenuRow
                        tblMenu.selectRow(at: IndexPath(row: selectedMenuRow, section: 0), animated: false, scrollPosition: UITableViewScrollPosition.middle)
                    }
                }
                break
                
            case .ArtistsPage:
                
                if (direction > 0){
                    if (selectedArtistRow + 1 < (artistsDataSource.artistItems?.count)!)
                    {
                        selectedArtistRow += 1
                        artistsDataSource.selectedRow = selectedArtistRow
                        let ip : IndexPath = IndexPath(row: selectedArtistRow, section: 0)
                        tblArtists.selectRow(at: ip, animated: false, scrollPosition: UITableViewScrollPosition.middle)

                        //tblArtists.scrollToNearestSelectedRow(at: UITableViewScrollPosition.middle, animated: false)
                        //tblArtists.reloadData()

                    }
                    
                }
                else {
                    if (selectedArtistRow > 0)
                    {
                        selectedArtistRow -= 1
                        artistsDataSource.selectedRow = selectedArtistRow
                        let ip : IndexPath = IndexPath(row: selectedArtistRow, section: 0)
                        tblArtists.selectRow(at: ip, animated: false, scrollPosition: UITableViewScrollPosition.middle)
                        //tblArtists.scrollToNearestSelectedRow(at: UITableViewScrollPosition.middle, animated: false)
                        //tblArtists.reloadData()

                    }
                }
                
                break
            case .AlbumPage:
                if (direction > 0){
                    if (selectedAlbumRow + 1 < (albumsDataSource.albums.count))
                    {
                        selectedAlbumRow += 1
                        albumsDataSource.selectedRow = selectedAlbumRow
                        let ip : IndexPath = IndexPath(row: selectedAlbumRow, section: 0)
                        tblAlbums.selectRow(at: ip, animated: true, scrollPosition: UITableViewScrollPosition.middle)
                    }
                }
                else {
                    if (selectedAlbumRow > 0)
                    {
                        selectedAlbumRow -= 1
                        albumsDataSource.selectedRow = selectedAlbumRow
                        let ip : IndexPath = IndexPath(row: selectedAlbumRow, section: 0)
                        tblAlbums.selectRow(at: ip, animated: true, scrollPosition: UITableViewScrollPosition.middle)
                    }
                }
                break
            case .TracksPage:
                if (direction > 0){
                    if (selectedTrackRow + 1 < (tracksDataSource.tracks.count))
                    {
                        selectedTrackRow += 1
                        tracksDataSource.selectedRow = selectedTrackRow
                        let ip : IndexPath = IndexPath(row: selectedTrackRow, section: 0)
                        tblTracks.selectRow(at: ip, animated: true, scrollPosition: UITableViewScrollPosition.middle)
                    }
                    
                }
                else {
                    if (selectedTrackRow > 0)
                    {
                        selectedTrackRow -= 1
                        tracksDataSource.selectedRow = selectedTrackRow
                        let ip : IndexPath = IndexPath(row: selectedTrackRow, section: 0)
                        tblTracks.selectRow(at: ip, animated: true, scrollPosition: UITableViewScrollPosition.middle)
                    }
                }
                
                break
            default:
                break
            }
            
            
        }

        oldSector = sector
    }
    
    
    //Return distinct array of Artist from media collection
    func getPlaylists() -> [MPMediaItem]
    {
        var distinctArtists = [MPMediaItem]()
        let query = MPMediaQuery.playlists()
        //query.groupingType = MPMediaGrouping.albumArtist
        for collection in query.collections! {
            let item: MPMediaItem? = collection.representativeItem
            distinctArtists.append(item!)
        }
        return distinctArtists
    }

    
    //Return distinct array of Artist from media collection
    func getArtists() -> [MPMediaItem]
    {
        var distinctArtists = [MPMediaItem]()
        let query = MPMediaQuery.artists()
        query.groupingType = MPMediaGrouping.albumArtist
        if let collections = query.collections {
            for collection in collections {
                let item: MPMediaItem? = collection.representativeItem
                distinctArtists.append(item!)
            }
        }
        return distinctArtists
    }
    
    //Get Albums for the artist
    func getArtistAlbums(artistItem : MPMediaItem) -> [MPMediaItem]
    {
        var distinctAlbums = [MPMediaItem]()
        let property: MPMediaPropertyPredicate = MPMediaPropertyPredicate( value: artistItem.albumArtist, forProperty: MPMediaItemPropertyAlbumArtist )
        
        let query: MPMediaQuery = MPMediaQuery()
        query.groupingType = MPMediaGrouping.album
        query.addFilterPredicate( property )

        for collection in query.collections! {
            let item: MPMediaItem? = collection.representativeItem
            distinctAlbums.append(item!)
        }
        return distinctAlbums
    }
    
    func getAlbumTracks(albumItem : MPMediaItem) -> [MPMediaItem]
    {
        let property: MPMediaPropertyPredicate = MPMediaPropertyPredicate( value: albumItem.albumPersistentID, forProperty: MPMediaItemPropertyAlbumPersistentID )
        
        let query: MPMediaQuery = MPMediaQuery()
        query.addFilterPredicate( property )
        
        return query.items!
    }
    
    func shuffleSongs()
    {
        playMode = .Shuffle
        player.shuffleMode = MPMusicShuffleMode.songs
        currentPage = .PlayPage
        player.prepareToPlay()
        player.play()
//        let t = player.nowPlayingItem!
//        print(" shuffle \(t.title)")
       // setNowPLaying(track: player.nowPlayingItem!)
        player.beginGeneratingPlaybackNotifications()

        iPodScrollView.scrollRectToVisible(CGRect(x: frameWidth * 4, y: 0, width: frameWidth, height: iPodScrollView.frame.height), animated: true)

    }
  
    func shuffleArtist(artist: MPMediaItem)
    {
        playMode = .Shuffle
        let property: MPMediaPropertyPredicate = MPMediaPropertyPredicate( value: artist.artistPersistentID, forProperty: MPMediaItemPropertyArtistPersistentID )
        
         let query: MPMediaQuery = MPMediaQuery()
        player.shuffleMode = MPMusicShuffleMode.songs
        query.addFilterPredicate( property )
        
        player.setQueue(with: query)
        currentPage = .PlayPage
        player.prepareToPlay()
        player.play()
        iPodScrollView.scrollRectToVisible(CGRect(x: frameWidth * 4, y: 0, width: frameWidth, height: iPodScrollView.frame.height), animated: true)
        print("playing \(player.nowPlayingItem)")
        setNowPLaying(track: player.nowPlayingItem!)
    }
    
    func shuffleAlbum(album: MPMediaItem )
    {
        playMode = .Shuffle
        let property: MPMediaPropertyPredicate = MPMediaPropertyPredicate( value: album.albumPersistentID, forProperty: MPMediaItemPropertyAlbumPersistentID )
        
        let query: MPMediaQuery = MPMediaQuery()
        player.shuffleMode = MPMusicShuffleMode.songs
        query.addFilterPredicate( property )
        
        player.setQueue(with: query)
        currentPage = .PlayPage
        player.play()
        iPodScrollView.scrollRectToVisible(CGRect(x: frameWidth * 4, y: 0, width: frameWidth, height: iPodScrollView.frame.height), animated: true)
        setNowPLaying(track: player.nowPlayingItem!)
    }
    
    
    @objc func nowPlayingItemIsChanged(notification: NSNotification){
        print("Player state changed")
        guard player.nowPlayingItem != nil else {
            return
        }
//        print("playing \(player.nowPlayingItem)")

        //todo if last song then go back to tracklist
        
//        if player.playbackState == .stopped
//        {
//         playingTimer.invalidate()
//            currentPage = .ArtistsPage
//            iPodScrollView.scrollRectToVisible(CGRect(x: iPodScrollView.frame.width * 0, y: 0, width: iPodScrollView.frame.width, height: iPodScrollView.frame.height), animated: true)
//   
//            
//        }
        
        setNowPLaying(track: player.nowPlayingItem!)
//                if playingTimer.isValid{
//                    playingTimer.invalidate()
//                }
    }
    
    func setNowPLaying(track : MPMediaItem)
    {
        nowPlayingPlayPause.image = UIImage(imageLiteralResourceName: "playButton")
        nowPlayingCover.image = track.artwork?.image(at: nowPlayingCover.frame.size)
        nowPlayingArtist.text = track.albumArtist
        nowPlayingAlbum.text = track.albumTitle
        nowPlayingTrack.text = track.title
        nowPlayingTrackTime.text = "\(Int(track.playbackDuration / 60).format(f: "02")) : \(Int(track.playbackDuration.truncatingRemainder(dividingBy: 60)).format(f: "02"))"
        nowPlayingTrackCurrent.text = "\(Int(track.playbackDuration / 60).format(f: "02")) : \(Int(track.playbackDuration.truncatingRemainder(dividingBy: 60)).format(f: "02"))"
        
        playingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.playLength), userInfo: nil, repeats: true)
        playViewLength = (trackPosBack.frame.width - 2) / CGFloat(track.playbackDuration)
        var tpFrame = trackPosFront.frame.size
        tpFrame.width = 1
        trackPosFront.frame.size = tpFrame
    }
    
    @objc func playLength()
    {
        let t = (player.nowPlayingItem?.playbackDuration)! - player.currentPlaybackTime
        nowPlayingTrackTime.text = "\(Int(t / 60).format(f: "02")) : \(Int(t.truncatingRemainder(dividingBy: 60)).format(f: "02"))"
        
        nowPlayingTrackCurrent.text = "\(Int(player.currentPlaybackTime / 60).format(f: "02")) : \(Int(player.currentPlaybackTime.truncatingRemainder(dividingBy: 60)).format(f: "02"))"
        var tpFrame = trackPosFront.frame.size
        tpFrame.width = playViewLength * CGFloat(player.currentPlaybackTime)
        trackPosFront.frame.size = tpFrame
    }
    
    func setInactivityTimer()  {
        if player.playbackState == .playing
        {
        activityTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.inactivityTime), userInfo: nil, repeats: false)
        }
    }
    
    @objc func inactivityTime()
    {
        if player.playbackState == .playing
        {
            currentPage = .PlayPage
            iPodScrollView.scrollRectToVisible(CGRect(x: iPodScrollView.frame.width * 4, y: 0, width: iPodScrollView.frame.width, height: iPodScrollView.frame.height), animated: true)

        }
    }
    
    func playClick() {
       // fxplayer?.stop()
       // fxplayer?.play()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
}


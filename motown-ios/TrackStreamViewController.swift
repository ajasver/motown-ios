//
//  DetailViewController.swift
//  motown-ios
//
//  Created by AJ Asver on 11/16/15.
//  Copyright © 2015 AJ Asver. All rights reserved.
//

import UIKit
import AVFoundation

class TrackStreamViewController: UIViewController {
    
    var stream = [MTTrack]()
    
    var currentTrack: MTTrack? {
        didSet {
            //update the view
            self.renderTrack()
            self.updatePlayer()
        }
    }
    
    var player: AVPlayer?
    var isPlaying = false
    
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var trackTitle: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playHeadTime: UILabel!
    @IBOutlet weak var trackLengthTime: UILabel!
    @IBOutlet weak var trackScrubber: UISlider!
    
    @IBAction func doPlay(sender: AnyObject) {
        //Play/Pause the stream
        if !currentTrack!.isPlaying {
            print("Play!")
            player!.play()
            currentTrack!.isPlaying = true
        } else {
            player!.pause()
            currentTrack!.isPlaying = false
        }
        
    }
    
    @IBAction func doScrub(sender: UISlider!) {
        let playHeadSeekTime = Double(sender.value) * (currentTrack!.trackLength)
        player!.seekToTime(CMTime(seconds: playHeadSeekTime, preferredTimescale: 1))
        currentTrack?.playHead = (playHeadSeekTime)
    }
    
    

    func configureView() {
    }
    
    func renderTrack() {
        //Update the interface with track data
        artistName.text = currentTrack!.artistName
        trackTitle.text = currentTrack!.title
        playHeadTime.text = currentTrack!.getPlayHeadTimeAsString()
        trackLengthTime.text = currentTrack!.getTrackLengthTimeAsString()
        trackScrubber.value = Float(currentTrack!.playHead)
        
        currentTrack!.isPlayingObserver = {
            (isPlaying: Bool) -> Void in
                if isPlaying == true {
                    self.playButton.setTitle("Pause", forState: .Normal)
                } else {
                    self.playButton.setTitle("Play", forState: .Normal)
                }
          }
        
        currentTrack!.playHeadObserver = {
            (playHead: NSTimeInterval) -> Void in
            self.trackScrubber.value = Float(playHead/self.currentTrack!.trackLength)
            self.playHeadTime.text = self.currentTrack!.getPlayHeadTimeAsString()
        }

        
    }
    
    func updatePlayer(){
        do {
            let url = currentTrack!.trackStreamURL!
            print(url)
            try player = AVPlayer(URL: url)
            player?.addPeriodicTimeObserverForInterval(CMTimeMake(1,30), queue: dispatch_get_main_queue(), usingBlock: {
                (time: CMTime) -> Void in
                self.currentTrack!.playHead = CMTimeGetSeconds(time)
                })
            
        } catch {
            print("Error loading track")
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        self.configureView()
        
        //Lets start with a dummy track in the stream
        
        stream.append(MTTrack(objectId: "genMFXg1XD"))
        
        currentTrack = stream[0]
        
        // Do any additional setup after loading the view, typically from a nib.

        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

}


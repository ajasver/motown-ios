//
//  Models.swift
//  motown-ios
//
//  Created by AJ Asver on 11/16/15.
//  Copyright © 2015 AJ Asver. All rights reserved.
// 

// The data models that we're going to use in the app: Track, User, Stream Activity and Favorites for now<
import Foundation
import Parse



class ParseBaseModel {
    
    var parseClassName: String
    var objectId: String?
    private var parseInstance: PFObject?
    var parseQuery: PFQuery
    
    init(parseClassName: String){
        self.parseClassName = parseClassName
        parseInstance = PFObject(className: self.parseClassName)
        parseQuery = PFQuery(className: self.parseClassName)
    }
    
    convenience init(parseClassName: String, objectId: String){
        self.init(parseClassName: parseClassName)
        self.load(objectId)
    }
    
    convenience init(){
        self.init(parseClassName: String(self.dynamicType))
    }
    
    convenience init(objectId: String){
        self.init(parseClassName: String(self.dynamicType), objectId: objectId)
    }

    func load(objectId:String){
        do {
            let instance = try parseQuery.getObjectWithId(objectId)
            self.parseInstance = instance
            self.objectId = instance.objectId
        } catch {
            print("Error: Could not load object with id \(objectId)")
        }
    }

    func loadInBackgroundWithId(objectId: String){
        parseQuery.getObjectInBackgroundWithId(objectId){
            (instance: PFObject?, error: NSError?) -> Void in
            if error==nil && instance != nil{
                self.parseInstance = instance!
                self.objectId = instance!.objectId
            }
        }
    }
    
    func loadInBackgroudWithId(objectId: String, block: (object: ParseBaseModel) -> Void) {
        parseQuery.getObjectInBackgroundWithId(objectId){
            (instance: PFObject?, error: NSError?) -> Void in
            if error==nil && instance != nil{
                self.parseInstance = instance!
                self.objectId = instance!.objectId
                block(object: self)
            }
        }
    }
    
    func reload() -> Void {
        if self.objectId != nil && self.parseInstance != nil {
            do {
                try self.parseInstance!.fetch()
            } catch {
                //Couldn't fetch
                print("Error refreshing object \(objectId!)")
            }
        }
      }
    
    func save() -> Void {
        // Save the object to Parse
        if parseInstance != nil {
            parseInstance!.saveInBackground()
        }
        
    }
    
    func saveWithBlock(block: (Bool, NSError?) -> Void) -> Void{
        if parseInstance != nil {
            parseInstance!.saveInBackgroundWithBlock(block as PFBooleanResultBlock?)
        }
    }

}




class MTTrack: ParseBaseModel{
    
    //Useful hidden properties to cache things
    var _trackImageData: NSData? = nil
    
    
    //Properties that each track will have
    var title: String? {
        get { return self.parseInstance!.objectForKey("title") as? String}
     }
    var artistName: String? {
        get { return self.parseInstance!.objectForKey("artistName") as? String}
      }
    var trackImage: NSData? {
        get {
            if _trackImageData == nil {
                if let file = self.parseInstance!.objectForKey("trackImage") as? PFFile {
                    var data: NSData?
                    file.getDataInBackgroundWithBlock({
                        (instance: NSData?, error: NSError?) -> Void in
                        if error == nil && instance != nil {
                            data = instance!
                        }
                    })
                    _trackImageData =  data
                } else {
                    _trackImageData = nil
                }
            }
            return _trackImageData
        }
    }
    
    var trackStreamURL: NSURL? {
        get {
            if var url = self.parseInstance!.objectForKey("trackStreamURL") as? String {
                url = url + "?client_id=4498069259d62bcb92c70b7ef14ae583"
                let nsURL = NSURL(string: url)
                return nsURL
            } else {
                return nil
            }
        }
    }

    var trackLength: NSTimeInterval {
        get { return NSTimeInterval(parseInstance!["trackLength"] as! Double) }
    }
    
    
    //States that the track can be in when in the app.  This data is not stored in our DB
    
     var playHead: NSTimeInterval = 0 {
        didSet{
            if playHeadObserver != nil {
                playHeadObserver!(playHead)
            }
        }
    }
    
    var isPlaying: Bool = false {
        didSet{
            if isPlayingObserver != nil {
                isPlayingObserver!(isPlaying)
            }
        }
    }

    
    
    //Functions that can observe the state of the track
    var playHeadObserver: ((NSTimeInterval) -> Void)?
    var isPlayingObserver: ((Bool) -> Void)?


    func getPlayHeadTimeAsString() -> String {
        //return the play head time as a MM:SS string
        return timeIntervalToString(playHead)
    }
    
    func getTrackLengthTimeAsString() -> String {
        //return the track length as a MM:SS string
        return timeIntervalToString(trackLength)
    }
    
    private func timeIntervalToString(timeInterval: NSTimeInterval) -> String {
        let mins = Int(timeInterval / 60)
        let secs = Int(timeInterval % 60)
        
        var secString = String(secs)
        if secs < 10 {
            secString = "0\(secString)"
        }
        return "\(mins):\(secString)"
    }
    
    
    
    
    
}






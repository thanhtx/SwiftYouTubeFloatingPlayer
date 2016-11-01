//
//  ViewController.swift
//  YTDraggablePlayer
//
//  Created by Ana Paula on 5/19/16.
//  Copyright © 2016 Ana Paula. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let videos = [Video.init(name: "Big Bunny", artist: "Google", url: URL(string: "http://clips.vorwaerts-gmbh.de/VfE_html5.mp4")!),
                  Video.init(name: "Robo Toy", artist: "Google", url: URL(string: "http://techslides.com/demos/sample-videos/small.mp4")!),
                  Video.init(name: "Big Bunny", artist: "Google", url: URL(string: "http://clips.vorwaerts-gmbh.de/VfE_html5.mp4")!),
                  Video.init(name: "Robo Toy", artist: "Google", url: URL(string: "http://techslides.com/demos/sample-videos/small.mp4")!),
                  Video.init(name: "Big Bunny", artist: "Google", url: URL(string: "http://clips.vorwaerts-gmbh.de/VfE_html5.mp4")!),
                  Video.init(name: "Robo Toy", artist: "Google", url: URL(string: "http://techslides.com/demos/sample-videos/small.mp4")!),
                  Video.init(name: "Big Bunny", artist: "Google", url: URL(string: "http://clips.vorwaerts-gmbh.de/VfE_html5.mp4")!),
                  Video.init(name: "Robo Toy", artist: "Google", url: URL(string: "http://techslides.com/demos/sample-videos/small.mp4")!)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    
    @IBAction func showPlayer(_ sender: AnyObject) {
        var urls: [URL] = []
        for video in videos {
            urls.append(video.url)
        }
        YTFPlayer.initYTF(urls, tableCellNibName: "VideoCell", delegate: self, dataSource: self)
        YTFPlayer.showYTFView(self)
    }
    
}

//MARK: YTFTableView

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoCell
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! VideoCell
        cell.labelArtist.text = videos[indexPath.row].artist
        cell.labelTitle.text = videos[indexPath.row].name
        if (indexPath.row % 2 == 0) {
            cell.imageThumbnail.image = UIImage(named: "bigBunny")
        } else {
            cell.imageThumbnail.image = UIImage(named: "legoToy")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        YTFPlayer.playIndex(indexPath.row)
    }
}

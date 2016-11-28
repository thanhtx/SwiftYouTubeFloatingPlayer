//
//  YTDViewController.swift
//  YTDraggablePlayer
//
//  Created by Ana Paula on 5/23/16.
//  Copyright © 2016 Ana Paula. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

enum ViewerViewControllerState {
    case
    normal,
    infoHidden
}

enum ViewerGestureAction {
    case
    undefined,
    hideInfo,
    showInfo,
    showNextMedia,
    showPreviousMedia,
    resizePlayer
}

class YTFViewController: AppViewController {
    
    @IBOutlet weak var play: UIButton!
    @IBOutlet weak var fullscreen: UIButton!
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var minimizeButton: YTFPopupCloseButton!
    @IBOutlet weak var playerControlsView: UIView!
    @IBOutlet weak var backPlayerControlsView: UIView!
    @IBOutlet weak var slider: CustomSlider!
    @IBOutlet weak var progress: CustomProgress!
    @IBOutlet weak var entireTime: UILabel!
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var progressIndicatorView: UIActivityIndicatorView!

    @IBOutlet weak var playerViewContainer: UIView!
    @IBOutlet weak var thumbnailContainer: UIView!
    @IBOutlet weak var playerTopMarginContraint: NSLayoutConstraint!
    @IBOutlet weak var viewerPage: ViewerPage!
    let viewerLiveController = ControllerFactory.createViewerLiveController()
    var gestureAction: ViewerGestureAction = .undefined
    
    var isOpen: Bool = false
    
    var isPlaying: Bool = false
    var isFullscreen: Bool = false
    var dragginSlider: Bool = false
    var isMinimized: Bool = false
    var hideTimer: Timer?
    var currentUrlIndex: Int = 0 {
        didSet {
            if (playerView != nil) {
                // Finish playing all items
                if (currentUrlIndex >= urls?.count) {
                    // Go back to first tableView item to loop list
                    currentUrlIndex = 0
                } else {
                    playIndex(currentUrlIndex)
                }
            }
        }
    }
    var urls: [URL]? {
        didSet {
            if (playerView != nil) {
                currentUrlIndex = 0
            }
        }
    }
    
    var playerControlsFrame: CGRect?
    var playerViewFrame: CGRect?
//    var tableViewContainerFrame: CGRect?
    var playerViewMinimizedFrame: CGRect?
    var minimizedPlayerFrame: CGRect?
    var initialFirstViewFrame: CGRect?
    var viewMinimizedFrame: CGRect?
    var restrictOffset: Float?
    var restrictTrueOffset: Float?
    var restictYaxis: Float?
    var transparentView: UIView?
    var onView: UIView?
    var playerTapGesture: UITapGestureRecognizer?
    var panGestureDirection: UIPanGestureRecognizerDirection?
    var touchPositionStartY: CGFloat?
    var touchPositionStartX: CGFloat?
    
    override func viewDidLoad() {
        restorationIdentifier = Constant.ViewController.player
        initPlayerWithURLs()
        initViews()
        playerView.delegate = self
        super.viewDidLoad()

        viewerPage.viewerLiveController = viewerLiveController
        viewerPage.thumbnailContainer = thumbnailContainer
        viewerPage.playerTopMarginContraint = playerTopMarginContraint
        addView(viewerPage)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let media = initData[Constant.ViewParam.media] as! MediaDto
        viewerLiveController.mediaListType = initData[Constant.ViewParam.mediaListType] as! MediaListType
        viewerLiveController.criteria = initData[Constant.ViewParam.criteria] as? String
        viewerLiveController.keyword = initData[Constant.ViewParam.keyword] as? String
        viewerLiveController.joinSocket(media: media)
        
        super.viewDidAppear(animated)
        calculateFrames()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewerLiveController.leaveSocket()
    }
    
    func initPlayerWithURLs() {
        if (isMinimized) {
            expandViews()
        }
        playIndex(currentUrlIndex)
    }
    
    func initViews() {
        self.view.backgroundColor = UIColor.clear
        self.view.alpha = 0.0
        playerControlsView.alpha = 0.0
        backPlayerControlsView.alpha = 0.0
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(YTFViewController.panAction(_:)))
        playerViewContainer.addGestureRecognizer(gesture)
        playerView.fillMode = .resizeAspectFill
        self.hidePlayerControls(false)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(YTFViewController.tapAction(_:)))
        playerViewContainer.addGestureRecognizer(tapGesture)
    }
    
    func calculateFrames() {
        self.initialFirstViewFrame = self.view.frame
        self.playerViewFrame = self.playerView.frame
        self.playerViewMinimizedFrame = self.playerView.frame
        self.viewMinimizedFrame = self.view.frame
        self.playerControlsFrame = self.playerControlsView.frame
        
        //playerView.translatesAutoresizingMaskIntoConstraints = true
        playerControlsView.translatesAutoresizingMaskIntoConstraints = true
        backPlayerControlsView.translatesAutoresizingMaskIntoConstraints = true
        self.playerControlsView.frame = self.playerControlsFrame!
        
        transparentView = UIView.init(frame: initialFirstViewFrame!)
        transparentView?.backgroundColor = UIColor.black
        transparentView?.alpha = 0.0
        onView?.addSubview(transparentView!)
        
        self.restrictOffset = Float(self.initialFirstViewFrame!.size.width) - 200
        self.restrictTrueOffset = Float(self.initialFirstViewFrame!.size.height) - 180
        self.restictYaxis = Float(self.initialFirstViewFrame!.size.height - playerView.frame.size.height)
        
    }
    
    @IBAction func minimizeButtonTouched(_ sender: AnyObject) {
        minimizeViews()
    }

    @nonobjc
    override func update(_ command: Command, data: Any?) {
        switch command {
        case .vPlayNextMedia:
            let media = self.viewerLiveController.nextMedia
            let url = URL(string: media.fileUrl)!
            YTFPlayer.changeURL(url)
            self.viewerLiveController.changeMedia(media: media)
        case .vPlayPreviousMedia:
            let media = self.viewerLiveController.previousMedia
            let url = URL(string: media.fileUrl)!
            YTFPlayer.changeURL(url)
            self.viewerLiveController.changeMedia(media: media)
        default:
            super.update(command, data: data)
        }
    }
}


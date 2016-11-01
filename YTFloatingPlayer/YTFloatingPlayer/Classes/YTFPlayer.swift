//
//  YTDProtocol.swift
//  YTDraggablePlayer
//
//  Created by Ana Paula on 6/6/16.
//  Copyright © 2016 Ana Paula. All rights reserved.
//

import UIKit

public struct YTFPlayer {
    public static func initYTF(_ url: URL, tableCellNibName: String, delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        if (dragViewController == nil) {
            dragViewController = YTFViewController(nibName: "YTFViewController", bundle: nil)
        }
        dragViewController?.urls = [url]
        dragViewController?.delegate = delegate
        dragViewController?.dataSource = dataSource
        dragViewController?.tableCellNibName = tableCellNibName
    }
    
    public static func initYTF(_ urls: [URL], tableCellNibName: String, delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        if (dragViewController == nil) {
            dragViewController = YTFViewController(nibName: "YTFViewController", bundle: nil)
        }
        dragViewController?.urls = urls
        dragViewController?.delegate = delegate
        dragViewController?.dataSource = dataSource
        dragViewController?.tableCellNibName = tableCellNibName
    }
    
    public static func showYTFView(_ viewController: UIViewController) {
        if dragViewController!.isOpen == false {
            dragViewController!.view.frame = CGRect(x: viewController.view.frame.size.width, y: viewController.view.frame.size.height, width: viewController.view.frame.size.width, height: viewController.view.frame.size.height)
            dragViewController!.view.alpha = 0
            dragViewController!.view.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            dragViewController!.onView = viewController.view
            
            UIApplication.shared.keyWindow?.addSubview(dragViewController!.view)
            
            UIView.animate(withDuration: 0.5, animations: {
                dragViewController!.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                dragViewController!.view.alpha = 1
                
                dragViewController!.view.frame = CGRect(x: 0, y: 0, width: UIApplication.shared.keyWindow!.bounds.width, height: UIApplication.shared.keyWindow!.bounds.height)
                
                dragViewController!.isOpen = true
            })
        }
    }
    
    public static func changeURL(_ url: URL) {
        dragViewController?.urls = [url]
    }
    
    public static func changeURLs(_ urls: [URL]) {
        dragViewController?.urls = urls
    }
    
    public static func changeCurrentIndex(_ index: Int) {
        dragViewController?.currentUrlIndex = index
    }
    
    public static func playIndex(_ index: Int) {
        dragViewController?.currentUrlIndex = index
        dragViewController?.playIndex(index)
        dragViewController?.hidePlayerControls(true)
    }
    
    public static func getIndex() -> Int {
        return dragViewController!.currentUrlIndex
    }
    
    public static func isOpen() -> Bool {
        return dragViewController?.isOpen == true ? true : false
    }
    
    public static func getYTFViewController() -> UIViewController? {
        return dragViewController
    }
    
    public static func finishYTFView(_ animated: Bool) {
        if(dragViewController != nil) {
            dragViewController?.isOpen = false
            dragViewController?.finishViewAnimated(animated)
            dragViewController = nil
        }
    }
}

var dragViewController: YTFViewController?

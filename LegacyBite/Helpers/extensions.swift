//
//  extensions.swift
//  LegacyBite
//
//  Created by Grizly on 23.07.26.
//

import UIKit

@objc extension UIViewController{
    func showLoader(blocksInteraction:Bool = false){
        self.view.isUserInteractionEnabled = !blocksInteraction
        guard self.view.viewWithTag(9999) == nil else {
            return
        }
        let loader = UIActivityIndicatorView(style: .large)
        loader.color = .systemGray
        loader.tag = 9999
        loader.center = self.view.center
        
        loader.startAnimating()
        self.view.addSubview(loader)

    }
    
    func hideLoader(){
        self.view.viewWithTag(9999)?.removeFromSuperview()
        self.view.isUserInteractionEnabled = true
    }
}

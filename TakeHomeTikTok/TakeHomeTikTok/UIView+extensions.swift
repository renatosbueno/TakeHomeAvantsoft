//
//  UIView+extensions.swift
//  TakeHomeTikTok
//
//  Created by Renato Bueno on 29/03/23.
//

import UIKit

extension UIView {
    
    func animateView() {
        self.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.20, initialSpringVelocity: 6.0, options: .curveEaseInOut) {
            self.transform = .identity
        }
    }
}

//
//  PathView.swift
//  MotionExamples
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit

final class PathView: UIView {

    var path: UIBezierPath? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var focusPercent: CGFloat? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
            
        guard let path = path else {
            return
        }
        
        path.lineWidth = 2.0
        
        UIColor.darkGray.setStroke()
        
        path.stroke()
        
    }

}

//
//  DynamicViewController.swift
//  MotionExamples
//
//  Created by Brett Walker on 6/3/16.
//  Copyright © 2016 Poet & Mountain, LLC. All rights reserved.
//

import UIKit

public class DynamicViewController: UIViewController, ButtonsViewDelegate {

    var createdUI: Bool = false
    var buttonsView: ButtonsView!
    var tapRecognizer: UITapGestureRecognizer!
    
    var circle: UIView!
    var motions: [MotionGroup] = []
    var constraints: [String : NSLayoutConstraint] = [:]
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if (!createdUI) {
            setupUI()
            
            tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(viewTappedHandler))
            view.addGestureRecognizer(tapRecognizer)
            
            createdUI = true
        }
        
    }
    
    
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        for motion in motions {
            motion.stop()
        }
    }
    
    deinit {
        (view as! ButtonsView).delegate = nil
        view.removeGestureRecognizer(tapRecognizer)
    }
    
    
    
    
    // MARK: - Private methods
    
    private func setupUI() {
        view.backgroundColor = UIColor.whiteColor()
        let margins = view.layoutMarginsGuide
        
        
        let label = UILabel.init(frame: CGRectZero)
        label.font = UIFont.systemFontOfSize(12.0)
        label.userInteractionEnabled = false
        label.text = "Tap to move the circle to that point.\nThe path will blend as you continue to tap in other locations."
        label.numberOfLines = 4
        self.view.addSubview(label)
        
        let w: CGFloat = 40.0
        
        circle = UIView.init()
        circle.backgroundColor = UIColor.init(red: 76.0/255.0, green:164.0/255.0, blue:68.0/255.0, alpha:1.0)
        circle.layer.masksToBounds = true
        circle.layer.cornerRadius = w * 0.5
        self.view.addSubview(circle)
        
        circle.translatesAutoresizingMaskIntoConstraints = false
        let circle_x = circle.centerXAnchor.constraintEqualToAnchor(margins.leadingAnchor, constant: 20.0)
        circle_x.active = true
        let circle_y = circle.centerYAnchor.constraintEqualToAnchor(margins.topAnchor, constant: topLayoutGuide.length+40.0)
        circle_y.active = true
        
        circle.heightAnchor.constraintEqualToConstant(40.0).active = true
        circle.widthAnchor.constraintEqualToConstant(40.0).active = true
        
        constraints["x"] = circle_x
        constraints["y"] = circle_y
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor, constant: 50.0).active = true
        label.centerYAnchor.constraintEqualToAnchor(margins.topAnchor, constant: topLayoutGuide.length+40.0).active = true
        label.widthAnchor.constraintEqualToConstant(220.0).active = true
        label.heightAnchor.constraintEqualToConstant(60.0).active = true
        
        
        buttonsView = ButtonsView.init(frame: CGRectZero)
        view.addSubview(buttonsView)
        buttonsView.startButton.hidden = true
        buttonsView.stopButton.hidden = true
        buttonsView.delegate = self
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        
        buttonsView.widthAnchor.constraintEqualToAnchor(margins.widthAnchor, constant: 0.0).active = true
        buttonsView.heightAnchor.constraintEqualToAnchor(margins.heightAnchor, constant: 0.0).active = true
        
    }
    
    
    
    func viewTappedHandler(gesture: UITapGestureRecognizer) {
        
        if (gesture.state != UIGestureRecognizerState.Ended) {
            return;
        }
        
        let pt = gesture.locationInView(self.view)
        
        // setup new motion
        let x = constraints["x"]!
        let y = constraints["y"]!
        let motion_x = Motion(target: x,
                              properties: [PropertyData(path: "constant", start: Double(x.constant), end: Double(pt.x-20.0))],
                              duration: 1.5,
                              easing: EasingQuadratic.easeInOut())
        motion_x.additive = true
        
        let motion_y = Motion(target: y,
                              properties: [PropertyData(path: "constant", start: Double(y.constant), end: Double(pt.y))],
                              duration: 1.5,
                              easing: EasingQuadratic.easeInOut())
        motion_y.additive = true
        
        let group = MotionGroup(motions: [motion_x, motion_y])
        group.completed { [weak self] (group) in
            guard let strong_self = self else { return }
            
            for x in 0..<strong_self.motions.count {
                let motion = strong_self.motions[x]
                if (group === motion) {
                    strong_self.motions.removeAtIndex(x)
                    break
                }
            }
        }
        
        motions.append(group)
        
        group.start()
        
    }
    
    
    
    // MARK: - ButtonsViewDelegate methods
    
    func didStart() {
    }
    
    func didStop() {
    }
    
    func didPause() {
        for motion in motions {
            motion.pause()
        }
    }
    
    func didResume() {
        for motion in motions {
            motion.resume()
        }
    }

}


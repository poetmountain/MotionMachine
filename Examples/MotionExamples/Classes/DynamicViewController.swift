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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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
    
    
    
    override public func viewWillDisappear(_ animated: Bool) {
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
        view.backgroundColor = UIColor.white()
        let margins = view.layoutMarginsGuide
        
        
        let label = UILabel.init(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.isUserInteractionEnabled = false
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
        let circle_x = circle.centerXAnchor.constraint(equalTo: margins.leadingAnchor, constant: 20.0)
        circle_x.isActive = true
        let circle_y = circle.centerYAnchor.constraint(equalTo: margins.topAnchor, constant: topLayoutGuide.length+40.0)
        circle_y.isActive = true
        
        circle.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        circle.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        
        constraints["x"] = circle_x
        constraints["y"] = circle_y
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 50.0).isActive = true
        label.centerYAnchor.constraint(equalTo: margins.topAnchor, constant: topLayoutGuide.length+40.0).isActive = true
        label.widthAnchor.constraint(equalToConstant: 220.0).isActive = true
        label.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
        
        
        buttonsView = ButtonsView.init(frame: CGRect.zero)
        view.addSubview(buttonsView)
        buttonsView.startButton.isHidden = true
        buttonsView.stopButton.isHidden = true
        buttonsView.delegate = self
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        
        buttonsView.widthAnchor.constraint(equalTo: margins.widthAnchor, constant: 0.0).isActive = true
        buttonsView.heightAnchor.constraint(equalTo: margins.heightAnchor, constant: 0.0).isActive = true
        
    }
    
    
    
    func viewTappedHandler(_ gesture: UITapGestureRecognizer) {
        
        if (gesture.state != UIGestureRecognizerState.ended) {
            return;
        }
        
        let pt = gesture.location(in: self.view)
        
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
                    strong_self.motions.remove(at: x)
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


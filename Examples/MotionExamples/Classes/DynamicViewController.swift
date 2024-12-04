//
//  DynamicViewController.swift
//  MotionExamples
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

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
    
    
    
    public override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
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
        motions.removeAll()
        
        view.removeGestureRecognizer(tapRecognizer)
    }
    

    
    // MARK: - Private methods
    
    private func setupUI() {
        view.backgroundColor = UIColor.white
        
        var margins : UILayoutGuide
        let top_offset : CGFloat = 20.0

        if #available(iOS 11.0, *) {
            margins = view.safeAreaLayoutGuide
        } else {
            margins = topLayoutGuide as! UILayoutGuide
        }
        
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
  
        
        var top_anchor: NSLayoutYAxisAnchor
        if #available(iOS 11.0, *) {
            top_anchor = margins.topAnchor
        } else {
            top_anchor = margins.bottomAnchor
        }
        
        circle.translatesAutoresizingMaskIntoConstraints = false
        let circle_x = circle.centerXAnchor.constraint(equalTo: margins.leadingAnchor, constant: 48.0)
        circle_x.isActive = true
  
        let circle_y = circle.topAnchor.constraint(equalTo: top_anchor, constant: top_offset)
        circle_y.isActive = true
        
        circle.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        circle.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        
        constraints["x"] = circle_x
        constraints["y"] = circle_y
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 80.0).isActive = true
        label.firstBaselineAnchor.constraint(equalTo: top_anchor, constant: top_offset).isActive = true
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
    
    
    
    @objc func viewTappedHandler(_ gesture: UITapGestureRecognizer) {
        
        if (gesture.state != UIGestureRecognizer.State.ended) {
            return;
        }
        
        let pt = gesture.location(in: self.view)
        print("gesture pt \(pt)")
        
        var y_offset : CGFloat = 0.0
        
        if #available(iOS 11.0, *) {
            y_offset = CGFloat(view.safeAreaInsets.top) + 20.0
            
        } else {
            y_offset = CGFloat(topLayoutGuide.length) + 20.0
        }
        
        // setup new motion
        let x = constraints["x"]!
        let y = constraints["y"]!
        let motion_x = Motion(target: x,
                              properties: [PropertyData(path: "constant", start: Double(x.constant), end: Double(pt.x))],
                              duration: 1.5,
                              easing: EasingQuadratic.easeInOut())
        motion_x.additive = true
        
        let motion_y = Motion(target: y,
                              properties: [PropertyData(path: "constant", start: Double(y.constant), end: Double(pt.y-y_offset))],
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


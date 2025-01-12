//
//  AdditiveViewController.swift
//  MotionExamples
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import MotionMachine

public class AdditiveViewController: UIViewController, ButtonsViewDelegate {

    var createdUI: Bool = false
    var buttonsView: ButtonsView!
    var tapRecognizer: UITapGestureRecognizer!
    
    var circle: UIView!
    var group: MotionGroup!
    var reverseGroup: MotionGroup!
    var constraints: [String : NSLayoutConstraint] = [:]
    var expanding: Bool = false
    
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
            
            var margins : UILayoutGuide
            if #available(iOS 11.0, *) {
                margins = view.safeAreaLayoutGuide
            } else {
                margins = view.layoutMarginsGuide
            }
            
            // setup motion
            let expanded_amount = Double(margins.layoutFrame.size.height) * 1.2
            let normal_amount = 40.0
            
            let change_color = Motion(target: circle,
                                      states: MotionState(keyPath: \UIView.backgroundColor[default: .systemGreen], end: .systemBlue),
                                      duration: 1.6,
                                      easing: EasingQuadratic.easeInOut(),
                                      options: [.additive])
            


            let expand_width = Motion(target: constraints["width"]!,
                                      properties: [PropertyData(keyPath: \NSLayoutConstraint.constant, start: normal_amount, end: expanded_amount)],
                                      duration: 1.8,
                                      easing: EasingCubic.easeInOut(),
                                      options: [.additive])
            
            let expand_height = Motion(target: constraints["height"]!,
                                       properties: [PropertyData(keyPath: \NSLayoutConstraint.constant, start: normal_amount, end: expanded_amount)],
                                       duration: 1.8,
                                       easing: EasingCubic.easeInOut(),
                                       options: [.additive])
            
            let corner_radius = Motion(target: circle,
                                       properties: [PropertyData(keyPath: \UIView.layer.cornerRadius, start: normal_amount*0.5, end: expanded_amount*0.5)],
                                       duration: 1.8,
                                       easing: EasingCubic.easeInOut(),
                                       options: [.additive])
            
            group = MotionGroup(motions: [change_color, expand_width, expand_height, corner_radius])
            group.completed { [weak self] group in
                if self?.reverseGroup.motionState == .stopped {
                    self?.expanding = true
                }
            }
            // setup shrink motion
            // -- note: we have to set the starting values for the shrink motions because if we leave them out, they'll use the current
            // values at the time the UI is setup, meaning the start and end values will be the same
            let rev_change_color = Motion(target: circle,
                                          states: MotionState(keyPath: \UIView.backgroundColor[default: .systemBlue], end: .systemGreen),
                                      duration: 1.6,
                                      easing: EasingQuadratic.easeInOut(),
                                          options: [.additive])
            
            
            let shrink_width = Motion(target: constraints["width"]!,
                                      properties: [PropertyData(keyPath: \NSLayoutConstraint.constant, start: expanded_amount, end: normal_amount)],
                                      duration: 1.8,
                                      easing: EasingCubic.easeInOut(),
                                      options: [.additive])
            
            let shrink_height = Motion(target: constraints["height"]!,
                                       properties: [PropertyData(keyPath: \NSLayoutConstraint.constant, start: expanded_amount, end: normal_amount)],
                                       duration: 1.8,
                                       easing: EasingCubic.easeInOut(),
                                       options: [.additive])
            
            let rev_corner_radius = Motion(target: circle,
                                           properties: [PropertyData(keyPath: \UIView.layer.cornerRadius, start: expanded_amount*0.5, end: normal_amount*0.5)],
                                         duration: 1.8,
                                           easing: EasingCubic.easeInOut(),
                                           options: [.additive])
            
            reverseGroup = MotionGroup(motions: [rev_change_color, shrink_width, shrink_height, rev_corner_radius])
            reverseGroup.completed { [weak self] group in
                if self?.group.motionState == .stopped {
                    self?.expanding = false
                }
            }
            createdUI = true
        }
        
    }
    

    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        group.stop()
        for motion in group.motions {
            group.remove(motion)
        }
        reverseGroup.stop()
        for motion in reverseGroup.motions {
            reverseGroup.remove(motion)
        }
    }
    
    
    
    
    // MARK: - Private methods
    
    private func setupUI() {
        view.backgroundColor = UIColor.white
        
        var margins : UILayoutGuide
        if #available(iOS 11.0, *) {
            margins = view.safeAreaLayoutGuide
        } else {
            margins = view.layoutMarginsGuide
        }
        
        
        let label = UILabel.init(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.isUserInteractionEnabled = false
        label.text = "Tap to expand.\nTap again to shrink.\nThe motions will blend."
        label.numberOfLines = 4
        self.view.addSubview(label)
        
        let w: CGFloat = 40.0
        
        circle = UIView()
        circle.backgroundColor = .systemGreen
        circle.layer.masksToBounds = true
        circle.layer.cornerRadius = w * 0.5
        self.view.addSubview(circle)
        
        var y_offset : CGFloat = 0.0
        
        if #available(iOS 11.0, *) {
            y_offset = CGFloat(view.safeAreaInsets.top)
            
        } else {
            y_offset = CGFloat(topLayoutGuide.length)
        }
        
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.centerXAnchor.constraint(equalTo: margins.centerXAnchor, constant: 0.0).isActive = true
        circle.centerYAnchor.constraint(equalTo: margins.centerYAnchor, constant: -y_offset).isActive = true

        let circle_height = circle.heightAnchor.constraint(equalToConstant: 40.0)
        circle_height.isActive = true
        let circle_width = circle.widthAnchor.constraint(equalToConstant: 40.0)
        circle_width.isActive = true
        
        constraints["width"] = circle_width
        constraints["height"] = circle_height
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: circle.trailingAnchor, constant: 10.0).isActive = true
        label.centerYAnchor.constraint(equalTo: circle.centerYAnchor, constant: 0.0).isActive = true
        label.widthAnchor.constraint(equalToConstant: 140.0).isActive = true
        label.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
        
        
        buttonsView = ButtonsView()
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
            return
        }
        
        expanding = !expanding
        
        if (expanding) {
            group.start()
        } else if (!expanding) {
            reverseGroup.start()
        }
    }
    
    
    
    // MARK: - ButtonsViewDelegate methods
    
    func didStart() {
        group.start()
    }
    
    func didStop() {
        group.stop()
    }
    
    func didPause() {
        group.pause()
        reverseGroup.pause()
    }
    
    func didResume() {
        group.resume()
        reverseGroup.resume()
    }

}

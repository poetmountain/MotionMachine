//
//  BasicMotionViewController.swift
//  MotionExamples
//
//  Created by Brett Walker on 6/1/16.
//  Copyright © 2016 Poet & Mountain, LLC. All rights reserved.
//

import UIKit

public class BasicMotionViewController: UIViewController, ButtonsViewDelegate {

    var createdUI: Bool = false
    var buttonsView: ButtonsView!
    var motionView: UIView!
    var motion: Motion!
    var xConstraint: NSLayoutConstraint!
    
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
            
            
            // setup motion
            motion = Motion(target: xConstraint, duration: 1.0, easing: EasingQuadratic.easeInOut(), options: [.Reverse])
                .add(PropertyData("constant", 200.0))
                .paused({ (motion) in
                    print("paused!")
                })
                .resumed({ (motion) in
                    print("resumed!")
                })
            
            createdUI = true
        }
        
    }

  
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        motion.start()
    }
    
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        motion.stop()
    }
    
    deinit {
        (view as! ButtonsView).delegate = nil
    }
    

    
    
    // MARK: - Private methods
    
    private func setupUI() {
        view.backgroundColor = UIColor.whiteColor()
        let margins = view.layoutMarginsGuide

        buttonsView = ButtonsView.init(frame: CGRectZero)
        view.addSubview(buttonsView)
        buttonsView.delegate = self
        buttonsView.translatesAutoresizingMaskIntoConstraints = false

        buttonsView.widthAnchor.constraintEqualToAnchor(margins.widthAnchor, constant: 0.0).active = true
        buttonsView.heightAnchor.constraintEqualToAnchor(margins.heightAnchor, constant: 0.0).active = true
        
        
        
        motionView = UIView.init()
        motionView.backgroundColor = UIColor.init(red: 76.0/255.0, green:164.0/255.0, blue:68.0/255.0, alpha:1.0)
        self.view.addSubview(motionView)
        motionView.translatesAutoresizingMaskIntoConstraints = false
        
        xConstraint = motionView.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor, constant: 0.0)
        xConstraint.active = true
        motionView.topAnchor.constraintEqualToAnchor(margins.topAnchor, constant: topLayoutGuide.length+20.0).active = true
        motionView.widthAnchor.constraintEqualToConstant(40.0).active = true
        motionView.heightAnchor.constraintEqualToConstant(40.0).active = true
        
        
    }
    
    
    // MARK: - ButtonsViewDelegate methods
    
    func didStart() {
        motion.start()
    }
    
    func didStop() {
        motion.stop()
    }
    
    func didPause() {
        motion.pause()
    }
    
    func didResume() {
        motion.resume()
    }
    
}

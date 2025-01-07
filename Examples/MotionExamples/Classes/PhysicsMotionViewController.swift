//
//  PhysicsMotionViewController.swift
//  MotionExamples
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit

public class PhysicsMotionViewController: UIViewController, ButtonsViewDelegate {

    var createdUI: Bool = false
    var buttonsView: ButtonsView!
    var motionView: UIView!
    var motion: PhysicsMotion<NSLayoutConstraint>!
    var xConstraint: NSLayoutConstraint!
    
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
            
            
            // setup motion
            createMotion()
            
            createdUI = true
        }
        
    }
    
    
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        motion.start()
    }
    
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        motion.stop()
    }
    
    
    
    
    // MARK: - Private methods
    
    private func setupUI() {
        view.backgroundColor = UIColor.white
        
        var margins : UILayoutGuide
        if #available(iOS 11.0, *) {
            margins = view.safeAreaLayoutGuide
        } else {
            margins = topLayoutGuide as! UILayoutGuide
        }
        
        var top_anchor: NSLayoutYAxisAnchor
        if #available(iOS 11.0, *) {
            top_anchor = margins.topAnchor
        } else {
            top_anchor = margins.bottomAnchor
        }
        
        buttonsView = ButtonsView.init(frame: CGRect.zero)
        view.addSubview(buttonsView)
        buttonsView.delegate = self
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        
        buttonsView.widthAnchor.constraint(equalTo: margins.widthAnchor, constant: 0.0).isActive = true
        buttonsView.heightAnchor.constraint(equalTo: margins.heightAnchor, constant: 0.0).isActive = true
        
        
        
        motionView = UIView.init()
        motionView.backgroundColor = UIColor.init(red: 76.0/255.0, green:164.0/255.0, blue:68.0/255.0, alpha:1.0)
        motionView.layer.masksToBounds = true
        motionView.layer.cornerRadius = 20
        self.view.addSubview(motionView)
        motionView.translatesAutoresizingMaskIntoConstraints = false
        
        xConstraint = motionView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 20.0)
        xConstraint.isActive = true
        motionView.topAnchor.constraint(equalTo: top_anchor, constant: 20.0).isActive = true
        motionView.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        motionView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        
    }
    
    
    private func createMotion() {
        let config = PhysicsConfiguration(velocity: 300, friction: 0.72)
        motion = PhysicsMotion(target: xConstraint, properties: [PropertyData(keyPath: \NSLayoutConstraint.constant)], configuration: config)
        .paused({ (motion) in
            print("paused!")
        })
        .resumed({ (motion) in
            print("resumed!")
        })
        .completed({ (motion) in
            print("completed!")
        })
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

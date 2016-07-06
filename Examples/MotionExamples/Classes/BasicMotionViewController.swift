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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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

  
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        motion.start()
    }
    
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        motion.stop()
    }
    
    deinit {
        (view as! ButtonsView).delegate = nil
    }
    

    
    
    // MARK: - Private methods
    
    private func setupUI() {
        view.backgroundColor = UIColor.white()
        let margins = view.layoutMarginsGuide

        buttonsView = ButtonsView.init(frame: CGRect.zero)
        view.addSubview(buttonsView)
        buttonsView.delegate = self
        buttonsView.translatesAutoresizingMaskIntoConstraints = false

        buttonsView.widthAnchor.constraint(equalTo: margins.widthAnchor, constant: 0.0).isActive = true
        buttonsView.heightAnchor.constraint(equalTo: margins.heightAnchor, constant: 0.0).isActive = true
        
        
        
        motionView = UIView.init()
        motionView.backgroundColor = UIColor.init(red: 76.0/255.0, green:164.0/255.0, blue:68.0/255.0, alpha:1.0)
        self.view.addSubview(motionView)
        motionView.translatesAutoresizingMaskIntoConstraints = false
        
        xConstraint = motionView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 0.0)
        xConstraint.isActive = true
        motionView.topAnchor.constraint(equalTo: margins.topAnchor, constant: topLayoutGuide.length+20.0).isActive = true
        motionView.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        motionView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        
        
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

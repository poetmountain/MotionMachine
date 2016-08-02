//
//  PhysicsMotionViewController.swift
//  MotionExamples
//
//  Created by Brett Walker on 6/2/16.
//  Copyright © 2016 Poet & Mountain, LLC. All rights reserved.
//

import UIKit

public class PhysicsMotionViewController: UIViewController, ButtonsViewDelegate {

    var createdUI: Bool = false
    var buttonsView: ButtonsView!
    var square: UIView!
    var motion: PhysicsMotion!
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
            motion = PhysicsMotion(target: xConstraint, properties: [PropertyData("constant")], velocity: 300.0, friction: 0.72)
            .paused({ (motion) in
                print("paused!")
            })
            .resumed({ (motion) in
                print("resumed!")
            })
            .completed({ (motion) in
                print("completed!")
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
        view.backgroundColor = UIColor.white
        let margins = view.layoutMarginsGuide
        
        buttonsView = ButtonsView.init(frame: CGRect.zero)
        view.addSubview(buttonsView)
        buttonsView.delegate = self
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        
        buttonsView.widthAnchor.constraint(equalTo: margins.widthAnchor, constant: 0.0).isActive = true
        buttonsView.heightAnchor.constraint(equalTo: margins.heightAnchor, constant: 0.0).isActive = true
        
        
        
        square = UIView.init()
        square.backgroundColor = UIColor.init(red: 76.0/255.0, green:164.0/255.0, blue:68.0/255.0, alpha:1.0)
        self.view.addSubview(square)
        square.translatesAutoresizingMaskIntoConstraints = false
        
        xConstraint = square.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 0.0)
        xConstraint.isActive = true
        square.topAnchor.constraint(equalTo: margins.topAnchor, constant: topLayoutGuide.length+20.0).isActive = true
        square.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        square.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        
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

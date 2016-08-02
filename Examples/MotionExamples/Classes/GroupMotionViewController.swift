//
//  GroupMotionViewController.swift
//  MotionExamples
//
//  Created by Brett Walker on 6/2/16.
//  Copyright © 2016 Poet & Mountain, LLC. All rights reserved.
//

import UIKit

public class GroupMotionViewController: UIViewController, ButtonsViewDelegate {

    var createdUI: Bool = false
    var buttonsView: ButtonsView!
    var circle: UIView!
    var circle2: UIView!
    var group: MotionGroup!
    
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
            
            
            // setup motion
            group = MotionGroup(options: [.Reverse])
            .add(Motion(target: constraints["circleX"]!,
                    properties: [PropertyData("constant", 200.0)],
                      duration: 1.0,
                        easing: EasingQuartic.easeInOut()))
                
            .add(Motion(target: constraints["circleY"]!,
                    properties: [PropertyData("constant", 250.0)],
                      duration: 1.4,
                        easing: EasingElastic.easeInOut()))
                
            .add(Motion(target: circle,
                    properties: [PropertyData("backgroundColor.blue", 0.9)],
                      duration: 1.2,
                        easing: EasingQuartic.easeInOut()))
            
            .add(Motion(target: constraints["circle2X"]!,
                        properties: [PropertyData("constant", 300.0)],
                        duration: 1.2,
                        easing: EasingQuadratic.easeInOut()))
            (group.motions.last as! Motion).reverseEasing = EasingQuartic.easeInOut()

            
            createdUI = true
        }
        
    }
    
    
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        group.start()
    }
    
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        group.stop()
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
        

        // set up motion views
        
        circle = UIView.init()
        circle.backgroundColor = UIColor.init(red: 76.0/255.0, green:164.0/255.0, blue:68.0/255.0, alpha:1.0)
        circle.layer.cornerRadius = 20.0
        circle.layer.masksToBounds = true
        self.view.addSubview(circle)
        
        circle2 = UIView.init()
        circle2.backgroundColor = UIColor.init(red: 91.0/255.0, green:189.0/255.0, blue:231.0/255.0, alpha:1.0)
        circle2.layer.cornerRadius = 20.0
        circle2.layer.masksToBounds = true
        self.view.addSubview(circle2)
        
        // set up motion constraints
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle2.translatesAutoresizingMaskIntoConstraints = false
        
        let circle_x = circle.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 0.0)
        circle_x.isActive = true
        let circle_y = circle.topAnchor.constraint(equalTo: margins.topAnchor, constant: topLayoutGuide.length+40.0)
        circle_y.isActive = true
        circle.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        circle.heightAnchor.constraint(equalToConstant: 40.0).isActive = true

        let circle2_x = circle2.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 0.0)
        circle2_x.isActive = true
        circle2.topAnchor.constraint(equalTo: circle.layoutMarginsGuide.bottomAnchor, constant: 20.0).isActive = true
        circle2.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        circle2.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        
        constraints["circleX"] = circle_x
        constraints["circleY"] = circle_y
        constraints["circle2X"] = circle2_x
        
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
    }
    
    func didResume() {
        group.resume()
    }

}

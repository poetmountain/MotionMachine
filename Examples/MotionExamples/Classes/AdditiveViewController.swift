//
//  AdditiveViewController.swift
//  MotionExamples
//
//  Created by Brett Walker on 6/2/16.
//  Copyright © 2016 Poet & Mountain, LLC. All rights reserved.
//

import UIKit

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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if (!createdUI) {
            setupUI()
            
            tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(viewTappedHandler))
            view.addGestureRecognizer(tapRecognizer)
            
            
            // setup motion
            let expanded_amount = Double(view.layoutMarginsGuide.layoutFrame.size.height) * 1.2
            let normal_amount = 40.0
            
            let change_color = Motion(target: circle,
                                      properties: [PropertyData("backgroundColor.red", 91.0/255.0),
                                        PropertyData("backgroundColor.green", 189.0/255.0),
                                        PropertyData("backgroundColor.blue", 231.0/255.0)],
                                      duration: 1.6,
                                      easing: EasingQuadratic.easeInOut())
            change_color.additive = true
            


            let expand_width = Motion(target: constraints["width"]!,
                                      properties: [PropertyData(path: "constant", start: normal_amount, end: expanded_amount)],
                                      duration: 1.8,
                                      easing: EasingCubic.easeInOut())
            expand_width.additive = true
            
            let expand_height = Motion(target: constraints["height"]!,
                                       properties: [PropertyData(path: "constant", start: normal_amount, end: expanded_amount)],
                                       duration: 1.8,
                                       easing: EasingCubic.easeInOut())
            expand_height.additive = true
            
            let corner_radius = Motion(target: circle,
                                       properties: [PropertyData(path: "layer.cornerRadius", start: normal_amount*0.5, end: expanded_amount*0.5)],
                                       duration: 1.8,
                                       easing: EasingCubic.easeInOut())
            corner_radius.additive = true
            
            group = MotionGroup(motions: [expand_width, expand_height, change_color, corner_radius])
            

            // setup shrink motion
            // -- note: we have to set the starting values for the shrink motions because if we leave them out, they'll use the current
            // values at the time the UI is setup, meaning the start and end values will be the same
            let rev_change_color = Motion(target: circle,
                                          properties: [PropertyData(path: "backgroundColor.red", start: 91.0/255.0, end: 76.0/255.0),
                                                       PropertyData(path: "backgroundColor.green", start: 189.0/255.0, end: 164.0/255.0),
                                                       PropertyData(path: "backgroundColor.blue", start: 231.0/255.0, end: 68.0/255.0)],
                                      duration: 1.6,
                                      easing: EasingQuadratic.easeInOut())
            rev_change_color.additive = true
            
            
            let shrink_width = Motion(target: constraints["width"]!,
                                      properties: [PropertyData(path: "constant", start: expanded_amount, end: normal_amount)],
                                      duration: 1.8,
                                      easing: EasingCubic.easeInOut())
            shrink_width.additive = true
            
            let shrink_height = Motion(target: constraints["height"]!,
                                       properties: [PropertyData(path: "constant", start: expanded_amount, end: normal_amount)],
                                       duration: 1.8,
                                       easing: EasingCubic.easeInOut())
            shrink_height.additive = true
            
            let rev_corner_radius = Motion(target: circle,
                                       properties: [PropertyData(path: "layer.cornerRadius", start: expanded_amount*0.5, end: normal_amount*0.5)],
                                         duration: 1.8,
                                           easing: EasingCubic.easeInOut())
            rev_corner_radius.additive = true
            
            reverseGroup = MotionGroup(motions: [shrink_width, shrink_height, rev_change_color, rev_corner_radius])

            
            createdUI = true
        }
        
    }
    

    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        group.stop()
        reverseGroup.stop()
    }
    
    deinit {
        (view as! ButtonsView).delegate = nil
    }
    
    
    
    
    // MARK: - Private methods
    
    private func setupUI() {
        view.backgroundColor = UIColor.whiteColor()
        let margins = view.layoutMarginsGuide
        
        
        let label = UILabel.init(frame: CGRectZero)
        label.font = UIFont.systemFontOfSize(12.0)
        label.userInteractionEnabled = false
        label.text = "Tap to expand.\nTap again to shrink.\nThe motions will blend."
        label.numberOfLines = 4
        self.view.addSubview(label)
        
        let w: CGFloat = 40.0
        
        circle = UIView.init()
        circle.backgroundColor = UIColor.init(red: 76.0/255.0, green:164.0/255.0, blue:68.0/255.0, alpha:1.0)
        circle.layer.masksToBounds = true
        circle.layer.cornerRadius = w * 0.5
        self.view.addSubview(circle)
        
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.centerXAnchor.constraintEqualToAnchor(margins.centerXAnchor).active = true
        circle.centerYAnchor.constraintEqualToAnchor(margins.centerYAnchor).active = true

        let circle_height = circle.heightAnchor.constraintEqualToConstant(40.0)
        circle_height.active = true
        let circle_width = circle.widthAnchor.constraintEqualToConstant(40.0)
        circle_width.active = true
        
        constraints["width"] = circle_width
        constraints["height"] = circle_height
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraintEqualToAnchor(circle.trailingAnchor, constant: 10.0).active = true
        label.centerYAnchor.constraintEqualToAnchor(circle.centerYAnchor, constant: 0.0).active = true
        label.widthAnchor.constraintEqualToConstant(140.0).active = true
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
        
        expanding = !expanding
        
        if (expanding && group.motionState == .Stopped) {
            group.start()
        } else if (!expanding && reverseGroup.motionState == .Stopped) {
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

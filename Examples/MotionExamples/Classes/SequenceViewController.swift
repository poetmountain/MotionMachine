//
//  SequenceNoncontiguousViewController.swift
//  MotionExamples
//
//  Created by Brett Walker on 6/2/16.
//  Copyright © 2016 Poet & Mountain, LLC. All rights reserved.
//

import UIKit

public class SequenceViewController: UIViewController, ButtonsViewDelegate {

    var createdUI: Bool = false
    var buttonsView: ButtonsView!
    var squares: [UIView] = []
    var sequence: MotionSequence!
    
    var constraints: [NSLayoutConstraint] = []
    
    
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
            sequence = MotionSequence(options: [.Reverse])
            .stepCompleted({ (sequence) in
                print("step complete")
            })
            .completed({ (sequence) in
                print("sequence complete")
            })
            
            for x in 0..<4 {
                let down = Motion(target: constraints[x],
                                   properties: [PropertyData("constant", 250.0)],
                                   duration: 0.6,
                                   easing: EasingQuartic.easeInOut())
                
                let color = Motion(target: squares[x],
                                    finalState: ["backgroundColor" : UIColor.init(red: 91.0/255.0, green:189.0/255.0, blue:231.0/255.0, alpha:1.0)],
                                    duration: 0.7,
                                    easing: EasingQuadratic.easeInOut())
                
                let group = MotionGroup(motions: [down, color], options: [.Reverse])
                
                sequence.add(group)
            }
            createdUI = true
        }
        
    }
    
    
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        sequence.start()
    }
    
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        sequence.stop()
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
        
        
        // set up motion views
        
        var currx: CGFloat = 20.0
        let spacer: CGFloat = 20.0
        
        for _ in 0..<4 {
            let w: CGFloat = 40.0
            let square = UIView.init()
            square.backgroundColor = UIColor.init(red: 76.0/255.0, green:164.0/255.0, blue:68.0/255.0, alpha:1.0)
            square.layer.masksToBounds = true
            square.layer.cornerRadius = w * 0.5
            self.view.addSubview(square)
            square.translatesAutoresizingMaskIntoConstraints = false
            squares.append(square)
            
            // set up motion constraints
            let square_x = square.centerXAnchor.constraintEqualToAnchor(margins.leadingAnchor, constant: currx)
            square_x.active = true
            let square_y = square.centerYAnchor.constraintEqualToAnchor(margins.topAnchor, constant: topLayoutGuide.length+40.0)
            square_y.active = true
            let square_height = square.heightAnchor.constraintEqualToConstant(w)
            square_height.active = true
            let square_width = square.widthAnchor.constraintEqualToConstant(w)
            square_width.active = true
            
            constraints.append(square_y)
            
            currx += 40.0 + spacer
        }

    }
    
    
    // MARK: - ButtonsViewDelegate methods
    
    func didStart() {
        sequence.start()
    }
    
    func didStop() {
        sequence.stop()
    }
    
    func didPause() {
        sequence.pause()
    }
    
    func didResume() {
        sequence.resume()
    }


}

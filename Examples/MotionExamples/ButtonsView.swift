//
//  ButtonsView.swift
//  MotionExamples
//
//  Created by Brett Walker on 6/1/16.
//  Copyright © 2016 Poet & Mountain, LLC. All rights reserved.
//

import UIKit

protocol ButtonsViewDelegate {
    func didStart()
    func didStop()
    func didPause()
    func didResume()
}

public class ButtonsView: UIView {

    public var startButton: UIButton!
    public var stopButton: UIButton!
    public var pauseButton: UIButton!
    public var resumeButton: UIButton!
    
    var uiCreated: Bool = false
    
    var delegate: ButtonsViewDelegate?
    
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "ButtonsView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! UIView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    private func setupUI() {
        
        startButton = UIButton.init(type: .System)
        startButton.setTitle("Start", forState: .Normal)
        startButton.addTarget(self, action: #selector(start), forControlEvents: .TouchUpInside)
        self.addSubview(startButton)
        
        stopButton = UIButton.init(type: .System)
        stopButton.setTitle("Stop", forState: .Normal)
        stopButton.addTarget(self, action: #selector(stop), forControlEvents: .TouchUpInside)
        self.addSubview(stopButton)
        
        pauseButton = UIButton.init(type: .System)
        pauseButton.setTitle("Pause", forState: .Normal)
        pauseButton.addTarget(self, action: #selector(pause), forControlEvents: .TouchUpInside)
        self.addSubview(pauseButton)
        
        resumeButton = UIButton.init(type: .System)
        resumeButton.setTitle("Resume", forState: .Normal)
        resumeButton.addTarget(self, action: #selector(resume), forControlEvents: .TouchUpInside)
        self.addSubview(resumeButton)
        
        // setup constraints
        startButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        resumeButton.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["start" : startButton,
                     "stop" : stopButton,
                     "pause" : pauseButton,
                     "resume" : resumeButton]
        
        let hconstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[start(60)]-20-[stop(60)]-20-[pause(60)]-20-[resume(60)]",
                                                       options: [],
                                                       metrics: nil,
                                                       views: views)
        NSLayoutConstraint.activateConstraints(hconstraints)
        
        NSLayoutConstraint.init(item: startButton,
                                attribute: .Bottom,
                                relatedBy: .Equal,
                                toItem: self,
                                attribute: .Bottom,
                                multiplier: 1.0,
                                constant: -20.0).active = true
        
        NSLayoutConstraint.init(item: startButton,
                                attribute: .Height,
                                relatedBy: .Equal,
                                toItem: nil,
                                attribute: .NotAnAttribute,
                                multiplier: 1.0,
                                constant: 44.0).active = true
        
        NSLayoutConstraint.init(item: stopButton,
                                attribute: .Bottom,
                                relatedBy: .Equal,
                                toItem: self,
                                attribute: .Bottom,
                                multiplier: 1.0,
                                constant: -20.0).active = true
        
        NSLayoutConstraint.init(item: stopButton,
                                attribute: .Height,
                                relatedBy: .Equal,
                                toItem: nil,
                                attribute: .NotAnAttribute,
                                multiplier: 1.0,
                                constant: 44.0).active = true
        
        NSLayoutConstraint.init(item: pauseButton,
                                attribute: .Bottom,
                                relatedBy: .Equal,
                                toItem: self,
                                attribute: .Bottom,
                                multiplier: 1.0,
                                constant: -20.0).active = true
        
        NSLayoutConstraint.init(item: pauseButton,
                                attribute: .Height,
                                relatedBy: .Equal,
                                toItem: nil,
                                attribute: .NotAnAttribute,
                                multiplier: 1.0,
                                constant: 44.0).active = true
        
        NSLayoutConstraint.init(item: resumeButton,
                                attribute: .Bottom,
                                relatedBy: .Equal,
                                toItem: self,
                                attribute: .Bottom,
                                multiplier: 1.0,
                                constant: -20.0).active = true
        
        NSLayoutConstraint.init(item: resumeButton,
                                attribute: .Height,
                                relatedBy: .Equal,
                                toItem: nil,
                                attribute: .NotAnAttribute,
                                multiplier: 1.0,
                                constant: 44.0).active = true
    }

    

    
    func start() {
        delegate?.didStart()
    }
    
    func stop() {
        delegate?.didStop()
    }
    
    func pause() {
        delegate?.didPause()
    }
    
    func resume() {
        delegate?.didResume()
    }

}

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
        return UINib(nibName: "ButtonsView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    private func setupUI() {
        
        startButton = UIButton.init(type: .system)
        startButton.setTitle("Start", for: UIControlState())
        startButton.addTarget(self, action: #selector(start), for: .touchUpInside)
        self.addSubview(startButton)
        
        stopButton = UIButton.init(type: .system)
        stopButton.setTitle("Stop", for: UIControlState())
        stopButton.addTarget(self, action: #selector(stop), for: .touchUpInside)
        self.addSubview(stopButton)
        
        pauseButton = UIButton.init(type: .system)
        pauseButton.setTitle("Pause", for: UIControlState())
        pauseButton.addTarget(self, action: #selector(pause), for: .touchUpInside)
        self.addSubview(pauseButton)
        
        resumeButton = UIButton.init(type: .system)
        resumeButton.setTitle("Resume", for: UIControlState())
        resumeButton.addTarget(self, action: #selector(resume), for: .touchUpInside)
        self.addSubview(resumeButton)
        
        // setup constraints
        startButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        resumeButton.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String:AnyObject] = ["start" : startButton,
                     "stop" : stopButton,
                     "pause" : pauseButton,
                     "resume" : resumeButton]
        
        let hconstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[start(60)]-20-[stop(60)]-20-[pause(60)]-20-[resume(60)]",
                                                       options: [],
                                                       metrics: nil,
                                                       views: views)
        NSLayoutConstraint.activate(hconstraints)
        
        NSLayoutConstraint.init(item: startButton,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: self,
                                attribute: .bottom,
                                multiplier: 1.0,
                                constant: -20.0).isActive = true
        
        NSLayoutConstraint.init(item: startButton,
                                attribute: .height,
                                relatedBy: .equal,
                                toItem: nil,
                                attribute: .notAnAttribute,
                                multiplier: 1.0,
                                constant: 44.0).isActive = true
        
        NSLayoutConstraint.init(item: stopButton,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: self,
                                attribute: .bottom,
                                multiplier: 1.0,
                                constant: -20.0).isActive = true
        
        NSLayoutConstraint.init(item: stopButton,
                                attribute: .height,
                                relatedBy: .equal,
                                toItem: nil,
                                attribute: .notAnAttribute,
                                multiplier: 1.0,
                                constant: 44.0).isActive = true
        
        NSLayoutConstraint.init(item: pauseButton,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: self,
                                attribute: .bottom,
                                multiplier: 1.0,
                                constant: -20.0).isActive = true
        
        NSLayoutConstraint.init(item: pauseButton,
                                attribute: .height,
                                relatedBy: .equal,
                                toItem: nil,
                                attribute: .notAnAttribute,
                                multiplier: 1.0,
                                constant: 44.0).isActive = true
        
        NSLayoutConstraint.init(item: resumeButton,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: self,
                                attribute: .bottom,
                                multiplier: 1.0,
                                constant: -20.0).isActive = true
        
        NSLayoutConstraint.init(item: resumeButton,
                                attribute: .height,
                                relatedBy: .equal,
                                toItem: nil,
                                attribute: .notAnAttribute,
                                multiplier: 1.0,
                                constant: 44.0).isActive = true
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

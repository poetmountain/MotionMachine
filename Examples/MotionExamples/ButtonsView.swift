//
//  ButtonsView.swift
//  MotionExamples
//
//  Copyright © 2024 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit

@MainActor protocol ButtonsViewDelegate: AnyObject {
    func didStart()
    func didStop()
    func didPause()
    func didResume()
}

public class ButtonsView: UIView {

    public var startButton: UIButton = {
        return UIButton.init(type: .system)
    }()
    public var stopButton: UIButton = {
        return UIButton.init(type: .system)
    }()
    public var pauseButton: UIButton = {
        return UIButton.init(type: .system)
    }()
    public var resumeButton: UIButton = {
        return UIButton.init(type: .system)
    }()
    
    var uiCreated: Bool = false
    
    weak var delegate: ButtonsViewDelegate?
    
    
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
        
        startButton.setTitle("Start", for: UIControl.State())
        startButton.addTarget(self, action: #selector(start), for: .touchUpInside)
        self.addSubview(startButton)
        
        stopButton.setTitle("Stop", for: UIControl.State())
        stopButton.addTarget(self, action: #selector(stop), for: .touchUpInside)
        self.addSubview(stopButton)
        
        pauseButton.setTitle("Pause", for: UIControl.State())
        pauseButton.addTarget(self, action: #selector(pause), for: .touchUpInside)
        self.addSubview(pauseButton)
        
        resumeButton.setTitle("Resume", for: UIControl.State())
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

    

    
    @objc func start() {
        delegate?.didStart()
    }
    
    @objc func stop() {
        delegate?.didStop()
    }
    
    @objc func pause() {
        delegate?.didPause()
    }
    
    @objc func resume() {
        delegate?.didResume()
    }

}

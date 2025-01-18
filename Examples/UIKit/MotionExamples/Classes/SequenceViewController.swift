//
//  SequenceNoncontiguousViewController.swift
//  MotionExamples
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import MotionMachine

public class SequenceViewController: UIViewController, ButtonsViewDelegate {

    var createdUI: Bool = false
    var buttonsView: ButtonsView!
    var squares: [UIView] = []
    var sequence: MotionSequence!
    
    var constraints: [NSLayoutConstraint] = []
    
    let numCircles = 5
    
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
            sequence = MotionSequence(options: [.reverses, .repeats])

            for x in 0..<numCircles {
                let down = Motion(target: squares[x],
                                  properties: [PropertyData(keyPath: \UIView.center.y, end: 250.0)],
                                   duration: 0.6,
                                  easing: EasingQuadratic.easeInOut())
                
                let color = Motion(target: squares[x],
                                   states: MotionState(keyPath: \UIView.backgroundColor[default: .systemGreen], end: .systemBlue),
                                    duration: 0.7,
                                    easing: EasingQuadratic.easeInOut())
                
                let group = MotionGroup(motions: [down, color], options: [.reverses])
                
                sequence.add(group)
            }
            createdUI = true
        }
        
    }
    
    
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        sequence.start()
    }
    
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sequence.stop()
        for step in sequence.steps {
            sequence.remove(step)
        }
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
        
        buttonsView = ButtonsView.init(frame: CGRect.zero)
        view.addSubview(buttonsView)
        buttonsView.delegate = self
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        
        buttonsView.widthAnchor.constraint(equalTo: margins.widthAnchor, constant: 0.0).isActive = true
        buttonsView.heightAnchor.constraint(equalTo: margins.heightAnchor, constant: 0.0).isActive = true
        
        
        // set up motion views
        
        var currx: CGFloat = 48.0
        let spacer: CGFloat = 20.0
        
        for _ in 0..<numCircles {
            let diameter: CGFloat = 40.0
            let square = UIView.init()
            square.backgroundColor = .systemGreen
            square.layer.masksToBounds = true
            square.layer.cornerRadius = diameter * 0.5
            self.view.addSubview(square)
            squares.append(square)
            
            square.frame = CGRect(x: currx, y: 120, width: diameter, height: diameter)
            
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

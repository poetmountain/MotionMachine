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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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
                                   statesForProperties: [PropertyStates(path: "backgroundColor", end: UIColor.init(red: 91.0/255.0, green:189.0/255.0, blue:231.0/255.0, alpha:1.0))],
                                    duration: 0.7,
                                    easing: EasingQuadratic.easeInOut())
                
                let group = MotionGroup(motions: [down, color], options: [.Reverse])
                
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
    }
    
    deinit {
        (view as! ButtonsView).delegate = nil
    }
    
    
    
    
    // MARK: - Private methods
    
    private func setupUI() {
        view.backgroundColor = UIColor.white
        
        var margins : UILayoutGuide
        let top_offset : CGFloat = 20.0
        
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
        
        
        // set up motion views
        
        var currx: CGFloat = 48.0
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
            let square_x = square.centerXAnchor.constraint(equalTo: margins.leadingAnchor, constant: currx)
            square_x.isActive = true
            let square_y = square.topAnchor.constraint(equalTo: top_anchor, constant: top_offset)
            square_y.isActive = true
            let square_height = square.heightAnchor.constraint(equalToConstant: w)
            square_height.isActive = true
            let square_width = square.widthAnchor.constraint(equalToConstant: w)
            square_width.isActive = true
            
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

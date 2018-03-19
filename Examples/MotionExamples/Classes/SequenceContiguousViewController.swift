//
//  SequenceContiguousViewController.swift
//  MotionExamples
//
//  Created by Brett Walker on 6/2/16.
//  Copyright © 2016 Poet & Mountain, LLC. All rights reserved.
//

import UIKit

public class SequenceContiguousViewController: UIViewController, ButtonsViewDelegate {

    var createdUI: Bool = false
    var buttonsView: ButtonsView!
    var square: UIView!
    var sequence: MotionSequence!
    
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
    
    
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (!createdUI) {
            setupUI()
            
            // setup motion
            let new_x = Double((view.bounds.size.width * 0.5))
            let move_right = Motion(target: constraints["x"]!,
                                properties: [PropertyData("constant", new_x)],
                                  duration: 1.0,
                                    easing: EasingCubic.easeInOut())
            
            let move_down = Motion(target: constraints["y"]!,
                                   properties: [PropertyData("constant", Double(250.0))],
                                 duration: 0.8,
                                   easing: EasingQuartic.easeInOut())
            
            let change_color = Motion(target: square,
                                      statesForProperties: [PropertyStates(path: "backgroundColor", end: UIColor.init(red: 91.0/255.0, green:189.0/255.0, blue:231.0/255.0, alpha:1.0))],
                                    duration: 0.9,
                                      easing: EasingQuadratic.easeInOut())
            
            let expand_width = Motion(target: constraints["width"]!,
                                   properties: [PropertyData("constant", 150.0)],
                                   duration: 0.8,
                                   easing: EasingCubic.easeInOut())
            
            let expand_height = Motion(target: constraints["height"]!,
                                  properties: [PropertyData("constant", 150.0)],
                                    duration: 0.8,
                                      easing: EasingCubic.easeInOut())
            
            let corner_radius = Motion(target: square,
                                       properties: [PropertyData("layer.cornerRadius", 75.0)],
                                       duration: 0.8,
                                       easing: EasingCubic.easeInOut())
            
            let group = MotionGroup(motions: [move_right, change_color])
            let expand_group = MotionGroup(motions: [expand_width, expand_height, corner_radius])
            
            sequence = MotionSequence(steps: [group, move_down, expand_group], options: [.Reverse])
            .stepCompleted({ (sequence) in
                print("step complete")
            })
            .completed({ (sequence) in
                print("sequence complete")
            })
            sequence.reversingMode = .contiguous
            
            
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
        let top_offset : CGFloat = 40.0
        
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
        
        square = UIView.init()
        square.backgroundColor = UIColor.init(red: 76.0/255.0, green:164.0/255.0, blue:68.0/255.0, alpha:1.0)
        square.layer.masksToBounds = true
        square.layer.cornerRadius = 20.0
        self.view.addSubview(square)

        
        // set up motion constraints
        square.translatesAutoresizingMaskIntoConstraints = false
        
        var top_anchor: NSLayoutYAxisAnchor
        if #available(iOS 11.0, *) {
            top_anchor = margins.topAnchor
        } else {
            top_anchor = margins.bottomAnchor
        }
        
        let square_x = square.centerXAnchor.constraint(equalTo: margins.leadingAnchor, constant: top_offset)
        square_x.isActive = true
        let square_y = square.centerYAnchor.constraint(equalTo: top_anchor, constant: top_offset)
        square_y.isActive = true
        let square_height = square.heightAnchor.constraint(equalToConstant: 40.0)
        square_height.isActive = true
        let square_width = square.widthAnchor.constraint(equalToConstant: 40.0)
        square_width.isActive = true
        
        constraints["x"] = square_x
        constraints["y"] = square_y
        constraints["width"] = square_width
        constraints["height"] = square_height
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

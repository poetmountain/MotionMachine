//
//  PathPhysicsMotionViewController.swift
//  MotionExamples
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import MotionMachine

class PathPhysicsMotionViewController: UIViewController, ButtonsViewDelegate {

    lazy var buttonsView: ButtonsView = {
        return ButtonsView()
    }()
    
    lazy var motionView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(red: 76.0/255.0, green:164.0/255.0, blue:68.0/255.0, alpha:1.0)
        let diameter: CGFloat = 16.0
        view.backgroundColor = UIColor.init(red: 76.0/255.0, green:164.0/255.0, blue:68.0/255.0, alpha:1.0)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = diameter * 0.5
        view.frame = CGRect(x: -100, y: 0, width: diameter, height: diameter)
        return view
    }()
    

    lazy var pathView: PathView = {
        return PathView()
    }()
    
    
    var motion: PathPhysicsMotion?
    var pathState: PathState?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupMotion()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      
        motion?.start()
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
      
        motion?.stop()
    }


    private func setupMotion() {
        let path = UIBezierPath(arcCenter: CGPoint(x: 20, y: 20), radius: 200, startAngle: 0.087, endAngle: 1.66, clockwise: true)
        path.addQuadCurve(to: CGPoint(x: 20, y: 50), controlPoint: CGPoint(x: 100, y: 45))

        pathView.path = path

        let config = PhysicsConfiguration(velocity: 800, friction: 0.4, restitution: 0.7)
        motion = PathPhysicsMotion(path: path.cgPath, configuration: config)
        motion?.updated({ [weak pathView, weak view, weak motionView] (motion, currentPoint) in
            if let view, let adjustedPoint = pathView?.convert(currentPoint, to: view) {
                motionView?.center = adjustedPoint
            }
            
        })
        motion?.completed({ (motion, currentPoint) in
            print("completed!")
        })
    }
    
   
    private func setupUI() {
        view.backgroundColor = UIColor.white

        var margins : UILayoutGuide
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

        view.addSubview(buttonsView)
        buttonsView.delegate = self
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.widthAnchor.constraint(equalTo: margins.widthAnchor, constant: 0.0).isActive = true
        buttonsView.heightAnchor.constraint(equalTo: margins.heightAnchor, constant: 0.0).isActive = true

        self.view.addSubview(pathView)
        pathView.translatesAutoresizingMaskIntoConstraints = false
        pathView.topAnchor.constraint(equalTo: top_anchor, constant: 50.0).isActive = true
        pathView.leftAnchor.constraint(equalTo: margins.leftAnchor, constant: 50.0).isActive = true
        pathView.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
        pathView.heightAnchor.constraint(equalToConstant: 300.0).isActive = true

        self.view.addSubview(motionView)

    }


    // MARK: - ButtonsViewDelegate methods

    func didStart() {
        motion?.start()
    }

    func didStop() {
        motion?.stop()
    }

    func didPause() {
        motion?.pause()
    }

    func didResume() {
        motion?.resume()
    }


}

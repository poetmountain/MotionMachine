//
//  PathMotionContiguousViewController.swift
//  MotionExamples
//
//  Copyright © 2025 Poet & Mountain, LLC. All rights reserved.
//  https://github.com/poetmountain
//
//  Licensed under MIT License. See LICENSE file in this repository.

import UIKit
import MotionMachine

class PathMotionContiguousViewController: UIViewController, ButtonsViewDelegate {

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
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12.0)
        label.isUserInteractionEnabled = false
        label.text = "contiguousEdges edge behavior allows motions to seamlessly travel beyond one edge of the path to the other."
        label.numberOfLines = 4
        return label
    }()

    lazy var pathView: PathView = {
        return PathView()
    }()

    
    var motion: PathMotion?
    var pathState: PathState?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupMotion()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      
        Task {
            await pathState?.setupPerformanceMode()
            motion?.start()
        }
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
      
        motion?.stop()
    }


    private func setupMotion() {
        let lineWidth = 2.0
        let rect: CGRect = CGRect(x: 0, y: 0, width: 320, height: 320).insetBy(dx: lineWidth, dy: lineWidth)
        let radius: CGFloat = rect.width * 0.25
        let rectPath = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        pathView.path = rectPath
        
        motion = PathMotion(path: rectPath.cgPath, duration: 2, endPosition: 1.0, easing: EasingElastic.easeInOut(), edgeBehavior: .contiguousEdges)
        .repeats()
        .reverses(withEasing: EasingBack.easeInOut())
        
        motion?.updated({ [weak pathView, weak view, weak motionView] (motion, currentPoint) in
            if let view, let adjustedPoint = pathView?.convert(currentPoint, to: view) {
                motionView?.center = adjustedPoint
            }
            
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
        
        self.view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: top_anchor, constant: 30.0).isActive = true
        label.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 30).isActive = true
        label.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -30).isActive = true
        
        view.addSubview(buttonsView)
        buttonsView.delegate = self
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.widthAnchor.constraint(equalTo: margins.widthAnchor, constant: 0.0).isActive = true
        buttonsView.heightAnchor.constraint(equalTo: margins.heightAnchor, constant: 0.0).isActive = true

        self.view.addSubview(pathView)
        pathView.translatesAutoresizingMaskIntoConstraints = false
        pathView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 30.0).isActive = true
        pathView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0.0).isActive = true
        pathView.widthAnchor.constraint(equalToConstant: 320.0).isActive = true
        pathView.heightAnchor.constraint(equalToConstant: 320.0).isActive = true

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

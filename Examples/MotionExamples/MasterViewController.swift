//
//  MasterViewController.swift
//  MotionExamples
//
//  Created by Brett Walker on 6/1/16.
//  Copyright © 2016 Poet & Mountain, LLC. All rights reserved.
//

import UIKit

enum ExampleTypes: Int {
    
    case basic                  = 0
    case group                  = 1
    case sequence               = 2
    case contiguousSequence     = 3
    case physics                = 4
    case additive               = 5
    case dynamic                = 6
    
}

class MasterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var tableView: UITableView!
    var examples = [String]()
    var uiCreated: Bool = false
    
    let CELL_IDENTIFIER = "Cell"
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        
        examples = ["Motion",
                    "Group",
                    "Sequence",
                    "Sequence (Contiguous)",
                    "Physics",
                    "Additive",
                    "Additive (Multiple)"
                    ]
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Examples"
        self.view.backgroundColor = UIColor.white()

    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if (!uiCreated) {
            setupUI()
            uiCreated = true
        }
    }
    
    
    
    // MARK: - Private methods
    
    private func setupUI() {
        tableView = UITableView.init()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.clipsToBounds = true
        tableView.estimatedRowHeight = 44.0
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CELL_IDENTIFIER)
        self.view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.init(item: tableView,
                           attribute: .width,
                           relatedBy: .equal,
                              toItem: view,
                           attribute: .width,
                          multiplier: 1.0,
                            constant: 0.0).isActive = true
        
        NSLayoutConstraint.init(item: tableView,
                                attribute: .height,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .height,
                                multiplier: 1.0,
                                constant: 0.0).isActive = true
        
    }
    
    
    // MARK: - Table View

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER, for: indexPath)

        
        let label_text = examples[(indexPath as NSIndexPath).row]
        cell.textLabel!.text = label_text
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = ExampleTypes(rawValue: (indexPath as NSIndexPath).row)
        
        if let type = index {
            var vc: UIViewController
            
            switch type {
            case .basic:
                vc = BasicMotionViewController()
                
            case .group:
                vc = GroupMotionViewController()
                
            case .sequence:
                vc = SequenceViewController()
                
            case .contiguousSequence:
                vc = SequenceContiguousViewController()
                
            case .physics:
                vc = PhysicsMotionViewController()
                
            case .additive:
                vc = AdditiveViewController()
                
            case .dynamic:
                vc = DynamicViewController()
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
            
            vc.title = examples[(indexPath as NSIndexPath).row]
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }

}


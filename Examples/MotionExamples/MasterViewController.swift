//
//  MasterViewController.swift
//  MotionExamples
//
//  Created by Brett Walker on 6/1/16.
//  Copyright © 2016 Poet & Mountain, LLC. All rights reserved.
//

import UIKit

enum ExampleTypes: Int {
    
    case Basic                  = 0
    case Group                  = 1
    case Sequence               = 2
    case ContiguousSequence     = 3
    case Physics                = 4
    case Additive               = 5
    case Dynamic                = 6
    
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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Examples"
        self.view.backgroundColor = UIColor.whiteColor()

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
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: CELL_IDENTIFIER)
        self.view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.init(item: tableView,
                           attribute: .Width,
                           relatedBy: .Equal,
                              toItem: view,
                           attribute: .Width,
                          multiplier: 1.0,
                            constant: 0.0).active = true
        
        NSLayoutConstraint.init(item: tableView,
                                attribute: .Height,
                                relatedBy: .Equal,
                                toItem: view,
                                attribute: .Height,
                                multiplier: 1.0,
                                constant: 0.0).active = true
        
    }
    
    
    // MARK: - Table View

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CELL_IDENTIFIER, forIndexPath: indexPath)

        
        let label_text = examples[indexPath.row]
        cell.textLabel!.text = label_text
        
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let index = ExampleTypes(rawValue: indexPath.row)
        
        if let type = index {
            var vc: UIViewController
            
            switch type {
            case .Basic:
                vc = BasicMotionViewController()
                
            case .Group:
                vc = GroupMotionViewController()
                
            case .Sequence:
                vc = SequenceViewController()
                
            case .ContiguousSequence:
                vc = SequenceContiguousViewController()
                
            case .Physics:
                vc = PhysicsMotionViewController()
                
            case .Additive:
                vc = AdditiveViewController()
                
            case .Dynamic:
                vc = DynamicViewController()
            }
            
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
            vc.title = examples[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }

}


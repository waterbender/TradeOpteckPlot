//
//  PlotViewController.swift
//  TradeOpteck
//
//  Created by Yevgenii Pasko on 4/27/18.
//  Copyright © 2018 Yevgenii Pasko. All rights reserved.
//

import UIKit
import CorePlot

class PlotViewController: UIViewController {
    
    var hostView: PlotGraphsView?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.hostView?.frame = self.view.bounds
        self.view.addSubview(self.hostView ?? UIView())
        self.hostView?.plotGraph()
    }
    
    // MARK: Initialization
    override func viewDidAppear(_ animated : Bool)
    {
        super.viewDidAppear(animated)
    }
}

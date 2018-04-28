//
//  PlotViewModel.swift
//  TradeOpteck
//
//  Created by Yevgenii Pasko on 4/27/18.
//  Copyright © 2018 Yevgenii Pasko. All rights reserved.
//

import Foundation

class PlotViewModel {
    private(set) var currentCurrencies:[Any]=[]
    var compliteViewControllerHandler: (()->())?
    var pointAxisValue: Int?
    private var timer: Timer?
    private var currencyObject: [String:String]?
    
    var currentObject: [String:String]? {
        set(value) {
            self.currencyObject = value
            self.loadData()
        }
        get {
            return self.currencyObject
        }
    }
    
    func loadData()  {
        
        let queue = OperationQueue()
        queue.addOperation { [weak self] in
            let synchronizer = OpteckSynchronizer()
            let id = Int((self?.currentObject![Constants.AssetID]!)!)
            synchronizer.getInfoForId(assetID: id ?? 0, complitionBlock: {[weak self] (array) in
                
                self?.currentCurrencies.removeAll()
                self?.currentCurrencies.append(contentsOf: array)
                
                if let compliteHandler = self?.compliteViewControllerHandler {
                    self?.pointAxisValue = (self?.currentCurrencies.count ?? 0) / 24
                    self?.pointAxisValue = self?.pointAxisValue == 0 ? 1 : self?.pointAxisValue
                    RunLoop.main.perform {
                        compliteHandler()
                        self?.timer = Timer(timeInterval: 1, repeats: false, block: { (timer) in
                            self?.loadData()
                        })
                        self?.timer?.fire()
                    }
                }
            })
        }
    }
}

extension Int {
    subscript(currencyDict: [String:String]) -> Int {
        set {
            self = Int(currencyDict[Constants.AssetID]!)!
        }
        get {
            return self
        }
    }
}

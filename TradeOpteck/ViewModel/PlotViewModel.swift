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
    var timer: Timer?
    var currencyObject: [String:String]?

    
    func startUpdatesTimer() {
        
        timer = Timer(timeInterval: 1, repeats: false, block: {  [weak self] (timer) in
            self?.loadData()
        })
        timer?.fire()
    }
    
    func loadData()  {
        
        let queue = OperationQueue()
        queue.addOperation { [weak self] in
            let synchronizer = OpteckSynchronizer()
            let id = Int((self?.currencyObject?[Constants.AssetID]) ?? "0") 
            synchronizer.getInfoForId(assetID: id ?? 0, complitionBlock: {[weak self] (array) in
                
                self?.currentCurrencies.removeAll()
                self?.currentCurrencies.append(contentsOf: array)
                
                if let compliteHandler = self?.compliteViewControllerHandler {
                    
                    self?.pointAxisValue = (self?.currentCurrencies.count ?? 0) / 24
                    self?.pointAxisValue = self?.pointAxisValue == 0 ? 1 : self?.pointAxisValue
                    compliteHandler()
                    self?.startUpdatesTimer()
                }
            })
        }
    }
    
    deinit {
         self.timer?.invalidate()
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

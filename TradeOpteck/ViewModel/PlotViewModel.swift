//
//  PlotViewModel.swift
//  TradeOpteck
//
//  Created by Yevgenii Pasko on 4/27/18.
//  Copyright © 2018 Yevgenii Pasko. All rights reserved.
//

class PlotViewModel {
    private(set) var currentCurrencies:[Any]=[]
    var compliteViewControllerHandler: (()->())?
    var pointAxisValue: Int?
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
        let synchronizer = OpteckSynchronizer()
        let id = Int(currentObject![Constants.AssetID]!)
        synchronizer.getInfoForId(assetID: id ?? 0, complitionBlock: {[weak self] (array) in
            
            self?.currentCurrencies.append(contentsOf: array)
            if let compliteHandler = self?.compliteViewControllerHandler {
                self?.pointAxisValue = (self?.currentCurrencies.count ?? 0) / 24
                self?.pointAxisValue = self?.pointAxisValue == 0 ? 1 : self?.pointAxisValue
                compliteHandler()
            }
        })
    }

    init() {
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

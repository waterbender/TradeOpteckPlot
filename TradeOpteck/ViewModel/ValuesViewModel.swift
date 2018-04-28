//
//  ValuesViewModel.swift
//  TradeOpteck
//
//  Created by Yevgenii Pasko on 4/26/18.
//  Copyright © 2018 Yevgenii Pasko. All rights reserved.
//

class ValuesViewModel {

    private(set) var currentCurrencies:[Any]=[]
    var compliteViewControllerHandler: (()->())?
    
    func loadData()  {
        let synchronizer = OpteckSynchronizer()
        synchronizer.getValues(complitionBlock: {[weak self] (array) in
            self?.currentCurrencies.removeAll()
            self?.currentCurrencies.append(contentsOf: array)
            if let compliteHandler = self?.compliteViewControllerHandler {
                compliteHandler()
            }
        })
    }
    
    init() {
        self.loadData()
    }
}

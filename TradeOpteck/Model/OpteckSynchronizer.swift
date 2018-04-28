//
//  OpteckSynchronizer.swift
//  TradeOpteck
//
//  Created by Yevgenii Pasko on 4/26/18.
//  Copyright © 2018 Yevgenii Pasko. All rights reserved.
//

import UIKit

class OpteckSynchronizer {

    func getValues(complitionBlock:@escaping ([Any])->()) {
        
        let urlString = "\(Constants.DefaultProtocol)://trade.opteck.com/cfd?game_type=forex&tab=crypto"
        //"\(Constants.DefaultProtocol)://\(Constants.DefaultHost)/\(Constants.AssetsLoadMethod)"
        let webClient = WebAndFilesClient()
        webClient.getRequestList(urlString: urlString) { (data) in
            do {
                let parser = SubParser()
                let valutesArray = try parser.parseSectionsWithCode(codeData: data)
                complitionBlock(valutesArray)
            } catch {
                print(error)
            }
        }
    }
    
    func getInfoForId(assetID: Int, complitionBlock:@escaping ([Any])->()) {
        
        let urlString = "\(Constants.DefaultProtocol)://trade.opteck.com/info/load_candlestick_history/?assetId=\(assetID)&type=H1&limit=24&bn=0"
        let webClient = WebAndFilesClient()
        webClient.getRequestList(urlString: urlString) { (data) in
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(.dateDecoderFormater)
                var values = try decoder.decode([CurrencyObject].self, from: data)
                values.sort(by: { $0.createdAt < $1.createdAt })
                complitionBlock(values)
            } catch {
                print(error)
            }
        }
    }
}

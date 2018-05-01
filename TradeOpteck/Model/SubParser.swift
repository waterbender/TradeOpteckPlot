//
//  SubParser.swift
//  TradeOpteck
//
//  Created by Yevgenii Pasko on 4/26/18.
//  Copyright © 2018 Yevgenii Pasko. All rights reserved.
//

import UIKit
import SwiftSoup


class SubParser {
    
    enum ParseError: Error {
        case invalidParseCode
    }

    func parseSectionsWithCode(codeData: Data) throws -> [Any] {
        
        var array = [Any]()
        

        do {
            let htmlCode = String(data: codeData, encoding: .ascii)
            let doc: Document = try SwiftSoup.parse(htmlCode!)
            
            var fullElements: [Element] = [Element]()
            let bodyActiveElements = try? doc.getElementsByClass("o-tr-line active-pr-alert")
            let bodyElements = try? doc.getElementsByClass("o-tr-line disabled active-pr-alert")
            
            if let notActive:[Element] = bodyElements?.array() {
                fullElements.append(contentsOf: notActive)
            }
            if let active:Array<Element> = bodyActiveElements?.array() {
                fullElements.append(contentsOf: active)
            }
            
            for element in fullElements {
                
                let attributesOfCurrency = element.getAttributes()
                
                let infoUp = try element.getElementsByClass(Constants.CellSellTdUp)
                if (infoUp.array().count > 0) {
                    
                    let value = getValue(arrayDownUp: infoUp)
                    
                    attributesOfCurrency?.put(attribute: try Attribute(key: Constants.CellSellTdUp, value: value))
                   // elementDict["cell sell-td up"] = value
                } else {
                    let infoDown = try element.getElementsByClass(Constants.CellSellTdDown)
                    let value = getValue(arrayDownUp: infoDown)
                    attributesOfCurrency?.put(attribute: try Attribute(key: Constants.CellSellTdDown, value: value))
                    //elementDict["cell sell-td down"] = value
                }
                
                let buyUp = try element.getElementsByClass("cell buy-td up")
                if (buyUp.array().count > 0) {
                    
                    let value = getValue(arrayDownUp: buyUp)
                    attributesOfCurrency?.put(attribute: try Attribute(key: Constants.CellBuyTdUp, value: value))
                    //elementDict["cell buy-td up"] = value
                } else {
                    let buyDown = try element.getElementsByClass(Constants.CellBuyTdDown)
                    let value = getValue(arrayDownUp: buyDown)
                    attributesOfCurrency?.put(attribute: try Attribute(key: Constants.CellBuyTdDown, value: value))
                    //elementDict["cell buy-td down"] = value
                }
                
                // addition of change
                let changePercentageArray = try element.getElementsByClass(Constants.CellChangeTD)
                let change = try changePercentageArray.first()?.after("TextNode")
                let changeValue = try change?.getElementsByClass("item")
                let firstElement = changeValue?.first()
                let resultDoubleString = try firstElement?.html().removeCharacters(from: CharacterSet(charactersIn: "01234567890.-").inverted)
                attributesOfCurrency?.put(attribute: try Attribute(key: Constants.CellChangeTD, value: resultDoubleString ?? "0.0"))
                
                if let elementAttributes = attributesOfCurrency {
                    
                    var currentElements = [String:String]()
                    
                    for object in elementAttributes {
                        currentElements[object.getKey()] = object.getValue()
                    }
                    array.append(currentElements)
                }
            }
            
        } catch {
            print("error")
        }
        
        return array
    }
    
    
    func getValue(arrayDownUp: Elements) -> String {
        
        let someElement = arrayDownUp.array().first
        let inheritElement = someElement?.children().first()
        let child = inheritElement?.children().first()
        var htmlResult: String? = try! child?.html()
        htmlResult = htmlResult?.replacingOccurrences(of: "<span class=\"arrow-range\"></span> \n<span class=\"\">", with: "")
        let one333 = htmlResult?.removeCharacters(from: CharacterSet(charactersIn: "01234567890.").inverted)
        
        return one333!
    }
}

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }
    
    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
    
    func removeCharacters(from forbiddenChars: CharacterSet) -> String {
        let passed = self.unicodeScalars.filter { !forbiddenChars.contains($0) }
        return String(String.UnicodeScalarView(passed))
    }
    
    func removeCharacters(from: String) -> String {
        return removeCharacters(from: CharacterSet(charactersIn: from))
    }
}


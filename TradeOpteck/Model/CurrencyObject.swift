//
//  CurrencyObject.swift
//  TradeOpteck
//
//  Created by Yevgenii Pasko on 4/28/18.
//  Copyright © 2018 Yevgenii Pasko. All rights reserved.
//

import Foundation

class CurrencyObject: Codable {

    //String, URL, Bool and Date conform to Codable.
    var id: String
    var createdAt: Date
    var assetId: Int
    var minValue: Double
    var maxValue: Double
    var open: Double
    var closed: Double
    var start: String?
    var stop: String?
    var upDown: Bool
    var spread: Double
    var realStart: Int
    var dateHours: String {
        get {
            let stringDate = Formatter.dateDecoderFormater.string(from: createdAt)
            let arrayTimes = stringDate.components(separatedBy: " ")
            let timeComponents = arrayTimes[1].components(separatedBy: ":")
            let hours = timeComponents.first!
            let minutes = timeComponents[1]
            return "\(hours):\(minutes)"
        }
    }
    
    enum CodingKeys: String, CodingKey
    {
        case id = "id"
        case createdAt = "created_at"
        case assetId = "asset_id"
        case minValue = "min_value"
        case maxValue = "max_value"
        case open = "open"
        case closed = "closed"
        case start = "start"
        case stop = "stop"
        case upDown = "up_down"
        case spread = "spread"
        case realStart = "real_start"
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(assetId, forKey: .assetId)
        try container.encode(minValue, forKey: .minValue)
        try container.encode(maxValue, forKey: .maxValue)
        try container.encode(open, forKey: .open)
        try container.encode(closed, forKey: .closed)
        try container.encode(start, forKey: .start)
        try container.encode(stop, forKey: .stop)
        try container.encode(upDown, forKey: .upDown)
        try container.encode(spread, forKey: .spread)
        try container.encode(realStart, forKey: .realStart)
    }
    
    required init(from decoder: Decoder) throws
    {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(String.self, forKey: .id)
        createdAt = try values.decode(Date.self, forKey: .createdAt)
        assetId = Int(try values.decode(String.self, forKey: .assetId)) ?? 0
        minValue = Double(try values.decode(String.self, forKey: .minValue)) ?? 0.0
        maxValue = Double(try values.decode(String.self, forKey: .maxValue)) ?? 0.0
        open = Double(try values.decode(String.self, forKey: .open)) ?? 0.0
        closed = Double(try values.decode(String.self, forKey: .closed)) ?? 0.0
        
        do {
            start = try values.decodeIfPresent(String.self, forKey: CodingKeys.start)
        } catch {
            start = "\(String(describing: try values.decodeIfPresent(Int.self, forKey: .start)))"
        }
        do {
            stop = try values.decodeIfPresent(String.self, forKey: CodingKeys.stop)
        } catch {
            stop = "\(String(describing: try values.decodeIfPresent(Int.self, forKey: .stop)))"
        }
        
        upDown = Bool(try values.decode(String.self, forKey: .upDown)) ?? true
        spread = Double(try values.decode(String.self, forKey: .spread)) ?? 0.0
        realStart = Int(try values.decode(String.self, forKey: .realStart)) ?? 0
    }
}

extension Formatter {
    static let dateDecoderFormater: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return formatter
    }()
}

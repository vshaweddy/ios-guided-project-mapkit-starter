//
//  Quake.swift
//  Quakes
//
//  Created by Vici Shaweddy on 1/25/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation

struct QuakeResults: Decodable {
    let features: [Quake]
}

class Quake: Decodable {
    
    let magnitude: Double
    let place: String
    let time: Date
    let latitude: Double
    let longitude: Double
    
    enum QuakeCodingKeys: String, CodingKey {
        case magnitude = "mag"
        case properties
        case place
        case time
        case geometry
        case coordinates
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: QuakeCodingKeys.self)
        
        let properties = try container.nestedContainer(keyedBy: QuakeCodingKeys.self, forKey: .properties)
        
        self.magnitude = try properties.decode(Double.self, forKey: .magnitude)
        self.place = try properties.decode(String.self, forKey: .place)
        self.time = try properties.decode(Date.self, forKey: .time)
        
        
        let geometry = try container.nestedContainer(keyedBy: QuakeCodingKeys.self, forKey: .geometry)
        
        var coordinates = try geometry.nestedUnkeyedContainer(forKey: .coordinates)
        
        self.longitude = try coordinates.decode(Double.self)
        self.latitude = try coordinates.decode(Double.self)
        
//        super.init()
    }
    
    // for framework -- internal is only available to the classes of the framework
//    internal init(magnitude: Double, place: String, time: Date, latitude: Double, longitude: Double) {
//        self.magnitude = magnitude
//        self.place = place
//        self.time = time
//        self.latitude = latitude
//        self.longitude = longitude
//    }
}

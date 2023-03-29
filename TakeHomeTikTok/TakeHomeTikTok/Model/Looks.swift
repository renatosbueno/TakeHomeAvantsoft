//
//  Looks.swift
//  TakeHomeTikTok
//
//  Created by Renato Bueno on 29/03/23.
//

import Foundation

struct Object: Codable {
    var looks: [Looks]
}

struct Looks: Codable {
    
    var id: Int
    var songUrl: String
    var body: String
    var profilePictureUrl: String
    var username: String
    var compressedForIosUrl: String
}

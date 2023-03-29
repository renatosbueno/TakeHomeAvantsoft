//
//  NetworkEndpoint.swift
//  TakeHomeTikTok
//
//  Created by Renato Bueno on 29/03/23.
//

import Foundation

protocol NetworkEndpoint: AnyObject {
    var baseUrl: String { get }
    var path: String { get }
    var method: HttpMethod { get }
    var headers: [String: String] { get }
}
extension NetworkEndpoint {
    
    var baseUrl: String {
        return Bundle.main.url(forResource: "data", withExtension: ".json")?.absoluteString ?? ""
    }
    
    var headers: [String: String] {
        return [:]
    }
    
    var path: String {
        return ""
    }
}

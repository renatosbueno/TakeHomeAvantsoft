//
//  HomeViewModelProtocols.swift
//  TakeHomeTikTok
//
//  Created by Renato Bueno on 29/03/23.
//

import UIKit

protocol HomeViewModelInputProtocol: AnyObject {
    func fetchData()
    func numberOfItems() -> Int
    func getCurrentId(atIndex index: IndexPath) -> Int?
    func getContentDTO(index: IndexPath) -> VideoContentView.DTO?
    func didSelectReaction(type: ReactionType, id: Int)
}

protocol HomeViewModelOutput: AnyObject {
    func didFinishRequest()
    func didFinishWithError()
    func updateReactionCounter(type: ReactionType, counter: Int, id: Int)
}

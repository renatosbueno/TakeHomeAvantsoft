//
//  HomeViewModel.swift
//  TakeHomeTikTok
//
//  Created by Renato Bueno on 29/03/23.
//

import Foundation

final class HomeViewModel {
    
    private let network = Networker()
    private var object: Object?
    private var reactionsCount: [Int: [ReactionType: Int]] = [:]
    
    weak var delegate: HomeViewModelOutput?

}
extension HomeViewModel: HomeViewModelInputProtocol {
    
    func fetchData() {
        let endpoint = Endpoint()
        network.request(endpoint: endpoint, type: Object.self) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let object):
                self.object = object
                self.delegate?.didFinishRequest()
            case .failure:
                self.delegate?.didFinishWithError()
            }
        }
    }
    
    func numberOfItems() -> Int {
        return object?.looks.count ?? 0
    }
    
    func getCurrentId(atIndex index: IndexPath) -> Int? {
        return object?.looks[index.row].id
    }
    
    func getContentDTO(index: IndexPath) -> VideoContentView.DTO? {
        guard let object = object else {
            return nil
        }
        let content = object.looks[index.row]
        let videoPath = Bundle.main.path(forResource: content.compressedForIosUrl, ofType: "mp4") ?? content.compressedForIosUrl
        let videoURL = URL(fileURLWithPath: videoPath)
        
        let profilePicPath = Bundle.main.path(forResource: content.profilePictureUrl, ofType: "jpeg") ?? content.profilePictureUrl
        
        return VideoContentView.DTO(id: content.id,
                                    leftActionCount: reactionsCount[content.id]?[.heart] ?? 0,
                                    rightActionCount: reactionsCount[content.id]?[.fire] ?? 0,
                                    videoUrl: videoURL,
                                    profilePicturePath: profilePicPath,
                                    videoTitle: content.body)
    }
    
    func didSelectReaction(type: ReactionType, id: Int) {
        let currentCount = reactionsCount[id]?[type] ?? 0
        if reactionsCount[id] != nil {
            reactionsCount[id]?[type] = currentCount + 1
        } else {
            reactionsCount[id] = [type: currentCount + 1]
        }
        let counter = reactionsCount[id]?[type] ?? 0
        delegate?.updateReactionCounter(type: type, counter: counter, id: id)
    }
    
}

fileprivate final class Endpoint: NetworkEndpoint {
    
    var method: HttpMethod {
        return .get
    }
    
}

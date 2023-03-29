//
//  TakeHomeTikTokTests.swift
//  TakeHomeTikTokTests
//
//  Created by Renato Bueno on 27/03/23.
//

import XCTest
@testable import TakeHomeTikTok

final class TakeHomeTikTokTests: XCTestCase {
    
    private let viewModel = HomeViewModel()
    private let spy = HomeViewControllerSpy()

    override func setUp() {
        super.setUp()
        viewModel.delegate = spy
    }
    
    func testSpy() {
        let expectation = expectation(description: "Waiting for request")
        viewModel.fetchData()
        viewModel.didSelectReaction(type: .heart, id: 1)
        
        let result = XCTWaiter.wait(for: [expectation], timeout: 1.0)
        
        if result == .timedOut {
            XCTAssertTrue(spy.didFinishRequestCalled)
            XCTAssertFalse(spy.didFinishWithErrorCalled)
            XCTAssertTrue(spy.updateReactionCounterCalled)
            XCTAssertEqual(spy.id, 1)
            XCTAssertEqual(spy.counter, 1)
            XCTAssertEqual(spy.type, ReactionType.heart)
        }
    }
    
    func testReactionCount() {
        let expectation = expectation(description: "Waiting for request")
        viewModel.fetchData()
        viewModel.didSelectReaction(type: .fire, id: 1)
        viewModel.didSelectReaction(type: .fire, id: 1)
        
        let result = XCTWaiter.wait(for: [expectation], timeout: 1.0)
        
        if result == .timedOut {
            XCTAssertTrue(spy.updateReactionCounterCalled)
            XCTAssertEqual(spy.id, 1)
            XCTAssertEqual(spy.counter, 2)
            XCTAssertEqual(spy.type, ReactionType.fire)
        }
    }
    
    func testDTO() {
        let expectation = expectation(description: "Waiting for request")
        viewModel.fetchData()
        
        let result = XCTWaiter.wait(for: [expectation], timeout: 1.0)
        
        if result == .timedOut {
            let indexPath = IndexPath(row: 0, section: 0)
            let mockDTO = VideoContentView.DTO(id: 1,
                                               leftActionCount: 0,
                                               rightActionCount: 0,
                                               profilePicturePath: "profile_1.jpeg",
                                               videoTitle: "Love this thrifted top with my handmade choker!")
            XCTAssertEqual(viewModel.getContentDTO(index: indexPath)?.id, mockDTO.id)
            XCTAssertEqual(viewModel.getContentDTO(index: indexPath)?.leftActionCount, mockDTO.leftActionCount)
            XCTAssertEqual(viewModel.getContentDTO(index: indexPath)?.rightActionCount, mockDTO.rightActionCount)
            XCTAssertEqual(viewModel.getContentDTO(index: indexPath)?.videoTitle, mockDTO.videoTitle)
        }
    }
    
    func testNumberOfItemsAndId() {
        let expectation = expectation(description: "Waiting for request")
        viewModel.fetchData()
        
        let result = XCTWaiter.wait(for: [expectation], timeout: 1.0)
        
        if result == .timedOut {
            XCTAssertEqual(viewModel.numberOfItems(), 4)
            XCTAssertEqual(viewModel.getCurrentId(atIndex: IndexPath(row: 0, section: 0)), 1)
        }
    }
}

fileprivate final class HomeViewControllerSpy: HomeViewModelOutput {
    
    private(set) var didFinishRequestCalled = false
    private(set) var didFinishWithErrorCalled = false
    private(set) var updateReactionCounterCalled = false
    
    private(set) var type: ReactionType?
    private(set) var counter: Int = 0
    private(set) var id: Int?
    
    func didFinishRequest() {
        didFinishRequestCalled = true
    }
    
    func didFinishWithError() {
        didFinishWithErrorCalled = true
    }
    
    func updateReactionCounter(type: ReactionType, counter: Int, id: Int) {
        updateReactionCounterCalled = true
        
        self.type = type
        self.counter = counter
        self.id = id
    }
}

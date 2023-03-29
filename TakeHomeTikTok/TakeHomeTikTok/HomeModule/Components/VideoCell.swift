//
//  VideoCell.swift
//  TakeHomeTikTok
//
//  Created by Renato Bueno on 29/03/23.
//

import UIKit

final class VideoCell: UICollectionViewCell {
    
    private lazy var view: VideoContentView = {
        let view = VideoContentView(frame: self.contentView.bounds)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    weak var delegate: VideoContentViewDelegate? {
        didSet {
            view.delegate = delegate
        }
    }
    
    var currentId: Int {
        return view.currentId
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(view)
        self.contentView.backgroundColor = .clear
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        view.stopLoopingVideo()
    }
        
    func renderContent(dto: VideoContentView.DTO) {
        view.renderContent(dto: dto)
    }
    
    func updateCounter(type: ReactionType, count: Int) {
        view.updateCounter(type: type, count: count)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            self.view.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            self.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
        ])
    }
}

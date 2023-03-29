//
//  VideoContentView.swift
//  TakeHomeTikTok
//
//  Created by Renato Bueno on 29/03/23.
//

import UIKit
import AVFoundation

protocol VideoContentViewDelegate: AnyObject {
    func didSelectReaction(type: ReactionType, id: Int)
}

protocol VideoContentTheme {
    var titleFont: UIFont { get }
    var reactionButtonsFont: UIFont { get }
    var reactionLabelFont: UIFont { get }
    var margin: CGFloat { get }
    var buttonSize: CGFloat { get }
    var profileTopAnchor: CGFloat { get }
}

final class VideoContentDefaultTheme: VideoContentTheme {
    
    var titleFont: UIFont {
        return .systemFont(ofSize: 16, weight: .semibold)
    }
    
    var reactionButtonsFont: UIFont {
        return .systemFont(ofSize: 42)
    }
    
    var reactionLabelFont: UIFont {
        return .systemFont(ofSize: 20)
    }
    
    var margin: CGFloat {
        return 16
    }
    
    var buttonSize: CGFloat {
        return 48
    }
    
    var profileTopAnchor: CGFloat {
        return 32
    }
}

final class VideoContentView: UIView {
    
    private lazy var videoView: UIView = {
        let view = UIView(frame: self.frame)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer()
        layer.frame = self.bounds
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    private var playerLooper: AVPlayerLooper?
    
    private lazy var profileImageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = .white
        label.sizeToFit()
        label.font = theme.titleFont
        label.numberOfLines = .zero
        return label
    }()
    
    private lazy var leftReactionButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.addTarget(self, action: #selector(leftAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("❤️", for: .normal)
        button.titleLabel?.font = theme.reactionButtonsFont
        return button
    }()
    
    private lazy var leftReactioLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = theme.reactionLabelFont
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    private lazy var rightReactionButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.addTarget(self, action: #selector(rightAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("🔥", for: .normal)
        button.titleLabel?.font = theme.reactionButtonsFont
        return button
    }()
    
    private lazy var rightReactioLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = theme.reactionLabelFont
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    weak var delegate: VideoContentViewDelegate?
    private lazy var theme: VideoContentTheme = VideoContentDefaultTheme()
    
    private(set) var currentId: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layoutIfNeeded()
        profileImageView.layer.cornerRadius = profileImageView.layer.bounds.width / 2
        profileImageView.clipsToBounds = true
    }
    
    struct DTO: Equatable {
        var id: Int
        var leftActionCount: Int
        var rightActionCount: Int
        var videoUrl: URL?
        var profilePicturePath: String
        var videoTitle: String
    }
    
    func renderContent(dto: VideoContentView.DTO) {
        self.currentId = dto.id
        if let videoUrl = dto.videoUrl {
            let playerItem = AVPlayerItem(url: videoUrl)
            let player = AVQueuePlayer(playerItem: playerItem)
            playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
            playerLayer.player = player
            
            videoView.layer.addSublayer(playerLayer)
            player.play()
        }
        
        profileImageView.image = UIImage(named: dto.profilePicturePath)
        titleLabel.text = dto.videoTitle
        leftReactioLabel.text = "\(dto.leftActionCount)"
        rightReactioLabel.text = "\(dto.rightActionCount)"
    }
    
    func stopLoopingVideo() {
        guard let player = playerLooper else {
            return
        }
        player.disableLooping()
    }
    
    func updateCounter(type: ReactionType, count: Int) {
        switch type {
        case .heart:
            leftReactioLabel.text = "\(count)"
        case .fire:
            rightReactioLabel.text = "\(count)"
        }
    }
    
    @objc private func leftAction() {
        leftReactionButton.animateView()
        delegate?.didSelectReaction(type: .heart, id: currentId)
    }
    
    @objc private func rightAction() {
        rightReactionButton.animateView()
        delegate?.didSelectReaction(type: .fire, id: currentId)
    }
    
    private func setupView() {
        self.addSubview(videoView)
        self.addSubview(profileImageView)
        self.addSubview(titleLabel)
        self.addSubview(leftReactionButton)
        self.addSubview(leftReactioLabel)
        self.addSubview(rightReactionButton)
        self.addSubview(rightReactioLabel)
        
        self.sendSubviewToBack(videoView)
    }
    
    private func setupConstraints() {
        let margin: CGFloat = theme.margin
        let buttonSize: CGFloat = theme.buttonSize
        
        NSLayoutConstraint.activate([
            videoView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            videoView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            videoView.topAnchor.constraint(equalTo: self.topAnchor),
            videoView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            profileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: margin),
            profileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: theme.profileTopAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: buttonSize),
            profileImageView.heightAnchor.constraint(equalToConstant: buttonSize),
            
            titleLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: margin),
            titleLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            titleLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -margin),
            
            leftReactionButton.widthAnchor.constraint(equalToConstant: buttonSize),
            leftReactionButton.heightAnchor.constraint(equalToConstant: buttonSize),
            leftReactionButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: margin),
            leftReactionButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            leftReactioLabel.topAnchor.constraint(equalTo: leftReactionButton.bottomAnchor, constant: margin / 2),
            leftReactioLabel.widthAnchor.constraint(equalTo: leftReactionButton.widthAnchor),
            leftReactioLabel.centerXAnchor.constraint(equalTo: leftReactionButton.centerXAnchor),
            
            rightReactionButton.widthAnchor.constraint(equalTo: leftReactionButton.widthAnchor),
            rightReactionButton.heightAnchor.constraint(equalTo: leftReactionButton.heightAnchor),
            rightReactionButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -margin),
            rightReactionButton.centerYAnchor.constraint(equalTo: leftReactionButton.centerYAnchor),
            
            rightReactioLabel.topAnchor.constraint(equalTo: rightReactionButton.bottomAnchor, constant: margin / 2),
            rightReactioLabel.widthAnchor.constraint(equalTo: rightReactionButton.widthAnchor),
            rightReactioLabel.centerXAnchor.constraint(equalTo: rightReactionButton.centerXAnchor)
        ])
    }
}

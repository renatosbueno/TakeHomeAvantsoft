//
//  ViewController.swift
//  TakeHomeTikTok
//
//  Created by Renato Bueno on 28/03/23.
//

import UIKit

protocol HomeTheme {
    var reactionLabelSize: CGFloat { get }
    var margin: CGFloat { get }
    var buttonSize: CGFloat { get }
    var swipeAreaSize: CGFloat { get }
}

final class HomeControllerDefaultTheme: HomeTheme {
    
    var reactionLabelSize: CGFloat {
        return 28
    }
    
    var margin: CGFloat {
        return 16
    }
    
    var buttonSize: CGFloat {
        return 28
    }
    
    var swipeAreaSize: CGFloat {
        return 60
    }
}

final class HomeViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .vertical
        collectionViewLayout.itemSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        let collection = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collection.backgroundColor = .clear
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.isPagingEnabled = true
        collection.allowsSelection = false
        collection.delegate = self
        collection.dataSource = self
        return collection
    }()

    private lazy var leftReactionBGLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "❤️"
        label.font = .systemFont(ofSize: theme.reactionLabelSize)
        return label
    }()
    
    private lazy var rightReactionBGLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "🔥"
        label.font = .systemFont(ofSize: theme.reactionLabelSize)
        return label
    }()
    
    private lazy var theme: HomeTheme = HomeControllerDefaultTheme()
    
    private var swipeHeartGesture = UISwipeGestureRecognizer()
    private var swipeFireGesture = UISwipeGestureRecognizer()
    
    var viewModel: HomeViewModelInputProtocol

    init(viewModel: HomeViewModelInputProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        setupViewHierarchy()
        setupSwipeGestures()
        registerCell()
        setupConstraints()
        viewModel.fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func registerCell() {
        collectionView.register(VideoCell.self, forCellWithReuseIdentifier: String(describing: VideoCell.self))
    }
    
    private func setupViewHierarchy() {
        self.view.addSubview(collectionView)
        self.view.addSubview(leftReactionBGLabel)
        self.view.addSubview(rightReactionBGLabel)
        
        self.view.bringSubviewToFront(collectionView)
    }
    
    private func setupSwipeGestures() {
        swipeHeartGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeHeartAction))
        swipeHeartGesture.direction = .right
        swipeFireGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeFireAction))
        swipeFireGesture.direction = .left
        
        self.collectionView.addGestureRecognizer(swipeHeartGesture)
        self.collectionView.addGestureRecognizer(swipeFireGesture)
        
    }
    
    private func setupConstraints() {
        let margin: CGFloat = theme.margin
        let buttonSize: CGFloat = theme.buttonSize
        NSLayoutConstraint.activate([
            self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            leftReactionBGLabel.widthAnchor.constraint(equalToConstant: buttonSize),
            leftReactionBGLabel.heightAnchor.constraint(equalToConstant: buttonSize),
            leftReactionBGLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: margin),
            leftReactionBGLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            
            rightReactionBGLabel.widthAnchor.constraint(equalTo: leftReactionBGLabel.widthAnchor),
            rightReactionBGLabel.heightAnchor.constraint(equalTo: leftReactionBGLabel.heightAnchor),
            rightReactionBGLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -margin),
            rightReactionBGLabel.centerYAnchor.constraint(equalTo: leftReactionBGLabel.centerYAnchor)
        ])
    }
    
    private func leftBGAction() {
        leftReactionBGLabel.animateView()
        
        guard let visibleIndexPath = getCurrentVisibleCellIndexPath(), let id = viewModel.getCurrentId(atIndex: visibleIndexPath) else {
            return
        }
        didSelectReaction(type: .heart, id: id)
    }
    
    private func rightBGAction() {
        rightReactionBGLabel.animateView()
        
        guard let visibleIndexPath = getCurrentVisibleCellIndexPath(), let id = viewModel.getCurrentId(atIndex: visibleIndexPath) else {
            return
        }
        
        didSelectReaction(type: .fire, id: id)
    }
    
    private func getCurrentVisibleCellIndexPath() -> IndexPath? {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        return collectionView.indexPathForItem(at: visiblePoint)
    }
    
    @objc private func didSwipeHeartAction() {
        animateSwipe(reactionType: .heart)
    }
    
    private func animateSwipe(reactionType: ReactionType) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, animations: {
            let value: CGFloat = reactionType == .heart ? self.theme.swipeAreaSize : -self.theme.swipeAreaSize
            self.collectionView.transform = CGAffineTransform(translationX: value, y: .zero)
            self.view.backgroundColor = reactionType == .heart ? .purple : .orange
            
            self.makeActionForType(reactionType: reactionType)
   
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.view.backgroundColor = .black
                self.collectionView.transform = .identity
            }
        }
    }
    
    private func makeActionForType(reactionType: ReactionType) {
        switch reactionType {
        case .heart:
            self.leftBGAction()
        case .fire:
            self.rightBGAction()
        }
    }
    
    @objc private func didSwipeFireAction() {
        animateSwipe(reactionType: .fire)
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Something went wrong", message: "try again?", preferredStyle: .alert)
        let action = UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.viewModel.fetchData()
        }
        alert.addAction(action)
        self.present(alert, animated: true)
    }
}
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: VideoCell.self), for: indexPath) as? VideoCell else {
            return UICollectionViewCell()
        }
        if let dto = viewModel.getContentDTO(index: indexPath) {
            cell.renderContent(dto: dto)
        }
        cell.delegate = self
        return cell
    }
    
}
extension HomeViewController: HomeViewModelOutput {
    
    func updateReactionCounter(type: ReactionType, counter: Int, id: Int) {
        DispatchQueue.main.async {
            guard let cell = self.collectionView.visibleCells.first(where: { ($0 as? VideoCell)?.currentId == id }) as? VideoCell else {
                return
            }
            cell.updateCounter(type: type, count: counter)
        }
    }
    
    func didFinishRequest() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    func didFinishWithError() {
        DispatchQueue.main.async { [weak self] in
            self?.showErrorAlert()
        }
    }
    
}
extension HomeViewController: VideoContentViewDelegate {
    
    func didSelectReaction(type: ReactionType, id: Int) {
        viewModel.didSelectReaction(type: type, id: id)
    }
}


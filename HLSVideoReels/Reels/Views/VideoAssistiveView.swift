//
//  VideoAssistiveView.swift
//  HLSVideoReels
//
//  Created by Suresh on 02/02/24.
//

import Foundation
import UIKit

enum AssistiveOption: Codable, Equatable {
    
    case like(likes: Int), dislike, comment(comments: Int), share, remix, profile(urlString: String)
    
    var description: String {
        switch self {
        case .like(let likes):
            return "\(likes)"
        case .dislike:
            return "Dislike"
        case .comment(let comments):
            return "\(comments)"
        case .share:
            return "Share"
        case .remix:
            return "Remix"
        case .profile(let urlString):
            return urlString
        }
    }
    
    var imageName: String {
        switch self {
        case .like:
            return "ic_like"
        case .dislike:
            return "ic_dislike"
        case .comment:
            return "ic_comment"
        case .share:
            return "ic_share"
        case .remix:
            return "ic_remix"
        default:
            return ""
        }
    }
   
}


final class VideoAssistiveView: UIView {
    static let assitiveWidgetSide: CGFloat = 50
    static let assitiveWidgetPadding: CGFloat = 8
    private let viewModel = VideoAssitiveViewModel()
    private var collectionViewHeightAnchor: NSLayoutConstraint?
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = VideoAssistiveView.assitiveWidgetPadding
        layout.minimumInteritemSpacing = VideoAssistiveView.assitiveWidgetPadding
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ActionableImageCell.self, forCellWithReuseIdentifier: String(describing: ActionableImageCell.self))
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        collectionViewHeightAnchor = collectionView.heightAnchor.constraint(equalToConstant: 0)
        collectionViewHeightAnchor?.isActive = true
    }
}

extension VideoAssistiveView {
    
    func configure(video: Reel) {
        self.viewModel.reel = video
        let optionCount = CGFloat(viewModel.assistiveOptions.count)
        collectionViewHeightAnchor?.constant = (optionCount * VideoAssistiveView.assitiveWidgetSide) + (optionCount - 1) * VideoAssistiveView.assitiveWidgetPadding
        collectionView.reloadData()
    }
}

extension VideoAssistiveView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.assistiveOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ActionableImageCell.self), for: indexPath) as? ActionableImageCell else {
            return UICollectionViewCell()
        }
        cell.configure(option: viewModel.assistiveOptions[indexPath.item])
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: VideoAssistiveView.assitiveWidgetSide, height: VideoAssistiveView.assitiveWidgetSide)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let option = viewModel.assistiveOptions[indexPath.item]
        print("Selected \(option)")
    }
}

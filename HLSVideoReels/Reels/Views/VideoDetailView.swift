//
//  VideoDetailView.swift
//  HLSVideoReels
//
//  Created by Suresh on 02/02/24.
//

import Foundation
import UIKit
import SDWebImage

final class VideoDetailView: UIView {

    private let profileImageSide: CGFloat = 32
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = profileImageSide / 2.0
        return imageView
    }()
    
    private let profileIdLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    private lazy var subscribeButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("  Subscribe  ", for: .normal)
        button.setTitle("  Subcribed  ", for: .highlighted)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.white, for: .highlighted)
        button.layer.cornerRadius = self.profileImageSide/2.0
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.white, for: .highlighted)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let videoDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return label
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
        self.addSubview(profileImageView)
        self.addSubview(profileIdLabel)
        self.addSubview(subscribeButton)
        self.addSubview(videoDescriptionLabel)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: self.topAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: profileImageSide),
            profileImageView.heightAnchor.constraint(equalToConstant: profileImageSide),
            
            profileIdLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 2),
            profileIdLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            
            subscribeButton.leadingAnchor.constraint(equalTo: profileIdLabel.trailingAnchor, constant: 2),
            subscribeButton.heightAnchor.constraint(equalToConstant: profileImageSide),
            
            
            videoDescriptionLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 2),
            videoDescriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            videoDescriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            videoDescriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
            
            
        ])
    }
}

extension VideoDetailView {
    
    func configure(video: Reel) {
        profileImageView.sd_setImage(with: URL(string: video.profileImageUrl ?? ""))
        if let profileId = video.profileId {
            profileIdLabel.text = "@\(profileId)"
        }else {
            profileIdLabel.text = ""
        }
        subscribeButton.isHighlighted = video.isSubscribed ?? false
        subscribeButton.backgroundColor = (video.isSubscribed == true) ? UIColor(red: 246/255, green: -0/255, blue: 4/255, alpha: 1) : UIColor.white
        
        videoDescriptionLabel.text = video.description ?? ""
        
    }
}


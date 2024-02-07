//
//  ButtonCell.swift
//  HLSVideoReels
//
//  Created by Suresh on 02/02/24.
//

import Foundation
import UIKit

final class ActionableImageCell: UICollectionViewCell {

    // MARK: - UIView Configurations
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 4
        return imageView
    }()

    // MARK: - Private Variables
    private var redirectionUrl: String?
    var option: AssistiveOption?

    // MARK: - Life Cycle Methods
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            titleLabel.heightAnchor.constraint(equalToConstant: 12)
        
        ])
    }
    
    func configure(option: AssistiveOption) {
        self.option = option
        titleLabel.text = option.description
        switch option {
        case .profile(let urlString):
            imageView.sd_setImage(with: URL(string: urlString))
            titleLabel.isHidden = true
        default:
            let image = UIImage(named: option.imageName)?.withRenderingMode(.alwaysTemplate)
            imageView.image = image
            imageView.tintColor = .white
            titleLabel.isHidden = false
        }
    }
}

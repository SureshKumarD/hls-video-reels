//
//  ViewController.swift
//  HLSVideoReels
//
//  Created by Suresh on 05/01/24.
//

import UIKit
import AVKit

final class ReelsViewController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        collectionView.register(VideoPlayerCell.self, forCellWithReuseIdentifier: String(describing: VideoPlayerCell.self))
        collectionView.isPagingEnabled = true
        collectionView.isPrefetchingEnabled = true
        collectionView.contentInsetAdjustmentBehavior = .never
        return collectionView
    }()
    
    private let navigationTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title"
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.textColor = .white
        return label
    }()
    
    private let navigationSubTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 13.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Sub title"
        label.textAlignment = .left
        label.textColor = .white
        return label
    }()
    
    private lazy var navigationTitleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [navigationTitleLabel, navigationSubTitleLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 4
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.axis = .vertical
        return stackView
    }()
    
    private var abstractPlayer: AVPlayer?
    private let viewModel: ReelsViewModel
    init(viewModel: ReelsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        // Do any additional setup after loading the view.
        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.fetchReels()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.abstractPlayer?.replaceCurrentItem(with: nil)
    }
    
    private func setupView() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
        ])
    }
    
    private func fetchReels() {
        viewModel.fetchReels {
            collectionView.reloadData()
            collectionView.performBatchUpdates(nil) { _ in
                self.checkAndPlay()
                self.loadInitialUrls()
            }
        }
    }
    
    private func loadInitialUrls() {
        let videos = Array(self.viewModel.reels[0...min(0, viewModel.reels.count)])
        
        if let urlArray = getURLArray(from: videos) {
            print("***loadInitialUrls \(urlArray)")
            preloadURL(urlArray: urlArray)
        }
    }

    private func getURLArray(from reels: [Reel]) -> [URL]? {
        let urlArray = reels.compactMap { reel in
            return URL(string: reel.videoUrl ?? "")
       }
        return urlArray
    }
    
}

extension ReelsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.reels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: VideoPlayerCell.self), for: indexPath) as? VideoPlayerCell else {
            return UICollectionViewCell()
        }
        cell.reel = viewModel.reels[indexPath.item]
        cell.index = indexPath.item
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return UIScreen.main.bounds.size
    }

    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? VideoPlayerCell else { return }
        cell.pause(reason: .hidden)
        cell.removeTimerObserver()
    }

}

extension ReelsViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        let updatedIndexPaths = indexPaths + collectionView.indexPathsForVisibleItems.dropLast()
        let urlArray = updatedIndexPaths.compactMap { indexPath in
            return URL(string: viewModel.reels[indexPath.item].videoUrl ?? "")
        }
        preloadURL(urlArray: urlArray)
        print("***prefetching indexpaths \(updatedIndexPaths)")
        print("CollectionView prefetching \(urlArray)")
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
            print("cancelPrefetching *** ", indexPaths)
        
    }
    
}

extension ReelsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.navigationController?.navigationBar.isHidden = true
        checkAndPlay()
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.navigationController?.navigationBar.isHidden = false
    }
}

extension ReelsViewController {
    private func checkAndPlay() {
        let visibleCells = collectionView.visibleCells.compactMap { $0 as? VideoPlayerCell }
        visibleCells.forEach({
            let f = $0.frame
            let w = self.view.window!
            let rect = w.convert(f, from: $0.superview!)
            let inter = rect.intersection(w.bounds)
            let ratio = (inter.width * inter.height) / (f.width * f.height)
            if ratio > 0.5 {
                if !$0.isPlayRequested {
                    print("Play at index : \($0.index) and ratio: \(ratio)")
                    $0.play()
                }
            } else {
                $0.pause(reason: .hidden)
            }
        })
    }
    
    private func resetCells() {
        let visibleCells = collectionView.visibleCells.compactMap { $0 as? VideoPlayerCell }
        visibleCells.forEach { $0.resetPlayer() }
    }
}

extension ReelsViewController {
    func preloadURL(urlArray: [URL]) {
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = true
        urlArray.forEach { url in
            guard let videoURL = VideoManager.shared.reverseProxyURL(from: url) else { return }
            let asset = AVURLAsset(url: videoURL)
            let playerItem = AVPlayerItem(asset: asset)
            player.replaceCurrentItem(with: playerItem)
            self.abstractPlayer = player
        }
    }
}

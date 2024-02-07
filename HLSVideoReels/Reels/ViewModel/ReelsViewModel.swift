//
//  ReelsViewModel.swift
//  HLSVideoReels
//
//  Created by Suresh on 02/02/24.
//

import Foundation


final class ReelsViewModel {
    
    var reels: [Reel]
    init(reels: [Reel] = []) {
        self.reels = reels
    }
}
extension ReelsViewModel {
    
    func fetchReels(completion: () -> Void) {
        if let reels = StubLoader.loadPlayList() {
            self.reels = reels
        }
        completion()
    }
}

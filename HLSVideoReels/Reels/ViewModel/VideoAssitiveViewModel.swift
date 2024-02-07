//
//  VideoAssitiveViewModel.swift
//  HLSVideoReels
//
//  Created by Suresh on 07/02/24.
//

import Foundation

final class VideoAssitiveViewModel {
    
    var assitiveOptions = [AssitiveOptions]()
    var reel: Reel? {
        didSet {
            assitiveOptions.removeAll()
            composeAssitiveOptions()
        }
    }
    
   
}
extension VideoAssitiveViewModel {
    private func composeAssitiveOptions() {
        assitiveOptions.append(.like(likes: reel?.likes ?? 0))
        assitiveOptions.append(.dislike)
        assitiveOptions.append(.comment(comments: reel?.comments ?? 0))
        assitiveOptions.append(.share)
        assitiveOptions.append(.remix)
        assitiveOptions.append(.profile(urlString: reel?.profileImageUrl ?? ""))
    }
}
  

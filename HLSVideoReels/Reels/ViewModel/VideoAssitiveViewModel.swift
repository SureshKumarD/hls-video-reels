//
//  VideoAssitiveViewModel.swift
//  HLSVideoReels
//
//  Created by Suresh on 07/02/24.
//

import Foundation

final class VideoAssitiveViewModel {
    
    var assistiveOptions = [AssistiveOption]()
    var reel: Reel? {
        didSet {
            assistiveOptions.removeAll()
            composeAssitiveOptions()
        }
    }
    
   
}
extension VideoAssitiveViewModel {
    private func composeAssitiveOptions() {
        assistiveOptions.append(.like(likes: reel?.likes ?? 0))
        assistiveOptions.append(.dislike)
        assistiveOptions.append(.comment(comments: reel?.comments ?? 0))
        assistiveOptions.append(.share)
        assistiveOptions.append(.remix)
        assistiveOptions.append(.profile(urlString: reel?.profileImageUrl ?? ""))
    }
}
  

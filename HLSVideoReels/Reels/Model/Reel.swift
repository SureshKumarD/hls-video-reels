//
//  Reel.swift
//  HLSVideoReels
//
//  Created by Suresh on 02/02/24.
//

import Foundation

struct Reel: Codable {
    var profileId, videoUrl, description, profileImageUrl: String?
    var isSubscribed: Bool?
    var likes, comments: Int?
    var isDislikable, isSharable, isMixable, shouldShowProfile: Bool?
}

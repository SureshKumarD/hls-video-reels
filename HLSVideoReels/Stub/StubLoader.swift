//
//  StubLoader.swift
//  HLSVideoReels
//
//  Created by Suresh on 02/02/24.
//

import Foundation

final class StubLoader {
    class func loadPlayList() -> [Reel]? {
        guard let path = Bundle.main.path(forResource: "playList", ofType: "json")
        else { return nil }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let result = try JSONDecoder().decode([Reel].self, from: data)
            return result
        } catch {
            return nil
        }
    }
}

//
//  File.swift
//  
//
//  Created by Gurpeet Singh on 13/12/21.
//
import UIKit

internal extension UIDevice {
    static var freeSpaceInBytes: Int64 {
        if #available(iOS 11.0, *) {
            if let space = try? URL(fileURLWithPath: NSHomeDirectory() as String).resourceValues(forKeys: [URLResourceKey.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage {
                return space
            } else {
                return 0
            }
        } else {
            if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
                let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value {
                return freeSpace
            } else {
                return 0
            }
        }
    }

    static var freeDiskSpaceInMB: Int64 {
        return UIDevice.freeSpaceInBytes / (1024 * 1024)
    }
}

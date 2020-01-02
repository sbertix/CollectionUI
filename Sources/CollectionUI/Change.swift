//
//  File.swift
//  
//
//  Created by Stefano Bertagno on 30/12/2019.
//

import Foundation

extension CollectionDifference.Change {
    /// Offset.
    var offset: Int {
        switch self {
        case .insert(let offset, _, _): return offset
        case .remove(let offset, _, _): return offset
        }
    }
}

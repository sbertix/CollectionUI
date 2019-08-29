//
//  File.swift
//  
//
//  Created by Stefano Bertagno on 29/08/2019.
//

import UIKit

/// A simple class holding reference to a given `UICollectionViewCellRepresentable`.
internal class UIContainerCollectionViewCell<Content>: UICollectionViewCell where Content: UICollectionViewCellRepresentable {
    /// The identifier.
    var id: Int = -1
}

//
//  UICollectionViewCellRepresentable.swift
//  CollectionUI
//
//  Created by Stefano Bertagno on 29/08/2019.
//  Copyright © 2019 Stefano Bertagno. All rights reserved.
//

import SwiftUI
import UIKit

/// A specific `UIView` for `UICollectionViewCell`s
public protocol UICollectionViewCellRepresentable: View {
    /// The actual content.
    associatedtype Item

    /// The associated size.
    static var size: NSCollectionLayoutSize { get }
    /// The item.
    var item: Item { get }

    /// Init with item.
    init(_ item: Item)
}

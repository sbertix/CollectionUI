//
//  CollectionView.swift
//  CollectionUI
//
//  Created by Stefano Bertagno on 29/08/2019.
//  Copyright © 2019 Stefano Bertagno. All rights reserved.
//

import SwiftUI
import UIKit

/// A wrapper for `UICollectionView`.
public struct CollectionView<Content>: UIViewControllerRepresentable where Content: UICollectionViewCellRepresentable {
    public typealias Coordinator = CollectionCoordinator<Content>

    /// A wrapper.
    struct Wrapper<Item>: Hashable {
        var item: Item
        var id: Int
        func hash(into hasher: inout Hasher) { hasher.combine(id) }
        static func == (lhs: Wrapper<Item>, rhs: Wrapper<Item>) -> Bool { lhs.id == rhs.id }
    }

    /// The actual data.
    private let data: [Wrapper<Content.Item>]
    /// Axis.
    private var axis: Axis
    /// Whether indicators should be shown or not.
    private var showsIndicators: Bool
    /// The content inset.
    private var contentInset: UIEdgeInsets
    /// The interitem spacing.
    private var interitemSpacing: CGFloat
    /// The line spacing.
    private var lineSpacing: CGFloat
    /// Update collection view.
    private var updateHandler: ((UICollectionView) -> Void)?

    // MARK: Lifecycle
    /// Init with data.
    public init<C, ID>(_ axis: Axis = .horizontal,
                       data: C,
                       id: KeyPath<C.Element, ID>,
                       contentInset: UIEdgeInsets = .zero,
                       interitemSpacing: CGFloat = 10,
                       lineSpacing: CGFloat = 10,
                       showsIndicators: Bool = false,
                       update: ((UICollectionView) -> Void)? = nil) where C: Collection, C.Element == Content.Item, ID: Hashable {
        self.axis = axis
        self.data = data.map { Wrapper(item: $0, id: $0[keyPath: id].hashValue) }
        self.contentInset = contentInset
        self.interitemSpacing = interitemSpacing
        self.lineSpacing = lineSpacing
        self.showsIndicators = showsIndicators
        self.updateHandler = update
    }
    public func makeCoordinator() -> Coordinator { Coordinator(self) }

    // MARK: Representable
    public func makeUIViewController(context: UIViewControllerRepresentableContext<CollectionView<Content>>) -> UICollectionViewController {
        /// the actual layout.
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = axis == .horizontal ? .horizontal : .vertical
        layout.itemSize = Content.size
        layout.minimumInteritemSpacing = interitemSpacing
        layout.minimumLineSpacing = lineSpacing
        // update collection.
        let controller = UICollectionViewController(collectionViewLayout: layout)
        controller.collectionView.preservesSuperviewLayoutMargins = true
        controller.collectionView.register(UIContainerCollectionViewCell<Content>.self, forCellWithReuseIdentifier: "cell")
        controller.collectionView.backgroundColor = .clear
        controller.collectionView.contentInset = contentInset
        controller.collectionView.dataSource = context.coordinator
        controller.collectionView.showsHorizontalScrollIndicator = showsIndicators && axis == .horizontal
        controller.collectionView.showsVerticalScrollIndicator = showsIndicators && axis == .vertical
        updateHandler?(controller.collectionView)
        return controller
    }
    public func updateUIViewController(_ uiViewController: UICollectionViewController,
                                       context: UIViewControllerRepresentableContext<CollectionView<Content>>) {
    }

    // MARK: Coordinator.
    public class CollectionCoordinator<Content>: NSObject, UICollectionViewDataSource where Content: UICollectionViewCellRepresentable {
        /// The parent.
        var parent: CollectionView<Content>

        // MARK: Lifecycle
        init(_ collectionViewController: CollectionView<Content>) {
            self.parent = collectionViewController
        }

        // MARK: Data source
        public func collectionView(_ collectionView: UICollectionView,
                                   numberOfItemsInSection section: Int) -> Int {
            parent.data.count
        }

        public func collectionView(_ collectionView: UICollectionView,
                                   cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: "cell",
                                     for: indexPath) as? UIContainerCollectionViewCell<Content> else {
                                        fatalError("`cell` is invalid.")
            }
            let wrapper = parent.data[indexPath.item]
            guard cell.id != wrapper.id else { return cell }
            // update cell.
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            let controller = UIHostingController(rootView: Content(wrapper.item))
            guard let container = controller.view else {
                fatalError("`container` is invalid.")
            }
            container.frame = CGRect(origin: .zero, size: Content.size)
            cell.contentView.addSubview(container)
            return cell
        }
    }
}

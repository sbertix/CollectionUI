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
public struct CollectionViewController<Content>: UIViewControllerRepresentable where Content: UICollectionViewCellRepresentable {
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
    /// The interitem spacing.
    private var interitemSpacing: NSCollectionLayoutSpacing

    // MARK: Lifecycle
    /// Init with data.
    public init<C, ID>(_ axis: Axis = .horizontal,
                       data: C,
                       id: KeyPath<C.Element, ID>,
                       spacing: NSCollectionLayoutSpacing = .fixed(10),
                       showsIndicators: Bool = false) where C: Collection, C.Element == Content.Item, ID: Hashable {
        self.axis = axis
        self.data = data.map { Wrapper(item: $0, id: $0[keyPath: id].hashValue) }
        self.interitemSpacing = spacing
        self.showsIndicators = showsIndicators
    }
    public func makeCoordinator() -> Coordinator { Coordinator(self) }

    // MARK: Representable
    public func makeUIViewController(context: UIViewControllerRepresentableContext<CollectionViewController<Content>>) -> UICollectionViewController {
        /// the actual layout.
        let itemLayout = NSCollectionLayoutItem(layoutSize: Content.size)
        let groupLayout = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                               heightDimension: .fractionalHeight(1)),
                                                             subitem: itemLayout,
                                                             count: data.count)
        groupLayout.interItemSpacing = interitemSpacing
        let sectionLayout = NSCollectionLayoutSection(group: groupLayout)
        let layout = UICollectionViewCompositionalLayout(section: sectionLayout)
        // update collection.
        let controller = UICollectionViewController(collectionViewLayout: layout)
        controller.collectionView.register(UIContainerCollectionViewCell<Content>.self, forCellWithReuseIdentifier: "cell")
        controller.collectionView.dataSource = context.coordinator
        return controller
    }
    public func updateUIViewController(_ uiViewController: UICollectionViewController,
                                       context: UIViewControllerRepresentableContext<CollectionViewController<Content>>) {
    }

    // MARK: Coordinator.
    public class CollectionCoordinator<Content>: NSObject, UICollectionViewDataSource where Content: UICollectionViewCellRepresentable {
        /// The parent.
        var parent: CollectionViewController<Content>

        // MARK: Lifecycle
        init(_ collectionViewController: CollectionViewController<Content>) {
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
            guard let container = UIHostingController(rootView: Content(wrapper.item)).view else {
                fatalError("`container` is invalid.")
            }
            cell.contentView.addSubview(container)
            container.leadingAnchor.constraint(equalTo: cell.leadingAnchor).isActive = true
            container.trailingAnchor.constraint(equalTo: cell.trailingAnchor).isActive = true
            container.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
            container.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
            return cell
        }
    }
}

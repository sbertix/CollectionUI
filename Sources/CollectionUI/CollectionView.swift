//
//  CollectionView.swift
//  
//
//  Created by Stefano Bertagno on 30/12/2019.
//

import SwiftUI
import UIKit

/// Layout representation of the `CollectionView`.
public struct CollectionViewLayout {
    /// The scrolliing direction. Defaults to `.horizontal`.
    public var axis: Axis = .horizontal
    /// Whether it should show scrolling indicators or not. Defaults to `true`.
    public var showsIndicators: Bool = true
    /// The content inset. Defaults to `.zero`.
    public var contentInset: UIEdgeInsets = .zero
    /// The interitem spacing. Defaults to `10`.
    public var interitemSpacing: CGFloat = 10
    /// The line spacing. Defaults to `10`.
    public var lineSpacing: CGFloat = 10
    /// The item size. Defaults to `.init(width: 100, height: 100)`.
    public var itemSize: CGSize = .init(width: 100, height: 100)
    /// Bounces.
    public var alwaysBounces: Bool = false
}

/// A basic `UICollectionView` wrapper.
public struct CollectionView<Content: View>: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UICollectionViewController
    public typealias Coordinator = CollectionCoordinator<Content>
    
    /// The actual ids.
    var identifiers: [Int]
    /// The actual content.
    var content: [Content]
    
    /// The layout info.
    var layout: CollectionViewLayout = .init()
    
    // MARK: Lifecycle
    /// Init with `data`.
    public init<C, ID>(_ data: C, id: KeyPath<C.Element, ID>, @ViewBuilder content: (C.Element) -> Content) where C: RandomAccessCollection, ID: Hashable {
        self.identifiers = data.map { $0[keyPath: id].hashValue }
        self.content = data.map(content)
    }
    /// Init with hashable `data`.
    public init<C>(_ data: C, @ViewBuilder content: (C.Element) -> Content) where C: RandomAccessCollection, C.Element: Hashable {
        self.identifiers = data.map { $0.hashValue }
        self.content = data.map(content)
    }
    /// Init with identifiable data.
    public init<C>(_ data: C, @ViewBuilder content: (C.Element) -> Content) where C: RandomAccessCollection, C.Element: Identifiable {
        self.identifiers = data.map { $0.id.hashValue }
        self.content = data.map(content)
    }
    
    // MARK: Accessory
    /// Update layout.
    public func layout(_ transform: (inout CollectionViewLayout) -> Void) -> Self {
        var copy = self
        transform(&copy.layout)
        return copy
    }
    /// Update `layout.axis`.
    public func axis(_ axis: Axis) -> Self { layout { $0.axis = axis }}
    /// Update `layout.showsIndicators`.
    public func indicators(_ showsIndicators: Bool) -> Self { layout { $0.showsIndicators = showsIndicators }}
    /// Update `layout.contentInset`.
    public func inset(_ contentInset: UIEdgeInsets) -> Self { layout { $0.contentInset = contentInset }}
    /// Update `layout.interitemSpacing`.
    public func interitemSpace(_ interitemSpacing: CGFloat = 10) -> Self { layout { $0.interitemSpacing = interitemSpacing }}
    /// Update `layout.lineSpacing`.
    public func lineSpace(_ lineSpacing: CGFloat = 10) -> Self { layout { $0.lineSpacing = lineSpacing }}
    /// Update `layout.itemSize`.
    public func item(size: CGSize) -> Self { layout { $0.itemSize = size }}
    /// Update `layout.itemSize`.
    public func item(width: CGFloat, height: CGFloat) -> Self { layout { $0.itemSize = .init(width: width, height: height) }}
    /// Update `layout.alwaysBounces`.
    public func bounce(_ alwaysBounces: Bool) -> Self { layout { $0.alwaysBounces = alwaysBounces }}
    
    // MARK: UIViewControllerRepresentable
    public func makeUIViewController(context: UIViewControllerRepresentableContext<CollectionView<Content>>) -> UICollectionViewController {
        // update layout.
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = self.layout.axis == .horizontal ? .horizontal : .vertical
        layout.itemSize = self.layout.itemSize
        layout.minimumLineSpacing = self.layout.lineSpacing
        layout.minimumInteritemSpacing = self.layout.interitemSpacing
        // update collection.
        let controller = UICollectionViewController(collectionViewLayout: layout)
        controller.collectionView.alwaysBounceHorizontal = self.layout.alwaysBounces && self.layout.axis == .horizontal
        controller.collectionView.alwaysBounceVertical = self.layout.alwaysBounces && self.layout.axis == .vertical
        controller.collectionView.preservesSuperviewLayoutMargins = true
        controller.collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        controller.collectionView.backgroundColor = .clear
        controller.collectionView.contentInset = self.layout.contentInset
        controller.collectionView.dataSource = context.coordinator
        controller.collectionView.showsHorizontalScrollIndicator = self.layout.showsIndicators && self.layout.axis == .horizontal
        controller.collectionView.showsVerticalScrollIndicator = self.layout.showsIndicators && self.layout.axis == .vertical
        return controller
    }
    public func updateUIViewController(_ uiViewController: UICollectionViewController,
                                       context: UIViewControllerRepresentableContext<CollectionView<Content>>) {
        // obtain differences.
        let differences = identifiers.difference(from: context.coordinator.zipped.map { $0.0 })
        context.coordinator.zipped = Array(zip(identifiers, content))
        uiViewController.collectionView.performBatchUpdates({
            uiViewController.collectionView.deleteItems(at: differences.removals.map { IndexPath(item: $0.offset, section: 0) })
            uiViewController.collectionView.insertItems(at: differences.insertions.map { IndexPath(item: $0.offset, section: 0) })
        }, completion: nil)
    }

    // MARK: Coordinator
    public func makeCoordinator() -> CollectionCoordinator<Content> {
        .init(collectionView: self)
    }
    
    /// The `BasicCollectionView` coordinator.
    public class CollectionCoordinator<Content: View>: NSObject, UICollectionViewDataSource {
        /// The actual data.
        var zipped: [(Int, Content)]
        
        // MARK: Lifecycle
        /// Init.
        init(collectionView: CollectionView<Content>) {
            self.zipped = Array(zip(collectionView.identifiers, collectionView.content))
        }
        
        // MARK: Collection
        public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { zipped.count }
        public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CollectionViewCell else {
                fatalError("Invalid collection view cell.")
            }
            // update cell.
            let value = zipped[indexPath.item]
            guard cell.identifier != value.0 else { return cell }
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            let controller = UIHostingController(rootView: value.1)
            guard let container = controller.view else {
                fatalError("Invalid container view for cell.")
            }
            // update container.
            container.backgroundColor = .clear
            container.frame = .zero
            container.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(container)
            // add constraints.
            NSLayoutConstraint.activate([
                container.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                container.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                container.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                container.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor)
            ])
            cell.identifier = value.0
            return cell
        }
    }
}

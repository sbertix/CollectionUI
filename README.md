# CollectionUI <WIP>
![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/sbertix/CollectionUI)
[![GitHub](https://img.shields.io/github/license/sbertix/CollectionUI)](https://github.com/sbertix/CollectionUI/blob/master/LICENSE)
<img src="https://img.shields.io/badge/supports-Swift%20Package%20Manager-ff69b4.svg">  

**CollectionUI** is a simple **SwiftUI** _wrapper_ for `UICollectionView`.

## Installation
### Swift Package Manager (Xcode 11 and above)
1. Select `File`/`Swift Packages`/`Add Package Dependency…` from the menu.
1. Paste `https://github.com/sbertix/CollectionUI.git`.
1. Follow the steps.

## Usage
```swift
import SwiftUI
import CollectionUI

/// A `StringView` conforming to `UICollectionViewCellRepresentable`.
struct StringView : UICollectionViewCellRepresentable {
    /// The cell size.
    static var size: CGSize = .init(width: 100, height: 100)
    /// The item.
    var item: String
    
    /// Init.
    init(_ item: String) { self.item = item }
    /// The actual body.
    var body: some View { Text(item) }
}

/// A `View`.
struct ContentView : View {
    var body: some View {
        CollectionView<StringView>(.horizontal, // optional.
                                   data: ["A", "B", "C", "D"],
                                   id: \.hashValue,
                                   contentInset: .init(top: 0, left: 15, bottom: 0, right: 15), // optional.
                                   interitemSpacing: 10, // optional.
                                   lineSpacing: 10, // optional.
                                   showsIndicator: false // optional)
             .frame(height: 300)
    }
}
```

Coming soon.

## License
**CollectionUI** is licensed under the MIT license.  
Check out [LICENSE](https://github.com/sbertix/NukeImage/blob/master/LICENSE) for more info.

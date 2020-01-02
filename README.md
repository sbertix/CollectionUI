# CollectionUI <WIP>
![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/sbertix/CollectionUI)
[![GitHub](https://img.shields.io/github/license/sbertix/CollectionUI)](https://github.com/sbertix/CollectionUI/blob/master/LICENSE)
<img src="https://img.shields.io/badge/supports-Swift%20Package%20Manager-ff69b4.svg">  

**CollectionUI** is a simple **SwiftUI** _wrapper_ for (simple) `UICollectionView`s.

## Installation
### Swift Package Manager (Xcode 11 and above)
1. Select `File`/`Swift Packages`/`Add Package Dependency…` from the menu.
1. Paste `https://github.com/sbertix/CollectionUI.git`.
1. Follow the steps.

## Usage
```swift
import SwiftUI
import CollectionUI

/// A `View`.
struct ContentView : View {
    @State var content = ["A", "B", "C"]

    var body: some View {
        CollectionView($content, id: \.hashValue) { Text($0) }
            .axis(.horizontal)
            .indicators(false)
            .groupSize(.init(widthDimension: .fractionalWidth(0.5),
                             heightDimension: .fractionalHeight(1)))
            .itemSize(.init(widthDimension: .fractionalWidth(1),
                            heightDimension: .fractionalHeight(1)))
            .frame(minHeight: 80)
            .padding()
    }
}
```

## License
**CollectionUI** is licensed under the MIT license.  
Check out [LICENSE](https://github.com/sbertix/CollectionUI/blob/master/LICENSE) for more info.

# ArtExplorer

ArtExplorer is an iOS app that allows users to explore and discover artworks from the Harvard Art Museums' collection. The app provides an intuitive interface for browsing artworks, viewing detailed information, and exploring the geographical context of each piece.

## Features

- Browse a diverse collection of artworks from the Harvard Art Museums
- View high-quality images of artworks
- Read detailed information about each artwork, including title, artist, culture, and more
- Explore the geographical origin of artworks on an interactive map
- Filter artworks by culture, century, and classification
- Responsive design that works on various iOS devices

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+
- An active internet connection
- Harvard Art Museums API key

## Installation

To run ArtExplorer on your local machine, follow these steps:

1. Ensure you have the latest version of Xcode installed on your Mac.

2. Clone this repository to your local machine:
   ```
   git clone https://github.com/yourusername/ArtExplorer.git
   ```

3. Navigate to the project directory:
   ```
   cd ArtExplorer
   ```

4. Open the project in Xcode:
   ```
   open ArtExplorer.xcodeproj
   ```

5. In Xcode, navigate to the project settings and select your development team for code signing.

## Configuration

This project uses a configuration file to store sensitive information like API keys. Follow these steps to set it up:

1. Locate the `ConfigTemplate.swift` file in the project.
2. Make a copy of `ConfigTemplate.swift` and name it `Config.swift`.
3. Open `Config.swift` and uncomment the struct declaration.
4. Replace `"YOUR_API_KEY_HERE"` with your actual Harvard Art Museums API key.
5. Never commit your `Config.swift` file to the repository.

Example of how your `Config.swift` should look after modification:

```swift
struct Config {
    static let apiKey = "your_actual_api_key_here"
}
```

Note: `Config.swift` is listed in `.gitignore` to prevent accidental commits of your API key.

## Usage

1. After setting up the configuration file with your API key, build and run the project in Xcode by clicking the "Play" button or pressing `Cmd + R`.
2. Upon launching the app, you'll see a grid of artwork images.
3. Tap on any artwork to view more details, including a larger image, artist information, and geographical data.
4. Use the "Filter" button in the top right corner to refine your artwork search by culture, century, or classification.
5. In the artwork detail view, scroll down to see a map showing the origin of the artwork (if geographical data is available).

## Contributing

Contributions to ArtExplorer are welcome! If you have a bug fix or new feature you'd like to add, please follow these steps:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

Please ensure you do not commit your `Config.swift` file with your personal API key.

## Acknowledgments

- Harvard Art Museums for providing the API and access to their extensive art collection.
- [SwiftUI](https://developer.apple.com/xcode/swiftui/) for the reactive UI framework.
- [Combine](https://developer.apple.com/documentation/combine) for the functional reactive programming paradigm.

## Contact

Allen Odoom - aodoom04@gmail.com

Project Link: [https://github.com/yourusername/ArtExplorer](https://github.com/allenocvb/ArtExplorer)

## License

This project is not licensed for public use, modification, or distribution. All rights reserved.

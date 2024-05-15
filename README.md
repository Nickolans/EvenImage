# Even Image
A Swift-based command-line tool that transforms initially non-uniform images into uniformly-sized ones through the application of spacing, centering, and scaling. This project utilizes the Core Graphics framework for image rendering and manipulation.

> [!NOTE]
> This project is currently in the works, and updates are ongoing.

## Usage

The following will generate an image of size 2000x1000 that will act as the container for the image `t1.png`. The generated image is saved in the `test-results` directory.

```sh
swift run EvenImage ./t1.png test-results/ --height 1000 --width 2000
```

## Examples
The following are three generated images. The input images are placed on a gray background. The input image scales to fit the given size (in this case, 2000x1000). 

Since Image 1 is wide, it will scale to fit the width of the 2000x1000 container while leaving space on the top and bottom. Since Image 2 is tall, it will scale to fit the height of the 2000x1000 container while leaving space to the left and right.

### Image 1
![4F7FA752-0608-4FB8-AA81-193B3BD3CBA9](https://github.com/Nickolans/EvenImage/assets/23033783/bdf34452-2d56-4872-a841-a441993bfb1c)

### Image 2
![9B5822B4-B71C-49E1-A4DD-C597369CB905](https://github.com/Nickolans/EvenImage/assets/23033783/8529877a-4fec-477b-b156-cd283cbcb2b9)

### Image 3
![B6785884-50BA-43AC-AE6F-C300AA70E93A](https://github.com/Nickolans/EvenImage/assets/23033783/7606a9c7-ee6f-42f1-a916-ad0141b58af2)

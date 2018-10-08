# Not Nikola

An image classifier in the style of Not Hotdog from the Silicon Valley TV show. Built with Core ML and trained with Create ML.

<div align = "center">
<img src="https://d3ansictanv2wj.cloudfront.net/Figure_1-71076f8ac360d6a065cf19c6923310d2.jpg" width="400" />
<img src="Not Nikola/Assets/Example.jpg" width="400" />
</div>

## Training
The classifier model was trained with images of [Nikola Brežnjak](http://www.nikola-breznjak.com/blog/) from the [TelTech](http://www.teltech.co) Bahamas cruise. Training for a new model can be setup with Create ML and Swift Playgrounds in a few lines of code.

```swift
import CreateMLUI

let builder = MLImageClassifierBuilder()
builder.showInLiveView()
```
<div align = "center">
<img src="Not Nikola/Assets/Playground.png" width="600" />
</div>
Labeled folders of images can then be dragged into the playground to train and test the classifier.

## Usage
A Core ML image analysis request will return classification results based on image input. As a result of the Nikola model being trained with a relatively low number of images, this example app only identifies an image as Nikola if it has the highest possible confidence value. 
```swift
let model = try VNCoreMLModel(for: NikolaClassifier().model)

let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
    DispatchQueue.main.async {
        if let results = request.results {
            let classifications = results as! [VNClassificationObservation]
            self?.classificationView.isHidden = false
            
            if classifications.isEmpty {
                self?.classificationLabel.text = "Nothing there"
            } else {
                let classification = classifications.first
                if classification?.identifier == "Nikola" && CGFloat(classification!.confidence) == 1.0 {
                    self?.classificationLabel.text = "Nikola"
                } else {
                    self?.classificationLabel.text = "Not Nikola"
                }
            }
        }
    }
})
```

A more detailed tutorial on training with Create ML can be found at https://www.raywenderlich.com/5653-create-ml-tutorial-getting-started.

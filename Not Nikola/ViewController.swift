//
//  ViewController.swift
//  Not Nikola
//
//  Created by Paul Dippold on 10/5/18.
//  Copyright © 2018 Paul Dippold. All rights reserved.
//

import UIKit
import CoreML
import Vision
import ImageIO

class ViewController: UIViewController {
    @IBOutlet weak var classificationView: UIView!
    @IBOutlet weak var classificationLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectImageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        classificationView.isHidden = true
        classificationView.layer.cornerRadius = 8
    }
    
    @IBAction func choosePicture() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        
        let photoSourcePicker = UIAlertController()
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .camera)
        }
        let choosePhoto = UIAlertAction(title: "Choose Photo", style: .default) { [unowned self] _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        
        photoSourcePicker.addAction(takePhoto)
        photoSourcePicker.addAction(choosePhoto)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(photoSourcePicker, animated: true)
    }

    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
    
    func classify(image: UIImage) {
        self.classificationLabel.text = ""
        self.classificationView.isHidden = true
        if let ciImage = CIImage(image: image) {
            DispatchQueue.global(qos: .userInitiated).async {
                let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
                do {
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
                    
                    try handler.perform([request])
                } catch {
                    print("Failed: \(error.localizedDescription)")
                }
            }
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.image = image
        classify(image: image)
    }
}

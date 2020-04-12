//
//  ViewController.swift
//  WhatFlower
//
//  Created by Faisal Babkoor on 3/31/20.
//  Copyright © 2020 Faisal Babkoor. All rights reserved.
//

import UIKit
import CoreML
import Vision
import SDWebImage

typealias ImagePickerMethods = UIImagePickerControllerDelegate & UINavigationControllerDelegate

class ViewController: UIViewController, ImagePickerMethods {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var textView: UITextView!

    
    let imagePickerController = UIImagePickerController()

    
    override func viewDidLoad() {
        super.viewDidLoad()
       setupImagePickerView()
    }

    func setupImagePickerView() {
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userSelecteImage = info[.originalImage] as? UIImage {
            imageView.image = userSelecteImage
            /// convert UIImage to CIImage
          guard let ciimage = CIImage(image: userSelecteImage) else { return }
            detecte(flowerImage: ciimage)
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePickerController, animated: true)
    }
    
    
    func detecte(flowerImage: CIImage) {
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else { fatalError("Can't convert model") }
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else { fatalError() }
            if let firstResult = results.first {
                self.navigationItem.title = firstResult.identifier.capitalized
                NetworkManager.shared.getInfo(flowerName: firstResult.identifier) { result in
                    switch result {
                    case .success(let flower):
                        self.textView.text = flower.flowerDescription
                        self.imageView.sd_setImage(with: flower.image, placeholderImage: UIImage(ciImage: flowerImage)) { image, error,  cache, url in
                            
                            
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
        let handler = VNImageRequestHandler(ciImage: flowerImage)
        do {
            try handler.perform([request])
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
}


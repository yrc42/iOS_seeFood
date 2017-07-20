//
//  ViewController.swift
//  SeeFood
//
//  Created by CIBC_Coop2 on 2017-06-11.
//  Copyright © 2017 CIBC_Coop2. All rights reserved.
//

import UIKit
import VisualRecognitionV3
import SVProgressHUD
import Social

class ViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let apiKey = "922fbcf32fadca1fa75da284a6c2a1f6b8b845a3"
    let version = "2017-06-11"
    
    @IBOutlet weak var topBarImageView: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    let imagePicker = UIImagePickerController()
    var classificationResults : [String] = []
    
    @IBOutlet weak var shareButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imagePicker.delegate = self
        shareButton.isHidden = true
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        cameraButton.isEnabled = false
        SVProgressHUD.show()
      
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            
            imageView.image = image
            dismiss(animated: true, completion: nil)
            
            let visualRecognition = VisualRecognition(apiKey: apiKey, version: version)
            let imageData = UIImageJPEGRepresentation(image,0.01)
            
            //find the directory
            let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            //choose file url
            let fileURL = documentURL.appendingPathComponent("tempImage.jpg")
            
            //write the image to imageurl
            try? imageData?.write(to: fileURL, options:  [])
            
            
            visualRecognition.classify(imageFile: fileURL, success: { (classifiedImages) in
                
               let classes = classifiedImages.images.first!.classifiers.first!.classes
                
                
                for index in 0..<classes.count{
                    self.classificationResults.append(classes[index].classification)
                    
                }
             //   print(self.classificationResults)
                DispatchQueue.main.async {
                    self.cameraButton.isEnabled = true
                    SVProgressHUD.dismiss()
                    self.shareButton.isHidden = false
                    
                }
                
                if self.classificationResults.contains("hotdog") {
                    DispatchQueue.main.async{
                        self.navigationItem.title = "HOTDOG"
                        self.navigationController?.navigationBar.barTintColor = UIColor.green
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.topBarImageView.image = UIImage(named: "hotdog")
                    }
                }else{
                    DispatchQueue.main.async {
                        self.navigationItem.title = "NOT HOTDOG"
                        self.navigationController?.navigationBar.barTintColor = UIColor.red
                        self.navigationController?.navigationBar.isTranslucent = false
                        self.topBarImageView.image = UIImage(named: "not-hotdog")

                    }
                }
 
         //       print(classifiedImages)
            })
            
        } else{
            print("error")
        }
        
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
        
    }

    @IBAction func shareTapped(_ sender: UIButton) {
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter){
            let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            vc?.setInitialText(navigationItem.title)
            vc?.add(#imageLiteral(resourceName: "hotdogBackground"))
            present(vc!, animated: true, completion: nil)
            
        }else{
            self.navigationItem.title = "please log in to twitter"
        }
        
    }
}


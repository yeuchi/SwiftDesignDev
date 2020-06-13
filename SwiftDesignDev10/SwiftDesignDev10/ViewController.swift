//
//  ViewController.swift
//  SwiftDesignDev10
//
//  Created by yeuchi on 6/12/20.
//  Copyright © 2020 yeuchi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {

    var image:UIImage?=nil
    var myRGBA:RGBAImage? = nil
    var params:FilterParams = FilterParams()
    var state:ViewState = ViewState.Source

    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.delegate = self
        self.scrollView.contentSize = imageView.frame.size
        
        self.tapRecognizer.numberOfTapsRequired = 2
        /*
         image = UIImage(named: "landscape")
         imageView.image = image
         
         let size = image?.size
         scrollView.contentSize = size!
         */
        
        self.scrollView.minimumZoomScale = 0.3
        self.scrollView.maximumZoomScale = 5
    }

    @IBAction func onNew(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            self.showCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Album", style: .default, handler: { action in
            self.showAlbum()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func onFilter(_ sender: UIButton) {
        /*if (sender.selected) {
         hideSecondaryMenu()
         sender.selected = false
         } else {
         showSecondaryMenu()
         sender.selected = true
         }*/
    }
    
    @IBAction func onCompare(_ sender: UIButton) {
    }
    
    @IBAction func onShare(_ sender: UIButton) {
        /*
         let activityController = UIActivityViewController(activityItems: ["Check out our really cool app", imageView.image!], applicationActivities: nil)
         presentViewController(activityController, animated: true, completion: nil)
         */
    }
    
    func showCamera() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .camera
        present(picker, animated: true)
    }
    
    func showAlbum() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        self.image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.image = self.image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        print("scrollViewDidZoom:")
        print(scrollView.zoomScale)
    }
    
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        //self.scrollView.zoomScale = 1.5 * self.scrollView.zoomScale
        self.scrollView.setZoomScale(1.5 * self.scrollView.zoomScale, animated: true)
    }
}

extension ViewController {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}


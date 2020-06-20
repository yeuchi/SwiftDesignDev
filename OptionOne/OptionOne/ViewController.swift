//
//  ViewController.swift
//  OptionOne
//
//  Created by yeuchi on 6/20/20.
//  Copyright © 2020 yeuchi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, TableDelegateProtocol, FeedDelegateProtocol, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {

    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnCompare: UIButton!
    
    var image:UIImage?=nil
    var myRGBA:RGBAImage? = nil
    var params:FilterParams = FilterParams()
    var state:ViewState = ViewState.Source
    var urlSession: URLSession!
    
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnShare.isEnabled = false
        btnCompare.isEnabled = false
        
        let configuration = URLSessionConfiguration.default
        self.urlSession = URLSession(configuration: configuration)
        
        self.scrollView.delegate = self
        self.scrollView.contentSize = imageView.frame.size
        self.image = self.imageView.image
        
        self.tapRecognizer.numberOfTapsRequired = 2
        self.scrollView.minimumZoomScale = 0.3
        self.scrollView.maximumZoomScale = 5
    }
    
    @IBAction func onNew(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "imageFeed") as! ImageFeedTableViewController
        vc.delegate = self
        
        self.present(vc, animated: true, completion: nil)
    }
    
    /*
     * Delegate - image selected
     */
    func onSelectedImage(imageUrl: URL) {
        
        let data = try? Data(contentsOf: imageUrl)
        self.image = UIImage(data: data!)
        self.imageView.image = self.image
  
    }
    
    @IBAction func onFilter(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "idTableViewController") as! FilterTableViewController
        vc.delegate = self
        
        self.present(vc, animated: true, completion: nil)
       // btnCompare.isEnabled = true
    }
    
    /*
     * Delegate Method
     * - execute convolution filter
     */
    func onSelectedFilter(filterType: KernelType) {
       // self.txtSelectedFilter.text = filterType.rawValue
        self.params.kernel = filterType
        applyFilter()
    }
    
    @IBAction func onCompare(_ sender: UIButton) {
        // not required for this assignment
    }
    
    @IBAction func onShare(_ sender: UIButton) {
        // not required for this assignment
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        print("scrollViewDidZoom:")
        print(scrollView.zoomScale)
    }
    
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
   
        //self.scrollView.zoomScale = 1.5 * self.scrollView.zoomScale
        self.scrollView.setZoomScale(1.5 * self.scrollView.zoomScale, animated: true)
    }
    
    func applyFilter() {
        runInstaFilter(params: self.params)
    }
    
    func runInstaFilter(params:FilterParams) {
        
        self.myRGBA = RGBAImage(image:self.image!)!
        let filter = params.getKernelValues()
        
        // Denominator: find kernel sum
        var denominator = 0
        for cy in 0..<3 {
            for cx in 0..<3 {
                denominator += filter[cx][cy]
            }
        }
        if(denominator == 0) {
            denominator = 1
        }
        else if (denominator < 0) {
            denominator *= -1
        }
        
        /*
         * Rubric:
         * Does the playground code apply a filter to each pixel of the image? Maximum of 2 pts
         */
        for y in 0..<self.myRGBA!.height {
            for x in 0..<self.myRGBA!.width {
                var sumRed = 0
                var sumGreen = 0
                var sumBlue = 0
                
                // integrate, convolve with kernel (index -1 -> 1)
                for cy in 0..<3 {
                    for cx in 0..<3 {
                        
                        // constraint pixel index -> in bound
                        var yy = y + cy - 1
                        if(yy < 0){
                            yy = 0
                        }
                        else if (yy >= self.myRGBA!.height) {
                            yy = self.myRGBA!.height-1
                        }
                        
                        var xx = x + cx - 1
                        if(xx < 0){
                            xx = 0
                        }
                        else if (xx >= self.myRGBA!.width) {
                            xx = self.myRGBA!.width-1
                        }
                        
                        // do integration
                        let i = yy * self.myRGBA!.width + xx
                        let pix = self.myRGBA!.pixels[i]
                        sumRed += Int(pix.red) * filter[cx][cy]
                        sumGreen += Int(pix.green) * filter[cx][cy]
                        sumBlue += Int(pix.blue) * filter[cx][cy]
                    }
                }
                let ii = y * self.myRGBA!.width + x
                self.myRGBA!.pixels[ii].red = UInt8(max(0, min(255, sumRed/denominator)))
                self.myRGBA!.pixels[ii].green = UInt8(max(0, min(255, sumGreen/denominator)))
                self.myRGBA!.pixels[ii].blue = UInt8(max(0, min(255, sumBlue/denominator)))
            }
        }
        self.imageView.image = self.myRGBA!.toUIImage()
    }
}

extension ViewController {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}



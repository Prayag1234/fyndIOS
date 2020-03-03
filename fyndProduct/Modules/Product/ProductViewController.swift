
import UIKit

class ProductViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imgProduct: UIImageView!
    var product: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let productName = product?.name, let cost = product?.cost {
            self.title = "\(String(describing: productName)) - \(String(describing: cost))"
        }
        setupScrollView()
        downloadImage()
    }
    
    func setupScrollView(){
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        scrollView.bounces = false
    }
    
    func downloadImage() {
        let newSession = URLSession.shared
        self.displayActivityIndicator(shouldDisplay: true)
        guard let url = product?.imageURL else { return }
        let downloadTask = newSession.downloadTask(with: url) { (location, response, error) in
            self.displayActivityIndicator(shouldDisplay: false)
            if let locationUrl = location, let data = try? Data(contentsOf: locationUrl){
                let image = UIImage(data: data)
                DispatchQueue.main.async { self.imgProduct.image = image }
            }
        }
        downloadTask.resume()
    }


}

extension ProductViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgProduct
    }
}

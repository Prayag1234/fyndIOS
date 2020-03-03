
import UIKit

class ProductListViewController: UIViewController {
    
    var productList = [ProductsList]()
    @IBOutlet weak var tblProductList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Products"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "sort", style: .plain, target: self, action: #selector(sorting))
        setupTableView()
        setupData()
    }
    
    func setupTableView() {
        tblProductList.dataSource = self
        tblProductList.delegate = self
        tblProductList.register(UINib(nibName: "CollectionTableViewCell", bundle: nil), forCellReuseIdentifier: "CollectionTableViewCell")
    }
    
    func setupData() {
        fetchDataFromLink { (productList) in
            self.productList = self.prepareData(productList: productList)
            DispatchQueue.main.async {
                self.tblProductList.reloadData()
            }
            
        }
    }
    
    func prepareData(productList: [ProductsList]) -> [ProductsList] {
        productList.filter { $0.products?.count ?? 0 > 0}
    }
    
    @objc func sorting() {
        var sortedProductList = [ProductsList]()
        for categoryProductList in productList {
            sortedProductList.append(ProductsList(products: categoryProductList.products?.sorted(by: { $0.cost < $1.cost }), name: categoryProductList.name))
        }
        productList = sortedProductList
        self.tblProductList.reloadData()
    }
    
    func cellForItem(at indexPath: IndexPath, tag: Int) -> CollectionViewCell? {
        for i in self.tblProductList.visibleCells as! [CollectionTableViewCell]{
            if(tag == i.productCollectionView.tag){
                return i.productCollectionView.cellForItem(at: indexPath) as? CollectionViewCell
            }
        }
        return nil
    }
    
    func fetchDataFromLink(completionHandler: @escaping ([ProductsList]) -> Void) {
        let url = URL(string: "https://demo4308233.mockable.io/all")!
        self.displayActivityIndicator(shouldDisplay: true)
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            
            self.displayActivityIndicator(shouldDisplay: false)
            if let error = error {
                print("Error with fetching films: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    print("Error with the response, unexpected status code: \(String(describing: response))")
                    return
            }
            
            if let data = data,
                let productList = try? JSONDecoder().decode([ProductsList].self, from: data) {
                completionHandler(productList)
            }
            
        })
        task.resume()
    }
    
}

extension ProductListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        productList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let collectionTableCell = tableView.dequeueReusableCell(withIdentifier: "CollectionTableViewCell", for: indexPath) as! CollectionTableViewCell
        collectionTableCell.lblCategoryName.text = productList[indexPath.row].name
        collectionTableCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
        return collectionTableCell
    }
    
}

extension ProductListViewController: UITableViewDelegate {
    
}

extension ProductListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        productList[collectionView.tag].products?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.lblName.text = productList[collectionView.tag].products?[indexPath.row].name
        cell.lblCost.text = String((productList[collectionView.tag].products?[indexPath.row].cost)!)
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8
        print(indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = productList[collectionView.tag].products?[indexPath.row]
        ImageDownloadManager.shared.downloadImage(photo!, indexPath: indexPath, collectionTag: collectionView.tag) { (image, url, indexPathh, collectionTag, error) in
            
            if let indexPathNew = indexPathh {
                DispatchQueue.main.async {
                    if let getCell = self.cellForItem(at: indexPathNew, tag: collectionTag){
                        getCell.imgProduct.image = image
                    }
                }
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        /* Reduce the priority of the network operation in case the user scrolls and an image is no longer visible. */
        let photo = productList[collectionView.tag].products?[indexPath.row]
        ImageDownloadManager.shared.slowDownImageDownloadTaskfor(photo!)
    }
    
    
}

extension ProductListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(" at \(collectionView.tag) clicked \(indexPath)")
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let productViewController = storyBoard.instantiateViewController(withIdentifier: "ProductViewController") as! ProductViewController
        productViewController.product = self.productList[collectionView.tag].products?[indexPath.row]
        self.navigationController?.pushViewController(productViewController, animated: true)
        
    }
}

extension ProductListViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: (collectionView.frame.size.width-30)/3, height: (collectionView.frame.size.height-20)/2)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
}

extension ProductListViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = self.productList[collectionView.tag].products?[indexPath.row]
        let itemProvider = NSItemProvider(object: item?.name as! NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
}

extension ProductListViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        // need to handle drop event and check if its reorder or add new element in product list
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
}

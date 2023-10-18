//
//  DetailsViewController.swift
//  ShoppingNot
//
//  Created by Mert Baykal on 17/09/2023.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var saveButtton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var sizeTextfield: UITextField!
    
    
    var selectedProductName = " "
    var selectedProductUUID : UUID?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedProductName != " "{
            
              saveButtton.isHidden = true // buttonu gorunmez yapiyor
           // saveButtton.isEnabled = false // buttonu tiklanmaz hale getiriyor
            
            // core data secilen urun bilgilerini goste
            if let uuidString = selectedProductUUID?.uuidString{
                
                let appdelegate = UIApplication.shared.delegate as! AppDelegate
                let contex = appdelegate.persistentContainer.viewContext
                
                var fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)// burada neyi filitrelayecegini soruyo  ve id = %@ idini esit olanlari getir anlamina geliyor
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    let resualt = try contex.fetch(fetchRequest)
                    
                    if resualt.count != 0 {
                        for result in resualt as! [NSManagedObject] {
                            if let name = result.value(forKey: "name") as? String{
                                nameTextfield.text = name
                            }
                            if let price = result.value(forKey: "price") as? Int{
                                priceTextField.text = String(price)
                            }
                            if let size = result.value(forKey: "size") as? String{
                                sizeTextfield.text = size
                            }
                            if let imageData = result.value(forKey: "image") as? Data{
                                let image = UIImage(data: imageData)//image cevirme
                                imageView.image = image
                            }
                            
                        }
                    }
                }catch{
                    print("hata olustu")
                }
            }
            
        }else {
            saveButtton.isHidden = false
            saveButtton.isEnabled = false
            nameTextfield.text = " "
            sizeTextfield.text = " "
            priceTextField.text = " "
        }
        
    // her hangi gibi biryere tiklanma
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(takeOffkeyboard))
        view.addGestureRecognizer(gestureRecognizer)// bu sayede gorunume tiklanildigini algilama
        
        //image tiklandiginda fortograf secme algilayaci
        imageView.isUserInteractionEnabled = true
        let imageGestrueRecognizer = UITapGestureRecognizer(target: self, action: #selector(choseFoto))
        imageView.addGestureRecognizer(imageGestrueRecognizer)
    }
    
    @objc func choseFoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true //fotograf secildikten sonra kesilmeye ve ayarlanmaya izin verme
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.originalImage] as? UIImage
        saveButtton.isEnabled = true
        self.dismiss(animated: true)
    }
    
    @objc func takeOffkeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let appDelegette = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegette.persistentContainer.viewContext
        
        let shopping = NSEntityDescription.insertNewObject(forEntityName: "Shopping", into: context) // bununla beraber entitileri ulasim veri acktarimi yapila bilecek
        
        shopping.setValue(nameTextfield.text!, forKey: "name")
        shopping.setValue(sizeTextfield.text!, forKey: "size")

        if let price = Int(priceTextField.text!){
            shopping.setValue(price, forKey: "price")
        }
        
        // universal unique id
        shopping.setValue(UUID(), forKey: "id")
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5) // image veriye cevirme
        shopping.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("kayit edildi")
        }catch{
            print("hata var")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dataEntered"), object: nil)
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
   

}

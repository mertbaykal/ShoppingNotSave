//
//  ViewController.swift
//  ShoppingNot
//
//  Created by Mert Baykal on 17/09/2023.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var namesArray = [String]()
    var idArray = [UUID]()
    
    var selectedName = " "
    var selectedUUID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.dataSource = self
        tableView.delegate = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target:self, action: #selector(addButtonClicked))
        
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "dataEntered"), object: nil)
    }
    
    @objc func getData() {
        
        namesArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
        
        fetchRequest.returnsObjectsAsFaults = true
        
        do {// id cekme
             let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String {
                        namesArray.append(name)
                    }
                    if let id = result.value(forKey: "id")
                        as? UUID {
                        idArray.append(id)
                    }
                }
                tableView.reloadData() // hadi ben datalari gunceledim sen bi guncelle, yeni bir veri oldugunu ve guncelemesini oldugunu anlar
            }
        }catch{
            print("basarisiz")
        }
        
         
    }

    @objc func addButtonClicked() {
        selectedName = " "
        performSegue(withIdentifier: "ToDetails", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return namesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = namesArray[indexPath.row]
        return cell
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToDetails" {
            let destinationVC = segue.destination as! DetailsViewController
            destinationVC.selectedProductName = selectedName
            destinationVC.selectedProductUUID = selectedUUID
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedName = namesArray[indexPath.row]
        selectedUUID = idArray[indexPath.row]
        performSegue(withIdentifier: "ToDetails", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")

        let uuiString = idArray[indexPath.row].uuidString
        
        fetchRequest.predicate = NSPredicate(format: "id = %@", uuiString)
        fetchRequest.returnsObjectsAsFaults = false

        do  {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject]{
                    if let id = result.value(forKey: "id") as? UUID{
                        if id == idArray[indexPath.row]{
                            
                            context.delete(result)
                            namesArray.remove(at: indexPath.row)
                            idArray.remove(at: indexPath.row)
                            
                            
                            self.tableView.reloadData()
                            do {
                                try context.save()
                                tableView.reloadData() // Veriyi güncelle
                            } catch {
                                print("Save error: \(error.localizedDescription)")
                            }

                            break
                        }
                    }
                }
            }
        }catch{
            print("hata")
        }
    }
}


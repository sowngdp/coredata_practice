//
//  ViewController.swift
//  ArtBook
//
//  Created by hoi on 13/10/2023.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var nameArray = [String]()
    var idArray = [UUID]()
    
    var chosenArtist = ""
    var chosenArtistId : UUID?
    
    

    @IBOutlet weak var tabelView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        tabelView.delegate = self
        tabelView.dataSource = self
        
        getData()   
        
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        
        
        
        
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
    }

    
    
    @objc func addButtonClicked(){
        chosenArtist = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    @objc func getData(){
        
        
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Artist")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if results.count > 0 {
                
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey:"name") as? String {
                        
                        self.nameArray.append(name)
                        
                    }
                    
                    if let id = result.value(forKey: "id") as? UUID {
                        
                        self.idArray.append(id)
                        
                    }
            }
                    
                tabelView.reloadData()
                
            }
                
            } catch {
                print("Errol")
            }
        }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsVC
            destinationVC.chosenArtist = chosenArtist
            destinationVC.chosenArtistID = chosenArtistId
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenArtist = nameArray[indexPath.row]
        chosenArtistId = idArray[indexPath.row]
        
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let  fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Artist")
            
            let idString = idArray[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        
                        if let id = result.value(forKey: "id") as? UUID {
                            if id == idArray[indexPath.row] {
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                self.tabelView.reloadData()
                                
                                do {
                                    
                                    try context.save()
                                    
                                } catch {
                                    
                                    print("Errol")
                                    
                                }
                                
                                break
                            }
                        }
                        
                    }
                }
                
                
            } catch {
                print("Errol")
            }
        }
    }

//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        <#code#>
//    }
    
}
    
    



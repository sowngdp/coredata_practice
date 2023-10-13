//
//  DetailsVC.swift
//  ArtBook
//
//  Created by hoi on 13/10/2023.
//

import UIKit
import CoreData


class DetailsVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var artistText: UITextField!
    
    @IBOutlet weak var yearText: UITextField!
    
    
    var chosenArtist : String?
    var chosenArtistID : UUID?
    
    
    override func viewDidLoad() {
        
        if chosenArtist != "" {
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let context = appDelegate?.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Artist")
            
            let idString = chosenArtistID?.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                
                let results = try context?.fetch(fetchRequest)
                if results!.count > 0 {
                    for result in results as! [NSManagedObject] {
                        
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        
                        if let artist = result.value(forKey: "artist") as? String {
                            artistText.text = artist
                        }
                        
                        if let year = result.value(forKey: "years") as? Int {
                            yearText.text = String(year)
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
                
            } catch {
                print("Errol")
            }
            
            
        } else {
            nameText.text = ""
            artistText.text = ""
            yearText.text = ""
        }
        
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let gestureRecognizer = UIGestureRecognizer(target: self, action: #selector(hideKeyboard))
        
        view.addGestureRecognizer(gestureRecognizer)
        
        
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
        
        
        
        
    }
    
    @objc func selectImage(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil	)

    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        
        let newArtist =  NSEntityDescription.insertNewObject(forEntityName: "Artist", into: context)
        
        
        newArtist.setValue(nameText.text!, forKey: "name")
        newArtist.setValue(artistText.text!, forKey: "artist")
        
        if let year = Int(yearText.text!){
            newArtist.setValue(year, forKey: "years")
        }
        
        newArtist.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        
        newArtist.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("Successful")
        }
        catch   {
            print("Errol")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
   
}

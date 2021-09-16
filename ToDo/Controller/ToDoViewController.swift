//
//  ViewController.swift
//  ToDo
//
//  Created by Liza Sapsaj on 9/7/21.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoViewController: SwipeTableViewController {
    
    var toDoItems : Results<Item>?
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
    }
    
    //malo pre nego sto se pojavi na ekranu
    override func viewWillAppear(_ animated: Bool) {
        if let colourHex = selectedCategory?.colour{
            title = selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar else {
                fatalError("No nav controller")
            }
            if let navBarColour = UIColor(hexString: colourHex){
              
                navBar.backgroundColor = navBarColour
                navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
                searchBar.barTintColor = navBarColour
                
            }
            
        }
    }
    
    //MARK: - Tableview
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView,cellForRowAt: indexPath)
  
    
        if let item = toDoItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage:CGFloat(indexPath.row)/CGFloat(toDoItems!.count)){
                cell.backgroundColor = colour
        cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
               
            cell.accessoryType = item.done ? .checkmark:.none
        }else{
            cell.textLabel?.text = "No items added"
            
        }
       
        return cell
    }
   
    
    //MARK: - Add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new ToDo item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default){(action) in
            
            if let currentCategory = self.selectedCategory{
                do{
                    try self.realm.write{
                    let newItem = Item()
                    newItem.title = textField.text!
                    newItem.dateCreated = Date()
                    currentCategory.items.append(newItem)
                }
                }catch{
                    print("Error in saving item \(error)")
                }
            }
            self.tableView.reloadData()
        }
      
        alert.addTextField { (alertTextField) in
           
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
 
    
    
    //MARK: - Metode (load)

    func loadItems(){
        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    
    //MARK: - delete data from swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = self.toDoItems?[indexPath.row]{
                do{
                        try self.realm.write{
                            self.realm.delete(itemForDeletion)
                    }
                    }catch{
                        print("Error deleting item \(error)")
                    }
                      
                    }
    }
    
    //MARK: - Tableview (didSelect za done status)
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        if let item = toDoItems?[indexPath.row]{
            do{
            try realm.write {
               
               item.done = !item.done
            }
            }catch{
                print("Error saving done status \(error)")
            }
        }
        tableView.reloadData()
      
    }
    
     
}

//MARK: - Search bar methods
extension ToDoViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        toDoItems = toDoItems?.filter( "title CONTAINS[cd] %@" ,searchBar.text).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchBar.text?.count == 0){
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}



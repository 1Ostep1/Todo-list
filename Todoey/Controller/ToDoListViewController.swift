import UIKit
import CoreData

class ToDoListViewController: UITableViewController {

    var itemArray : [Item] = []
    var selectCategory:Category?{
        didSet{
            loadInfo()
        }
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK: - Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"ToDoListCell",for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    
    //MARK: - Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveInfo()
    }

    //MARK: - Editind / Deleting Information
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            context.delete(itemArray[indexPath.row])
            itemArray.remove(at: indexPath.row)
            saveInfo()
        }
    }
    @IBAction func editItemPressed(_ sender: UIBarButtonItem) {
        tableView.isEditing = !tableView.isEditing
        sender.title = (tableView.isEditing) ? "Done":"Edit"
    }
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedItem = itemArray[sourceIndexPath.row]
        itemArray.remove(at: sourceIndexPath.row)
        itemArray.insert(movedItem, at:destinationIndexPath.row)
        saveInfo()
    }
    
    //MARK: - Add new item
    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title:"Add new item", message:"", preferredStyle: .alert)
        let action = UIAlertAction(title:"Add", style: .default) { (action) in
            let newItem = Item(context: self.context)
            newItem.title = textField.text
            newItem.done = false
            newItem.parentCategory = self.selectCategory
            self.itemArray.append(newItem)
            self.saveInfo()
        }
        let cancelAction = UIAlertAction(title:"Cancel", style:.cancel)
        alert.addTextField { (textF) in
            textF.placeholder = "Item"
            textField = textF
        }
        alert.addAction(cancelAction)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - save/load
    
    func saveInfo(){
        do {
            try context.save()
        } catch {
            print("Error:\(error)")
        };tableView.reloadData()
    }
    
    func loadInfo(with request:NSFetchRequest<Item> = Item.fetchRequest(), predicate:NSPredicate? = nil){
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectCategory!.name!)
        if let additionalPredicate = predicate{
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionalPredicate])
        }else{
            request.predicate = categoryPredicate
        }
        do {
           itemArray = try context.fetch(request)
        } catch {
            print("Error:\(error)")
        };tableView.reloadData()
    }
    
}

//MARK: - SearchBar methods

extension ToDoListViewController:UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request:NSFetchRequest<Item> = Item.fetchRequest()
        let predicate  = NSPredicate(format:"title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key:"title", ascending: true)]
        loadInfo(with:request, predicate:predicate)
        tableView.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadInfo()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}


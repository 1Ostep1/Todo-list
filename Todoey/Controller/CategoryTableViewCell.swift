import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var categoryArray:[Category]  = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadInfo()
    }
    //MARK: - Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"categoryCell",for: indexPath)
        let category = categoryArray[indexPath.row]
        cell.textLabel?.text = category.name
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    //MARK: - Delete /Edit Methods
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            context.delete(categoryArray[indexPath.row])
            categoryArray.remove(at: indexPath.row)
            saveInfo()
        }
    }
    @IBAction func editCategoryPressed(_ sender: UIBarButtonItem) {
        tableView.isEditing = !tableView.isEditing
        sender.title = (tableView.isEditing) ? "Done":"Edit"
    }
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedCategory = categoryArray[sourceIndexPath.row]
        categoryArray.remove(at: sourceIndexPath.row)
        categoryArray.insert(movedCategory, at:destinationIndexPath.row)
        saveInfo()
    }
    
    //MARK: - Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier:"goToItems", sender:self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectCategory = categoryArray[indexPath.row]
        }
    }
    //MARK: - Data Manipulation Methods

    @IBAction func addPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title:"Add category", message:"", preferredStyle:.alert)
        let addAction = UIAlertAction(title:"Add", style: .default) { (action) in
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text
            self.categoryArray.append(newCategory)
            self.saveInfo()
        }
        let cancelAction = UIAlertAction(title:"Cancel", style:.cancel)
        alert.addTextField { (textF) in
            textF.placeholder = "Category"
            textField = textF
        }
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        present(alert, animated: true, completion: nil)
    }
    //MARK: - Save / Load Information From CoreData
    
    func saveInfo(){
        do {
            try context.save()
        } catch {
            print("Error:\(error)")
        };tableView.reloadData()
    }
    
    func loadInfo(with request:NSFetchRequest<Category> = Category.fetchRequest(), predicate:NSPredicate? = nil){
        request.predicate = predicate
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error:\(error)")
        };tableView.reloadData()
    }
    
}
//MARK: - SearchBar methods

extension CategoryTableViewController:UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request:NSFetchRequest<Category> = Category.fetchRequest()
        let predicate  = NSPredicate(format:"name CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key:"name", ascending: true)]
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

//
//  ViewController.swift
//  Combine+CoreData+Viper
//
//  Created by Ramkrishna Sharma on 27/03/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var records = [ListingModel]()
    var presentor: ViewToPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Person Listing"
        presentor?.startFetching()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
    }

    @objc func addTapped() {
        promptForAddingPerson()
    }

    func promptForAddingPerson(isUpdate: Bool = false, text: String = "") {
        let ac = UIAlertController(title: isUpdate ? "Update person full name" : "Enter person full name", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let textField = ac.textFields![0]
        textField.text = text

        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
            let textField = ac.textFields![0]
            // do something interesting with "answer" here
            if isUpdate {
                self.presentor?.updatePerson(fullName: textField.text ?? "", searchFullName: text)
            } else {
                self.presentor?.addPerson(fullName: textField.text ?? "")
            }
        }

        ac.addAction(submitAction)
        present(ac, animated: true)
    }
}

extension ViewController: PresenterToViewProtocol {
    func showRecord(records: Array<ListingModel>) {
        self.records = records
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListingTableViewCell", for: indexPath) as! ListingTableViewCell
        let record = records[indexPath.row]
        cell.lblTitle.text = record.fullName
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let record = records[indexPath.row]
        promptForAddingPerson(isUpdate: true, text: record.fullName)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let record = records[indexPath.row]
            presentor?.deletePerson(fullName: record.fullName)
        }
    }
}

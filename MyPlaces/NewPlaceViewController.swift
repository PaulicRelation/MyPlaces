//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Pavel on 6/8/19.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit

class NewPlaceViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()

    }

    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {

        }
        else {
            view.endEditing(true)
        }
    }

}

// MARK: - Text field delegate

extension NewPlaceViewController: UITextFieldDelegate {
    // Hide keyboard when Done pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }


}


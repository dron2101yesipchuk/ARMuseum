//
//  VirtualObjectsListController.swift
//  ARMuseum
//
//  Created by Dron on 03.05.2020.
//  Copyright © 2020 dron. All rights reserved.
//

import UIKit
import QuickLook

class VirtualObjectsListController: UITableViewController {
    
    var models: [VirtualObject] = []
    var modelIndex = 0;
        
    override func viewDidLoad() {
        super.viewDidLoad()

        self.models = VirtualObjectsManager.shared.retrieveItems()
        self.tableView.reloadData()
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.models.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "VirtualObjectCell", for: indexPath) as? VirtualObjectCell {
            cell.configureWith(modelImage: UIImage(named: self.models[indexPath.row].image) ?? UIImage(), modelName: self.models[indexPath.row].name)
            return cell
        }

        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.modelIndex = indexPath.row
        let previewController = QLPreviewController()
        previewController.delegate = self
        previewController.dataSource = self
        self.present(previewController, animated: true, completion: nil)
    }
}

extension VirtualObjectsListController: QLPreviewControllerDelegate, QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let url = Bundle.main.url(forResource: models[modelIndex].name, withExtension: "usdz")!
        return url as QLPreviewItem
    }
}

//
//  ViewController.swift
//  TradeOpteck
//
//  Created by Yevgenii Pasko on 4/26/18.
//  Copyright © 2018 Yevgenii Pasko. All rights reserved.
//

import UIKit

class СurrencyViewController: UIViewController {

    @IBOutlet weak var valuteTableView: UITableView!
    private let valutesListViewModel = ValuesViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        valutesListViewModel.compliteViewControllerHandler = {
            DispatchQueue.main.async {
                self.valuteTableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let vc = segue.destination
        
        guard let resultVC: PlotViewController = vc as? PlotViewController else {
            return
        }
      
        let idexPath = sender as! IndexPath
        let dictObject = valutesListViewModel.currentCurrencies[idexPath.row]
        let plotViewModel = PlotViewModel()
        plotViewModel.currentObject = dictObject as? [String : String]
        
        let graphsView = PlotGraphsView()
        graphsView.plotViewModel = plotViewModel
        resultVC.hostView = graphsView
    }
}

extension СurrencyViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableValueIdentifier) as! ValueTableCell
        
        cell.setParameters(dict: (valutesListViewModel.currentCurrencies[indexPath.row] as? [String : String]) ?? ["":""])
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return valutesListViewModel.currentCurrencies.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: Constants.CellSegueToGraph, sender: indexPath)
    }
}



//
//  ChartListViewController.swift
//  CoinFlowMVVMAgain
//
//  Created by APPLE on 2021/01/19.
//

import UIKit

class ChartListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    private func showDetail() {
        let storyboard = UIStoryboard(name: "Chart", bundle: .main)
        let chartDetailViewController = storyboard.instantiateViewController(withIdentifier: "ChartDetailViewController")
        navigationController?.pushViewController(chartDetailViewController, animated: true)
    }
}

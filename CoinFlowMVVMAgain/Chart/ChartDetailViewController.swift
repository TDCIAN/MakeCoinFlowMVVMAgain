//
//  ChartDetailViewController.swift
//  CoinFlowMVVMAgain
//
//  Created by APPLE on 2021/01/19.
//

import UIKit

class ChartDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NetworkManager.requestCoinChartData { result in
            switch result {
            case .success(let coinChartDatas):
                print("--> coin chart data: \(coinChartDatas.count)")
            case .failure(let error):
                print("--> coin chart error: \(error.localizedDescription)")
            }
        }
    }

}

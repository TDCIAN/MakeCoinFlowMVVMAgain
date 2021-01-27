//
//  ChartDetailViewController.swift
//  CoinFlowMVVMAgain
//
//  Created by APPLE on 2021/01/19.
//

import UIKit

class ChartDetailViewController: UIViewController {
    
    var coinInfo: CoinInfo!
    @IBOutlet weak var coinTypeLabel: UILabel!
    
    @IBOutlet weak var currentPriceLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        updateCoinInfo(coinInfo: coinInfo)
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("--> 꽂힌 정보는: \(coinInfo.key)")
    }
}

extension ChartDetailViewController {
    
    private func fetchData() {
        NetworkManager.requestCoinChartData { result in
            switch result {
            case .success(let coinChartDatas):
                print("--> coin chart data: \(coinChartDatas.count)")
            case .failure(let error):
                print("--> coin chart error: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateCoinInfo(coinInfo: CoinInfo) {
        coinTypeLabel.text = "\(coinInfo.key)"
        currentPriceLabel.text = String(format: "%.1f", coinInfo.value.usd.price)
    }
}

//
//  ChartDetailViewController.swift
//  CoinFlowMVVMAgain
//
//  Created by APPLE on 2021/01/19.
//

import UIKit

typealias CoinChartInfo = (key: Period, value: [ChartData])
class ChartDetailViewController: UIViewController {
    
    var coinInfo: CoinInfo!
    
    var chartDatas: [CoinChartInfo] = []
    var selectedPeriod: Period = .day
    
    @IBOutlet weak var coinTypeLabel: UILabel!
    @IBOutlet weak var currentPriceLabel: UILabel!
    @IBOutlet weak var highlightBar: UIView!
    @IBOutlet weak var highlightBarLeading: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateCoinInfo(coinInfo: coinInfo)
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("--> 꽂힌 정보는: \(coinInfo.key)")
    }
    @IBAction func dailyButtonTapped(_ sender: UIButton) {
        moveHighlightBar(to: sender)
    }
    @IBAction func weeklyButtonTapped(_ sender: UIButton) {
        moveHighlightBar(to: sender)
    }
    @IBAction func monthlyButtonTapped(_ sender: UIButton) {
        moveHighlightBar(to: sender)
    }
    @IBAction func yearlyButtonTapped(_ sender: UIButton) {
        moveHighlightBar(to: sender)
    }
}

extension ChartDetailViewController {
    
    private func fetchData() {
        
        let periodUnits: [Period] = [.day, .week, .month, .year]
        periodUnits.forEach { period in
            NetworkManager.requestCoinChartData(coinType: coinInfo.key, period: period) { result in
                switch result {
                case .success(let coinChartDatas):
                    print("--> coin chart data: \(coinChartDatas.count)")
                    self.chartDatas.append(CoinChartInfo(key: period, value: coinChartDatas))
                case .failure(let error):
                    print("--> coin chart error: \(error.localizedDescription)")
                }
            }
        }
        
//        NetworkManager.requestCoinChartData(coinType: coinInfo.key, period: .day) { result in
//            switch result {
//            case .success(let coinChartDatas):
//                print("--> coin chart data: \(coinChartDatas.count)")
//                self.chartDatas.append(CoinChartInfo(key: .day, value: coinChartDatas))
//            case .failure(let error):
//                print("--> coin chart error: \(error.localizedDescription)")
//            }
//        }
//
//        NetworkManager.requestCoinChartData(coinType: coinInfo.key, period: .week) { result in
//            switch result {
//            case .success(let coinChartDatas):
//                print("--> coin chart data: \(coinChartDatas.count)")
//                self.chartDatas.append(CoinChartInfo(key: .week, value: coinChartDatas))
//            case .failure(let error):
//                print("--> coin chart error: \(error.localizedDescription)")
//            }
//        }
//
//        NetworkManager.requestCoinChartData(coinType: coinInfo.key, period: .month) { result in
//            switch result {
//            case .success(let coinChartDatas):
//                print("--> coin chart data: \(coinChartDatas.count)")
//                self.chartDatas.append(CoinChartInfo(key: .month, value: coinChartDatas))
//            case .failure(let error):
//                print("--> coin chart error: \(error.localizedDescription)")
//            }
//        }
//
//        NetworkManager.requestCoinChartData(coinType: coinInfo.key, period: .year) { result in
//            switch result {
//            case .success(let coinChartDatas):
//                print("--> coin chart data: \(coinChartDatas.count)")
//                self.chartDatas.append(CoinChartInfo(key: .year, value: coinChartDatas))
//            case .failure(let error):
//                print("--> coin chart error: \(error.localizedDescription)")
//            }
//        }
    }
    
    private func updateCoinInfo(coinInfo: CoinInfo) {
        coinTypeLabel.text = "\(coinInfo.key)"
        currentPriceLabel.text = String(format: "%.1f", coinInfo.value.usd.price)
    }
    
    private func moveHighlightBar(to button: UIButton) {
        self.highlightBarLeading.constant = button.frame.minX
    }
}

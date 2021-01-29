//
//  ChartCardCell.swift
//  CoinFlowMVVMAgain
//
//  Created by APPLE on 2021/01/29.
//

import UIKit
import Charts

class ChartCardCell: UICollectionViewCell {

    func configCell(coinInfo: CoinInfo) {
        coinNameLabel.text = coinInfo.key.rawValue
        
    }
    
    
    
    private func fetchData() {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        NetworkManager.requestCoinChartData(coinType: coinInfo.key, period: .day) { result in
            switch result {
            case .success(let coinChartData):
                print("chartListVC - coinChartData: \(coinChartData.count)")
                self.chartDatas.append(CoinChartInfo(key: period, value: coinChartData))
            case .failure(let error):
                print("chartListVC - coinChart error: \(error.localizedDescription)")
            }
        }
        dispatchGroup.notify(queue: .main) {
            print("--> 다 받았다 \(chartDatas.count)")
            self.renderChart(with: self.selectedPeriod)
        }
    }
}

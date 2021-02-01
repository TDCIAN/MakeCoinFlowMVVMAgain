//
//  ChartCardCellViewModel.swift
//  CoinFlowMVVMAgain
//
//  Created by APPLE on 2021/02/01.
//

import Foundation

class ChartCardCellViewModel {
    typealias Handler = ([CoinChartInfo], Period) -> Void
    var changeHandler: Handler
    
    var coinInfo: CoinInfo!
    var chartDatas: [CoinChartInfo] = []
    var selectedPeriod: Period = .week
    
    init(coinInfo: CoinInfo, chartDatas: [CoinChartInfo], selectedPeriod: Period, changeHandler: @escaping Handler) {
        self.coinInfo = coinInfo
        self.chartDatas = chartDatas
        self.selectedPeriod = selectedPeriod
        self.changeHandler = changeHandler
    }
}

extension ChartCardCellViewModel {
    func fetchData() {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        NetworkManager.requestCoinChartData(coinType: coinInfo.key, period: .week) { result in
            dispatchGroup.leave()
            switch result {
            case .success(let coinChartDatas):
                self.chartDatas.append(CoinChartInfo(key: Period.week, value: coinChartDatas))
            case .failure(let error):
                print("--> Card cell fetch data error: \(error.localizedDescription)")
            }
        }

        dispatchGroup.notify(queue: .main) {
            print("--> Card cell에서 차트 렌더: \(self.chartDatas.count)")
            self.changeHandler(self.chartDatas, self.selectedPeriod)
        }
    }
    
    func updateNotify(handler: @escaping Handler) {
        self.changeHandler = handler
    }
}

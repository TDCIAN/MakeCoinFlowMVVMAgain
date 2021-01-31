//
//  ChartDetailViewModel.swift
//  CoinFlowMVVMAgain
//
//  Created by APPLE on 2021/02/01.
//

import Foundation

class ChartDetailViewModel {
    // 차트 그림 그릴 때 필요한 요소들을 핸들러에 담는다
    typealias Handler = ([CoinChartInfo], Period) -> Void
    var changeHandler: Handler
    
    var coinInfo: CoinInfo!
    var chartDatas: [CoinChartInfo] = []
    var selectedPeriod: Period = .day
    
    init(coinInfo: CoinInfo, chartDatas: [CoinChartInfo], selectedPeriod: Period, changeHandler: @escaping Handler) {
        self.coinInfo = coinInfo
        self.chartDatas = chartDatas
        self.selectedPeriod = selectedPeriod
        self.changeHandler = changeHandler
    }
}

extension ChartDetailViewModel {
    func fetchData() {
        let dispatchGroup = DispatchGroup()
        
        Period.allCases.forEach { period in
            dispatchGroup.enter()
            NetworkManager.requestCoinChartData(coinType: coinInfo.key, period: period) { result in
                dispatchGroup.leave()
                switch result {
                case .success(let coinChartDatas):
                    print("--> coin chart data -> period: \(period): \(coinChartDatas.count)")
                    self.chartDatas.append(CoinChartInfo(key: period, value: coinChartDatas))
                case .failure(let error):
                    print("--> coin chart error: \(error.localizedDescription)")
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            print("--> 다 받았으니 차트를 렌더하자 -> \(self.chartDatas.count)")
            self.changeHandler(self.chartDatas, self.selectedPeriod)
        }
    }
    
    func updateNotify(handler: @escaping Handler) {
        self.changeHandler = handler
    }
}

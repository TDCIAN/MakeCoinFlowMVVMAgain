//
//  CoinChartDataRequest.swift
//  CoinFlowMVVMAgain
//
//  Created by APPLE on 2021/01/27.
//

import Foundation

struct CoinChartDataRequest: Request {
    var method: HTTPMethod = .get
    var params: RequestParam
    var path: String
    
    init(period: Period, param: RequestParam) {
        self.path = EndPoint.coinChartData + period.urlPath
        self.params = param
    }
}

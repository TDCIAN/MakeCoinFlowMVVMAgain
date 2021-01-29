//
//  ChartDetailViewController.swift
//  CoinFlowMVVMAgain
//
//  Created by APPLE on 2021/01/19.
//

import UIKit
import Charts

typealias CoinChartInfo = (key: Period, value: [ChartData])
class ChartDetailViewController: UIViewController {
    
    var coinInfo: CoinInfo!
    var chartDatas: [CoinChartInfo] = []
    var selectedPeriod: Period = .day
    
    @IBOutlet weak var coinTypeLabel: UILabel!
    @IBOutlet weak var currentPriceLabel: UILabel!
    @IBOutlet weak var highlightBar: UIView!
    @IBOutlet weak var highlightBarLeading: NSLayoutConstraint!
    
    @IBOutlet weak var chartView: LineChartView!
    
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
        renderChart(with: .day)
        moveHighlightBar(to: sender)
    }
    @IBAction func weeklyButtonTapped(_ sender: UIButton) {
        renderChart(with: .week)
        moveHighlightBar(to: sender)
    }
    @IBAction func monthlyButtonTapped(_ sender: UIButton) {
        renderChart(with: .month)
        moveHighlightBar(to: sender)
    }
    @IBAction func yearlyButtonTapped(_ sender: UIButton) {
        renderChart(with: .year)
        moveHighlightBar(to: sender)
    }
}

extension ChartDetailViewController {
    
    private func fetchData() {
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
            self.renderChart(with: self.selectedPeriod)
        }
    }
    
    private func updateCoinInfo(coinInfo: CoinInfo) {
        coinTypeLabel.text = "\(coinInfo.key)"
        currentPriceLabel.text = String(format: "%.1f", coinInfo.value.usd.price)
    }
    
    private func moveHighlightBar(to button: UIButton) {
        self.highlightBarLeading.constant = button.frame.minX
    }
    
    private func renderChart(with period: Period) {
        print("rendering with \(period)")
        
        // 데이터 가져오기
        guard let coinChartData = chartDatas.first(where: { $0.key == period })?.value else { return }
        
        // 차트에 필요한 차트데이터 가공
        let chartDataEntry = coinChartData.map { chartData -> ChartDataEntry in
            let time = chartData.time
            let price = chartData.closePrice
            return ChartDataEntry(x: time, y: price)
        }
        
        // 차트에 적용 -> how to draw
        let lineChartDataSet = LineChartDataSet(entries: chartDataEntry, label: "Coin Value")
        // -- draw mode
        lineChartDataSet.mode = .horizontalBezier
        // -- color
        lineChartDataSet.colors = [UIColor.systemBlue]
        // -- draw circle
        lineChartDataSet.drawCirclesEnabled = false
        lineChartDataSet.drawCircleHoleEnabled = false
        // -- draw y value
        lineChartDataSet.drawValuesEnabled = false
        // -- highlight when user touch
        lineChartDataSet.highlightEnabled = true
        lineChartDataSet.drawHorizontalHighlightIndicatorEnabled = false
        lineChartDataSet.highlightColor = UIColor.systemBlue
        
        let data = LineChartData(dataSet: lineChartDataSet)
        chartView.data = data
        
        // gradient fill
        let startColor = UIColor.systemBlue
        let endColor = UIColor(white: 1, alpha: 0.3)
        
        let gradientColors = [startColor.cgColor, endColor.cgColor] as CFArray // Colors of the gradient
        let colorLocations: [CGFloat] = [1.0, 0.0] // Positioning of the gradient
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations)
        lineChartDataSet.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0) // Set the Gradient
        lineChartDataSet.drawFilledEnabled = true // Draw the Gradient
        
        // Axis - xAxis
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.valueFormatter = xAxisDateFormatter(period: period)
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = true
        xAxis.drawLabelsEnabled = true
        
        // Axis - yAxis
        let leftYAxis = chartView.leftAxis
        leftYAxis.drawGridLinesEnabled = false
        leftYAxis.drawAxisLineEnabled = false
        leftYAxis.drawLabelsEnabled = false
        
        let rightYAxis = chartView.rightAxis
        rightYAxis.drawGridLinesEnabled = false
        rightYAxis.drawAxisLineEnabled = false
        rightYAxis.drawLabelsEnabled = false
        
        // User InterAction
        chartView.doubleTapToZoomEnabled = false
        chartView.dragEnabled = true
        
        chartView.delegate = self
        
        // Chart Description
        let description = Description()
        description.text = ""
        chartView.chartDescription = description
        
        // Legend
        let legend = chartView.legend
        legend.enabled = false
        
    }
}

extension ChartDetailViewController {
    private func xAxisDateFormatter(period: Period) -> IAxisValueFormatter {
        switch period {
        case .day: return ChartXAxisDayFormatter()
        case .week: return ChartXAxisWeekFormatter()
        case .month: return ChartXAxisMonthFormatter()
        case .year: return ChartXAxisYearFormatter()
        }
    }
}

extension ChartDetailViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print("chartValueSelected --> entry.x값: \(entry.x), entry.y값: \(entry.y), highlight값: \(highlight)")
        currentPriceLabel.text = String(format: "%.1f", entry.y)
    }
}

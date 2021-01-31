//
//  ChartListViewController.swift
//  CoinFlowMVVMAgain
//
//  Created by APPLE on 2021/01/19.
//

import UIKit
import Charts

typealias CoinInfo = (key: CoinType, value: Coin)

class ChartListViewController: UIViewController {
    
    @IBOutlet weak var chartCollectionView: UICollectionView!
    @IBOutlet weak var chartTableView: UITableView!
    @IBOutlet weak var chartTableViewHeight: NSLayoutConstraint!
    
    var coinInfoList: [CoinInfo] = [] {
        // data가 세팅이 되면 didSet
        didSet {
            // data 세팅이 되면 테이블뷰 리스트 다시 그리기, 테이블뷰 리로드
            DispatchQueue.main.async {
                self.chartCollectionView.reloadData()
                self.chartTableView.reloadData()
                self.adjustTableViewHeight()
            }
        }
    }
    
    var coinInfo: CoinInfo!
    var chartDatas: [CoinChartInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NetworkManager.requestCoinList { result in
            switch result {
            case .success(let coins):
                // cell에는 coin type과 해당 coin의 정보가 들어가야 한다
                let tuples = zip(CoinType.allCases, coins).map { (key: $0, value: $1) }
                self.coinInfoList = tuples
                
//                print("--> coin list: \(coins.count), \(coins)")
            case .failure(let error):
                print("--> coin list error: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Private Method
extension ChartListViewController {
    private func adjustTableViewHeight() {
        chartTableViewHeight.constant = chartTableView.contentSize.height
    }
    
    private func showDetail(coinInfo: CoinInfo) {
        let storyboard = UIStoryboard(name: "Chart", bundle: .main)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "ChartDetailViewController") as? ChartDetailViewController {
            detailVC.coinInfo = coinInfo
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

// MARK: - Collection View
extension ChartListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return coinInfoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChartCardCell", for: indexPath) as? ChartCardCell else { return UICollectionViewCell() }
        let coinInfo = coinInfoList[indexPath.row]
        cell.updateCoinInfo(coinInfo: coinInfo)
        cell.fetchData()
        return cell
    }
}

extension ChartListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.frame.width - 20 * 2 - 15
        let height: CGFloat = 200
        return CGSize(width: width, height: height)
    }
}

class ChartCardCell: UICollectionViewCell, ChartViewDelegate {
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var chartViewForCardCell: LineChartView!
    
    var coinInfo: CoinInfo!
    var chartDatas: [CoinChartInfo] = []
    var selecedPeriod: Period = .week
    
    func updateCoinInfo(coinInfo: CoinInfo) {
        self.coinInfo = coinInfo
        coinNameLabel.text = coinInfo.key.rawValue
    }
    
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
            self.renderChart()
        }
    }
    
    func renderChart() {
        // 데이터 가져오기
        guard let coinChartData = chartDatas.first(where: { $0.key == Period.week })?.value else { return }
        
        // 차트에 필요한 차트데이터 가공
        let chartDataEntry = coinChartData.map { chartData -> ChartDataEntry in
            let time = chartData.time
            let price = chartData.closePrice
            return ChartDataEntry(x: time, y: price)
        }
        
        // 차트에 적용 -> how to draw
        let lineChartDataSet = LineChartDataSet(entries: chartDataEntry, label: "Coin Value")
        // -- darw mode
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
        chartViewForCardCell.data = data
        
        // gradient fill -> 이거 나중에 바꾸면 차트 컬러 바꿀 수 있겠다
        let startColor = UIColor.systemBlue
        let endColor = UIColor(white: 1, alpha: 0.3)
        
        let gradientColors = [startColor.cgColor, endColor.cgColor] as CFArray // Colors of the gradient
        let colorLocations: [CGFloat] = [1.0, 0.0] // Positioning of the gradient
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations)
        lineChartDataSet.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0) // Set the Gradient
        lineChartDataSet.drawFilledEnabled = true // Draw the Gradient
        
        // Axis - xAxis
        let xAxis = chartViewForCardCell.xAxis
        xAxis.labelPosition = .bottom
        xAxis.valueFormatter = xAxisDateFormatter(period: .week)
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = true
        xAxis.drawLabelsEnabled = true
        
        // Axis - yAxis
        let leftYAxis = chartViewForCardCell.leftAxis
        leftYAxis.drawGridLinesEnabled = false
        leftYAxis.drawAxisLineEnabled = false
        leftYAxis.drawLabelsEnabled = false
        
        let rightYAxis = chartViewForCardCell.rightAxis
        rightYAxis.drawGridLinesEnabled = false
        rightYAxis.drawAxisLineEnabled = false
        rightYAxis.drawLabelsEnabled = false
        
        // User InterAction
        chartViewForCardCell.doubleTapToZoomEnabled = false
        chartViewForCardCell.dragEnabled = true
        
        chartViewForCardCell.delegate = self
        
        // Chart Description
        let description = Description()
        description.text = ""
        chartViewForCardCell.chartDescription = description
        
        // Legend
        let legend = chartViewForCardCell.legend
        legend.enabled = false
    }
    
    func xAxisDateFormatter(period: Period) -> IAxisValueFormatter {
        switch period {
        case .day: return ChartXAxisDayFormatter()
        case .week: return ChartXAxisWeekFormatter()
        case .month: return ChartXAxisMonthFormatter()
        case .year: return ChartXAxisYearFormatter()
        }
    }
}

// MARK: - Table View
extension ChartListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coinInfoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChartListCell", for: indexPath) as? ChartListCell else { return UITableViewCell()
        }
        let coinInfo = coinInfoList[indexPath.row]
        cell.configCell(coinInfo: coinInfo)
        return cell
    }
}

extension ChartListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coinInfo = coinInfoList[indexPath.row]
        showDetail(coinInfo: coinInfo)
    }
}

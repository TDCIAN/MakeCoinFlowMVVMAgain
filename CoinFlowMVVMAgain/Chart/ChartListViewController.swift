//
//  ChartListViewController.swift
//  CoinFlowMVVMAgain
//
//  Created by APPLE on 2021/01/19.
//

import UIKit

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
                self.chartTableView.reloadData()
                self.adjustTableViewHeight()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NetworkManager.requestCoinList { result in
            switch result {
            case .success(let coins):
                // cell에는 coin type과 해당 coin의 정보가 들어가야 한다
                let tuples = zip(CoinType.allCases, coins).map { (key: $0, value: $1) }
                self.coinInfoList = tuples
                
                print("--> coin list: \(coins.count), \(coins)")
            case .failure(let error):
                print("--> coin list error: \(error.localizedDescription)")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 이 시점에 테이블뷰 컨텐츠사이즈 파악 후, 테이블뷰 높이를 조정하겠다
        
        
    }
}

// MARK: - Private Method
extension ChartListViewController {
    private func adjustTableViewHeight() {
        chartTableViewHeight.constant = chartTableView.contentSize.height
    }
    
    private func showDetail() {
        let storyboard = UIStoryboard(name: "Chart", bundle: .main)
        let chartDetailViewController = storyboard.instantiateViewController(withIdentifier: "ChartDetailViewController")
        navigationController?.pushViewController(chartDetailViewController, animated: true)
    }
}

// MARK: - Collection View
extension ChartListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChartCardCell", for: indexPath) as? ChartCardCell else { return UICollectionViewCell() }
        cell.backgroundColor = .randomColor()
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

class ChartCardCell: UICollectionViewCell {

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
        showDetail()
    }
}

class ChartListCell: UITableViewCell {
    @IBOutlet weak var currentStatusBox: UIView!
    @IBOutlet weak var coinName: UILabel!
    @IBOutlet weak var currentPrice: UILabel!
    @IBOutlet weak var change24Hours: UILabel!
    @IBOutlet weak var changePercent: UILabel!
    @IBOutlet weak var currentStatusImageView: UIImageView!
        
    func configCell(coinInfo: CoinInfo) {
        let coinType = coinInfo.key
        let coin = coinInfo.value
        
        let isUnderPerform = coin.usd.changeLast24H < 0
        let upColor = UIColor.systemPink
        let downColor = UIColor.systemBlue
        let color = isUnderPerform ? downColor : upColor
        currentStatusBox.backgroundColor = color
        coinName.text = coinType.rawValue
        currentPrice.text = String(format: "%.1f", coin.usd.price)
        
        change24Hours.text = String(format: "%.1f", coin.usd.changePercentLast24H)
        
        changePercent.text = String(format: "%.1f %%", coin.usd.changePercentLast24H)
        
        change24Hours.textColor = color
        changePercent.textColor = color
        
        let statusImage = isUnderPerform ? UIImage(systemName: "arrowtriangle.down.fill") : UIImage(systemName: "arrowtriangle.up.fill")
        currentStatusImageView.image = statusImage
        currentStatusImageView.tintColor = color
    }
}

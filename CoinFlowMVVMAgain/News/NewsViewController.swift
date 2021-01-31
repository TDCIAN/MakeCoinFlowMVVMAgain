//
//  NewsViewController.swift
//  CoinFlowMVVMAgain
//
//  Created by APPLE on 2021/01/19.
//

import UIKit
import Kingfisher

class NewsViewController: UIViewController {
    
    @IBOutlet weak var newsTableView: UITableView!
    var articles: [Article] = [] {
        didSet {
            DispatchQueue.main.async {
                self.newsTableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NetworkManager.requestNewsList { result in
            switch result {
            case .success(let articles):
//                print("--> article list: \(articles.count)")
                self.articles = articles
            case .failure(let error):
                print("--> article error: \(error.localizedDescription)")
            }
        }
    }
}

extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewsListCell", for: indexPath) as? NewsListCell else { return UITableViewCell()
        }
        let article = articles[indexPath.row]
        cell.configCell(article: article)
        return cell
    }
    
    
}

class NewsListCell: UITableViewCell {
    @IBOutlet weak var thumnail: UIImageView!
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsDate: UILabel!
    
    func configCell(article: Article) {
        let url = URL(string: article.imageURL)!
        thumnail.kf.setImage(with: url)
        newsTitle.text = article.title
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        newsDate.text = formatter.string(from: Date(timeIntervalSince1970: article.timestamp))
        
    }
    
}

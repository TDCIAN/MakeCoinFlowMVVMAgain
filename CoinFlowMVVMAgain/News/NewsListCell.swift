//
//  NewsListCell.swift
//  CoinFlowMVVMAgain
//
//  Created by APPLE on 2021/01/31.
//

import UIKit
import Kingfisher

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

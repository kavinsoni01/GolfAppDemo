//
//  GolfListTableCell.swift
//  GolfAppDemo
//
//  Created by Kavin's Macbook on 22/05/25.
//

import UIKit
import Cosmos

class GolfListTableCell: UITableViewCell {
    
    var isLayoutSubviews:Bool = false
    private var didLayout = false

    @IBOutlet weak var viewBack: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var viewRating: CosmosView!


    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !didLayout {
            didLayout = true
            applyCornerRadiusAndShadow()
        }
    }

    private func setupUI() {
        selectionStyle = .none

        lblTitle.font = UIFont.boldSystemFont(ofSize: 16)
        lblTitle.textColor = .label

        lblLocation.font = UIFont.systemFont(ofSize: 14)
        lblLocation.textColor = .secondaryLabel

        viewRating.settings.fillMode = .precise
        viewRating.settings.updateOnTouch = false
        viewRating.settings.starSize = 18
        viewRating.settings.starMargin = 2
        viewRating.rating = 0
    }

    private func applyCornerRadiusAndShadow() {
        viewBack.layer.cornerRadius = 10
        viewBack.layer.masksToBounds = false
        viewBack.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        viewBack.layer.shadowOffset = CGSize(width: 0, height: 2)
        viewBack.layer.shadowOpacity = 0.4
        viewBack.layer.shadowRadius = 4
    }
    

    func configureCell(with model: Course) {
        lblTitle.text = model.club_name ?? "Unnamed Golf Course"

        if let address = model.location?.address, !address.isEmpty {
            lblLocation.text = address
        } else {
            lblLocation.text = "N/A"
        }

        viewRating.rating = model.rating ?? 3.0
        
//        // Static rating for mock purpose
//        let possibleValues: [Double] = [2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0]
//        viewRating.rating = possibleValues.randomElement() ?? 3.0
    }
}

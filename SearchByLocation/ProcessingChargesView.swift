//
//  ProcessingChargesView.swift
//  iDonate
//
//  Created by Satheesh k on 08/07/20.
//  Copyright © 2020 Im043. All rights reserved.
//

import UIKit

class ProcessingChargesView: UIView {
    
    var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Donation Calculation"
        label.textColor = fontBlackColor
        return label
    }()
    
    var closeBtn: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "close"), for: .normal)
        return button
    }()

    var donationAmountTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Donation amount"
        label.textColor = fontBlackColor
        return label
    }()
    
    var donationAmountValue: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = fontBlackColor
        label.text = "$ 200"
        label.textAlignment = .right
        return label
    }()


    var processingFeeTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Processing Fee"
        label.textColor = fontBlackColor
        return label
    }()

    var processingFeeValue: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = fontBlackColor
        label.text = "$ 2"
        label.textAlignment = .right

        return label
    }()


    var merchantChargesTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Merchant Charges\n(2.9% + $ 0.30)"
        label.numberOfLines = 0
        label.textColor = fontBlackColor
        return label
    }()

    var merchantChargesValue: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = fontBlackColor
        label.text = "$ 6.1"
        label.textAlignment = .right

        return label
    }()

    var seperatorLable: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = fontBlackColor
        return label
    }()
    
    var totalAmountTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Total amount"
        label.textColor = fontBlackColor
        return label
    }()

    var totalAmountValue: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = fontBlackColor
        label.text = "$ 208.1"
        label.textAlignment = .right

        return label
    }()


    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(closeBtn)
        containerView.addSubview(donationAmountTitle)
        containerView.addSubview(donationAmountValue)
        containerView.addSubview(processingFeeTitle)
        containerView.addSubview(processingFeeValue)
        containerView.addSubview(merchantChargesTitle)
        containerView.addSubview(merchantChargesValue)
        containerView.addSubview(seperatorLable)
        containerView.addSubview(totalAmountTitle)
        containerView.addSubview(totalAmountValue)
        
        containerView.backgroundColor = ivoryColor
        containerView.layer.cornerRadius = 10.0
        self.addSubview(containerView)
        
        setUpView()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setUpView() {
        
        NSLayoutConstraint.activate([containerView.heightAnchor.constraint(equalToConstant: 250),
                                     containerView.widthAnchor.constraint(equalToConstant: 350),
                                     containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
                                     containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0)])
        
        NSLayoutConstraint.activate([titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 20),
                                     titleLabel.widthAnchor.constraint(equalTo: self.containerView.widthAnchor, multiplier: 1/2),
                                     titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 20)])
        
        NSLayoutConstraint.activate([closeBtn.widthAnchor.constraint(equalToConstant: 30),
                                     closeBtn.heightAnchor.constraint(equalToConstant: 30),
                                     closeBtn.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -10),
                                     closeBtn.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 10)])
        
        NSLayoutConstraint.activate([donationAmountTitle.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 20),
                                     donationAmountTitle.widthAnchor.constraint(equalTo: self.containerView.widthAnchor, multiplier: 1/2),
                                     donationAmountTitle.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 20)])
        
        NSLayoutConstraint.activate([donationAmountValue.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -20),
                                     donationAmountValue.widthAnchor.constraint(equalTo: self.containerView.widthAnchor, multiplier: 1/2),
                                     donationAmountValue.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 20)])
        
        NSLayoutConstraint.activate([processingFeeTitle.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 20),
                                     processingFeeTitle.widthAnchor.constraint(equalTo: self.containerView.widthAnchor, multiplier: 1/2),
                                     processingFeeTitle.topAnchor.constraint(equalTo: self.donationAmountTitle.bottomAnchor, constant: 20)])
        
        NSLayoutConstraint.activate([processingFeeValue.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -20),
                                     processingFeeValue.widthAnchor.constraint(equalTo: self.containerView.widthAnchor, multiplier: 1/2),
                                     processingFeeValue.topAnchor.constraint(equalTo: self.donationAmountValue.bottomAnchor, constant: 20)])
        
        NSLayoutConstraint.activate([merchantChargesTitle.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 20),
                                     merchantChargesTitle.widthAnchor.constraint(equalTo: self.containerView.widthAnchor, multiplier: 1/2),
                                     merchantChargesTitle.topAnchor.constraint(equalTo: self.processingFeeTitle.bottomAnchor, constant: 20)])
        
        NSLayoutConstraint.activate([merchantChargesValue.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -20),
                                     merchantChargesValue.widthAnchor.constraint(equalTo: self.containerView.widthAnchor, multiplier: 1/2),
                                     merchantChargesValue.topAnchor.constraint(equalTo: self.processingFeeValue.bottomAnchor, constant: 20)])
        
        NSLayoutConstraint.activate([seperatorLable.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 10),
                                     seperatorLable.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -10),
                                     seperatorLable.heightAnchor.constraint(equalToConstant: 1),
                                     seperatorLable.topAnchor.constraint(equalTo: self.merchantChargesTitle.bottomAnchor, constant: 10)])
        
        NSLayoutConstraint.activate([totalAmountTitle.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 20),
                                     totalAmountTitle.widthAnchor.constraint(equalTo: self.containerView.widthAnchor, multiplier: 1/2),
                                     totalAmountTitle.topAnchor.constraint(equalTo: self.seperatorLable.bottomAnchor, constant: 20)])

        NSLayoutConstraint.activate([totalAmountValue.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -20),
                                     totalAmountValue.widthAnchor.constraint(equalTo: self.containerView.widthAnchor, multiplier: 1/2),
                                     totalAmountValue.topAnchor.constraint(equalTo: self.seperatorLable.bottomAnchor, constant: 20)])
        
    }
}

//
//  RatingControl.swift
//  MyPlaces
//
//  Created by Pavel on 6/10/19.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {

    // MARK: - Properties

    var rating = 0 {
        didSet { updateButtonSelectionState() }
    }
    var updateOnTouch = true
    private var ratingButtons = [UIButton]()

    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {  setupButtons() } }
    @IBInspectable var starCount: Int = 5 {
        didSet  { setupButtons() } }

    // MARK: - Initialisation

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }

    // MARK: Button Action

    @objc func ratingButtonTapped(button: UIButton) {
        guard let index = ratingButtons.firstIndex(of: button), updateOnTouch else { return }

        // Calculate rating of the selected button
        let selectedRating =  index + 1

        if selectedRating == rating { rating = 0 } else { rating = selectedRating }
    }

    // MARK: - Private Methods

    private func setupButtons() {

        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()

        // Load button images

        let bundle = Bundle(for: type(of: self))
        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let highligtStar  = UIImage(named: "highlightStar", in: bundle, compatibleWith: self.traitCollection)


        for _ in 0 ..< starCount {

            //  Create the button
            let button = UIButton()

            // Set the button images
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highligtStar, for: .highlighted)
            button.setImage(highligtStar, for: [.highlighted, .selected])

            //  Add constraints
            button.translatesAutoresizingMaskIntoConstraints  =  false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true

            //  Setup the button action
            button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)

            //  Add the button to stack
            addArrangedSubview(button)

            //  Add the new button on the rating button array
            ratingButtons.append(button)

        }
        updateButtonSelectionState()

    }

    private func updateButtonSelectionState() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }

}

import UIKit

struct FinishSheetRenderer {
    
    static func renderPatternPreview(pattern: CrochetPattern) -> UIImage {
        let size = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { ctx in
            let cgCtx = ctx.cgContext
            let cols = pattern.width
            let rows = pattern.height
            guard cols > 0, rows > 0 else { return }
            
            let cellSize = min(size.width / CGFloat(cols), size.height / CGFloat(rows))
            let totalW = cellSize * CGFloat(cols)
            let totalH = cellSize * CGFloat(rows)
            let ox = (size.width - totalW) / 2
            let oy = (size.height - totalH) / 2
            
            for row in 0..<rows {
                for col in 0..<cols {
                    let idx = pattern.grid[row][col]
                    let safeIdx = max(0, min(idx, pattern.palette.count - 1))
                    let rect = CGRect(
                        x: ox + CGFloat(col) * cellSize,
                        y: oy + CGFloat(row) * cellSize,
                        width: cellSize, height: cellSize
                    )
                    cgCtx.setFillColor(pattern.palette[safeIdx].cgColor)
                    cgCtx.fill(rect)
                }
            }
        }
    }
    
    static func renderJournalFinishSheet(
        projectName: String,
        madeBy: String,
        journalNote: String,
        startDate: Date,
        completionDate: Date,
        finishedImage: UIImage,
        patternPreview: UIImage
    ) -> UIImage {
        let sheetWidth: CGFloat = 1200
        let sheetHeight: CGFloat = 800
        let sheetSize = CGSize(width: sheetWidth, height: sheetHeight)
        let renderer = UIGraphicsImageRenderer(size: sheetSize)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let cardPadding: CGFloat = 28
        let cardCornerRadius: CGFloat = 30
        let innerPadding: CGFloat = 24
        
        let leftSideWidth: CGFloat = (sheetWidth - cardPadding * 2) * 0.55
        let rightSideWidth: CGFloat = (sheetWidth - cardPadding * 2) * 0.45
        let cardHeight = sheetHeight - cardPadding * 2
        
        return renderer.image { ctx in
            let cgCtx = ctx.cgContext
            
            UIColor(red: 255/255, green: 250/255, blue: 245/255, alpha: 1).setFill()
            cgCtx.fill(CGRect(origin: .zero, size: sheetSize))
            
            let cardRect = CGRect(
                x: cardPadding,
                y: cardPadding,
                width: sheetWidth - cardPadding * 2,
                height: cardHeight
            )
            
            cgCtx.setShadow(offset: CGSize(width: 0, height: 8), blur: 25, color: UIColor.black.withAlphaComponent(0.08).cgColor)
            
            let cardPath = UIBezierPath(roundedRect: cardRect, cornerRadius: cardCornerRadius)
            UIColor(red: 255/255, green: 252/255, blue: 248/255, alpha: 1).setFill()
            cardPath.fill()
            
            cgCtx.setShadow(offset: .zero, blur: 0)
            
            UIColor(red: 219/255, green: 178/255, blue: 167/255, alpha: 0.25).setStroke()
            cardPath.lineWidth = 2
            cardPath.stroke()
            
            let dividerX = cardPadding + leftSideWidth
            let dividerPath = UIBezierPath()
            dividerPath.move(to: CGPoint(x: dividerX, y: cardPadding + 40))
            dividerPath.addLine(to: CGPoint(x: dividerX, y: cardPadding + cardHeight - 40))
            UIColor(red: 200/255, green: 180/255, blue: 170/255, alpha: 0.2).setStroke()
            dividerPath.lineWidth = 1.5
            dividerPath.stroke()
            
            let leftX = cardPadding + innerPadding
            let leftContentWidth = leftSideWidth - innerPadding * 2
            var leftY: CGFloat = cardPadding + innerPadding
            
            let projectNameAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .bold),
                .foregroundColor: UIColor(red: 74/255, green: 68/255, blue: 63/255, alpha: 1)
            ]
            let projectNameSize = projectName.size(withAttributes: projectNameAttrs)
            let projectNameX = leftX + (leftContentWidth - projectNameSize.width) / 2
            projectName.draw(at: CGPoint(x: projectNameX, y: leftY), withAttributes: projectNameAttrs)
            leftY += projectNameSize.height + 8
            
            let dateAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 13, weight: .regular),
                .foregroundColor: UIColor(red: 142/255, green: 132/255, blue: 125/255, alpha: 1)
            ]
            let startText = "Started: \(dateFormatter.string(from: startDate))"
            let completedText = "Completed: \(dateFormatter.string(from: completionDate))"
            let dateText = "\(startText)  •  \(completedText)"
            let dateTextSize = dateText.size(withAttributes: dateAttrs)
            let dateTextX = leftX + (leftContentWidth - dateTextSize.width) / 2
            dateText.draw(at: CGPoint(x: dateTextX, y: leftY), withAttributes: dateAttrs)
            leftY += dateTextSize.height + 20
            
            let bottomReserved: CGFloat = 100
            let imageAvailableHeight = cardHeight - (leftY - cardPadding) - bottomReserved - innerPadding
            let imageAvailableWidth = leftContentWidth
            
            let imageAspect = finishedImage.size.width / finishedImage.size.height
            var imageWidth = imageAvailableWidth
            var imageHeight = imageWidth / imageAspect
            
            if imageHeight > imageAvailableHeight {
                imageHeight = imageAvailableHeight
                imageWidth = imageHeight * imageAspect
            }
            
            let imageX = leftX + (leftContentWidth - imageWidth) / 2
            let imageRect = CGRect(x: imageX, y: leftY, width: imageWidth, height: imageHeight)
            
            cgCtx.setShadow(offset: CGSize(width: 0, height: 6), blur: 20, color: UIColor.black.withAlphaComponent(0.12).cgColor)
            let imageBgPath = UIBezierPath(roundedRect: imageRect.insetBy(dx: -4, dy: -4), cornerRadius: 24)
            UIColor.white.setFill()
            imageBgPath.fill()
            cgCtx.setShadow(offset: .zero, blur: 0)
            
            cgCtx.saveGState()
            let imageClipPath = UIBezierPath(roundedRect: imageRect, cornerRadius: 22)
            imageClipPath.addClip()
            finishedImage.draw(in: imageRect)
            cgCtx.restoreGState()
            
            let bottomY = cardPadding + cardHeight - innerPadding - 70
            
            if let logoImage = UIImage(named: "PixieWelcome") {
                let logoHeight: CGFloat = 100
                let logoWidth = logoHeight * (logoImage.size.width / logoImage.size.height)
                let logoRect = CGRect(x: leftX, y: bottomY - 15, width: logoWidth, height: logoHeight)
                
                cgCtx.saveGState()
                cgCtx.setAlpha(0.7)
                logoImage.draw(in: logoRect)
                cgCtx.restoreGState()
            }
            
            let previewSize: CGFloat = 90
            let previewX = leftX + leftContentWidth - previewSize
            let previewRect = CGRect(x: previewX, y: bottomY - 10, width: previewSize, height: previewSize)
            
            cgCtx.setShadow(offset: CGSize(width: 0, height: 3), blur: 8, color: UIColor.black.withAlphaComponent(0.1).cgColor)
            let previewBgPath = UIBezierPath(roundedRect: previewRect.insetBy(dx: -3, dy: -3), cornerRadius: 18)
            UIColor.white.setFill()
            previewBgPath.fill()
            cgCtx.setShadow(offset: .zero, blur: 0)
            
            cgCtx.saveGState()
            let previewClipPath = UIBezierPath(roundedRect: previewRect, cornerRadius: 16)
            previewClipPath.addClip()
            patternPreview.draw(in: previewRect)
            cgCtx.restoreGState()
            
            let rightX = dividerX + innerPadding
            let rightContentWidth = rightSideWidth - innerPadding * 2
            var rightY: CGFloat = cardPadding + innerPadding + 10
            
            let journalHeaderAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .foregroundColor: UIColor(red: 180/255, green: 160/255, blue: 150/255, alpha: 1)
            ]
            "Note".draw(at: CGPoint(x: rightX, y: rightY), withAttributes: journalHeaderAttrs)
            rightY += 30
            
            let headerLinePath = UIBezierPath()
            headerLinePath.move(to: CGPoint(x: rightX, y: rightY))
            headerLinePath.addLine(to: CGPoint(x: rightX + 100, y: rightY))
            UIColor(red: 219/255, green: 178/255, blue: 167/255, alpha: 0.4).setStroke()
            headerLinePath.lineWidth = 1.5
            headerLinePath.stroke()
            rightY += 25
            
            let noteFont = UIFont.systemFont(ofSize: 17, weight: .regular)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 8
            paragraphStyle.alignment = .left
            
            let noteAttrs: [NSAttributedString.Key: Any] = [
                .font: noteFont,
                .foregroundColor: UIColor(red: 74/255, green: 68/255, blue: 63/255, alpha: 0.9),
                .paragraphStyle: paragraphStyle
            ]
            
            let noteText = journalNote.isEmpty ? "A handmade treasure, crafted with love and care." : journalNote
            let noteMaxWidth = rightContentWidth - 10
            let noteMaxHeight: CGFloat = cardHeight - 180
            let noteRect = CGRect(x: rightX, y: rightY, width: noteMaxWidth, height: noteMaxHeight)
            
            let noteAttributedString = NSAttributedString(string: noteText, attributes: noteAttrs)
            noteAttributedString.draw(with: noteRect, options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine], context: nil)
            
            let signatureName = madeBy.isEmpty ? "Anonymous" : madeBy
            let signatureText = "~ \(signatureName)"
            
            let signatureFont: UIFont
            if let italicDescriptor = UIFont.systemFont(ofSize: 20, weight: .medium).fontDescriptor.withSymbolicTraits(.traitItalic) {
                signatureFont = UIFont(descriptor: italicDescriptor, size: 20)
            } else {
                signatureFont = UIFont.systemFont(ofSize: 20, weight: .medium)
            }
            
            let signatureAttrs: [NSAttributedString.Key: Any] = [
                .font: signatureFont,
                .foregroundColor: UIColor(red: 100/255, green: 85/255, blue: 78/255, alpha: 0.9)
            ]
            
            let signatureSize = signatureText.size(withAttributes: signatureAttrs)
            let signatureX = rightX + rightContentWidth - signatureSize.width - 10
            let signatureY = cardPadding + cardHeight - innerPadding - signatureSize.height - 20
            
            signatureText.draw(at: CGPoint(x: signatureX, y: signatureY), withAttributes: signatureAttrs)
            
            let flourishPath = UIBezierPath()
            flourishPath.move(to: CGPoint(x: signatureX - 20, y: signatureY + signatureSize.height + 8))
            flourishPath.addQuadCurve(
                to: CGPoint(x: signatureX + signatureSize.width + 20, y: signatureY + signatureSize.height + 8),
                controlPoint: CGPoint(x: signatureX + signatureSize.width / 2, y: signatureY + signatureSize.height + 18)
            )
            UIColor(red: 219/255, green: 178/255, blue: 167/255, alpha: 0.3).setStroke()
            flourishPath.lineWidth = 1.5
            flourishPath.stroke()
        }
    }
}

import UIKit

struct CompletedCraft: Identifiable, Codable {
    let id: UUID
    let patternId: UUID
    let patternName: String
    let projectName: String
    let madeBy: String
    let startDate: Date
    let completionDate: Date
    let createdAt: Date
    
    var journalNote: String
    let finishedImageData: Data
    let patternPreviewData: Data
    let finishSheetData: Data
    var finishedImage: UIImage? {
        UIImage(data: finishedImageData)
    }
    var patternPreview: UIImage? {
        UIImage(data: patternPreviewData)
    }
    var finishSheet: UIImage? {
        UIImage(data: finishSheetData)
    }
    
    init(
        id: UUID = UUID(),
        patternId: UUID,
        patternName: String,
        projectName: String,
        madeBy: String,
        startDate: Date,
        completionDate: Date,
        journalNote: String,
        finishedImageData: Data,
        patternPreviewData: Data,
        finishSheetData: Data,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.patternId = patternId
        self.patternName = patternName
        self.projectName = projectName
        self.madeBy = madeBy
        self.startDate = startDate
        self.completionDate = completionDate
        self.journalNote = journalNote
        self.finishedImageData = finishedImageData
        self.patternPreviewData = patternPreviewData
        self.finishSheetData = finishSheetData
        self.createdAt = createdAt
    }
}

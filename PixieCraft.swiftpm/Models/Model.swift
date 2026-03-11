import SwiftUI
import Foundation

struct ColorData: Identifiable, Equatable, Codable, Hashable {
    var id = UUID()
    var r: Double  
    var g: Double
    var b: Double
    var color: Color {
        Color(red: r / 255, green: g / 255, blue: b / 255)
    }

    var hex: String {
        String(format: "#%02X%02X%02X", Int(r), Int(g), Int(b))
    }

    var cgColor: CGColor {
        CGColor(red: r / 255, green: g / 255, blue: b / 255, alpha: 1)
    }
    
    func distance(to other: ColorData) -> Double {
        let dr = r - other.r
        let dg = g - other.g
        let db = b - other.b
        return (dr * dr + dg * dg + db * db).squareRoot()
    }
    
    static func == (lhs: ColorData, rhs: ColorData) -> Bool {
        lhs.r == rhs.r && lhs.g == rhs.g && lhs.b == rhs.b
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(r)
        hasher.combine(g)
        hasher.combine(b)
    }
    
    enum CodingKeys: String, CodingKey {
        case r, g, b
    }
    
    init(r: Double, g: Double, b: Double) {
        self.id = UUID()
        self.r = r
        self.g = g
        self.b = b
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.r = try c.decode(Double.self, forKey: .r)
        self.g = try c.decode(Double.self, forKey: .g)
        self.b = try c.decode(Double.self, forKey: .b)
    }
    
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(r, forKey: .r)
        try c.encode(g, forKey: .g)
        try c.encode(b, forKey: .b)
    }
}


struct GuidedProgressState: Codable, Equatable, Hashable {
    var completedRows: Set<Int>
    var currentRow: Int
    var totalRows: Int
    
    var progressPercentage: Double {
        guard totalRows > 0 else { return 0 }
        return (Double(completedRows.count) / Double(totalRows)) * 100
    }
    
    var progressFraction: Double {
        guard totalRows > 0 else { return 0 }
        return Double(completedRows.count) / Double(totalRows)
    }
    
    var isComplete: Bool {
        completedRows.count >= totalRows
    }
    
    init(totalRows: Int) {
        self.completedRows = []
        self.currentRow = 1
        self.totalRows = max(1, totalRows)
    }
    
    init(completedRows: Set<Int>, currentRow: Int, totalRows: Int) {
        let safeTotalRows = max(1, totalRows)
        self.totalRows = safeTotalRows
        self.completedRows = completedRows.filter { $0 >= 1 && $0 <= safeTotalRows }
        self.currentRow = max(1, min(currentRow, safeTotalRows))
    }
    
    mutating func markRowComplete(_ rowNumber: Int) {
        guard rowNumber >= 1 && rowNumber <= totalRows else { return }
        completedRows.insert(rowNumber)
        recalculateCurrentRow()
    }
    
    mutating func recalculateCurrentRow() {
        for row in 1...totalRows {
            if !completedRows.contains(row) {
                currentRow = row
                return
            }
        }
        currentRow = totalRows
    }
    
    mutating func validateAndCorrect() {
        completedRows = completedRows.filter { $0 >= 1 && $0 <= totalRows }
        recalculateCurrentRow()
    }
}

struct CrochetPattern: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var grid: [[Int]]       // Row-major; each Int = palette index
    var palette: [ColorData]
    var createdDate: Date
    
    
    var lastMarkedRow: Int?
    var lastMarkedColumn: Int?
    var isInProgress: Bool { lastMarkedRow != nil && lastMarkedColumn != nil }
    
    
    var guidedProgress: GuidedProgressState?
    
    var guidedProgressOrNew: GuidedProgressState {
        guidedProgress ?? GuidedProgressState(totalRows: height)
    }
    
    var hasGuidedProgress: Bool {
        guidedProgress != nil && (guidedProgress!.completedRows.count > 0 || guidedProgress!.currentRow > 1)
    }
    
    var width: Int {
        grid.first?.count ?? 0
    }
    
    var height: Int {
        grid.count
    }
    
    var totalStitches: Int {
        width * height
    }
    
    var estimatedHours: Double {
        let raw = Double(totalStitches) / 400.0
        return (raw * 2).rounded() / 2   // round to 0.5
    }
    
    var estimatedTimeText: String {
        let hours = estimatedHours
        if hours < 1 {
            return "About 30 minutes 🧶"
        }
        let low = hours
        let high = hours + 1
        let fmt = { (v: Double) -> String in
            v.truncatingRemainder(dividingBy: 1) == 0
            ? "\(Int(v))"
            : String(format: "%.1f", v)
        }
        return "About \(fmt(low))–\(fmt(high)) hours 🧶"
    }
    
    var sizeText: String {
        "\(width) × \(height) stitches"
    }
    
    
    init(id: UUID = UUID(), name: String, grid: [[Int]], palette: [ColorData], createdDate: Date = Date(), lastMarkedRow: Int? = nil, lastMarkedColumn: Int? = nil, guidedProgress: GuidedProgressState? = nil) {
        self.id = id
        self.name = name
        self.grid = grid
        self.palette = palette
        self.createdDate = createdDate
        self.lastMarkedRow = lastMarkedRow
        self.lastMarkedColumn = lastMarkedColumn
        self.guidedProgress = guidedProgress
    }
}

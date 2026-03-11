import SwiftUI

struct ColorNamer {
    
    
    private static let knownColors: [String: String] = [
        "#FFFFFF": "Pure White",
        "#FFFAFA": "Snow White",
        "#FFF8F0": "Soft Ivory",
        "#FAF0E6": "Linen White",
        "#FDF5E6": "Old Lace",
        "#FAEBD7": "Antique White",
        "#F5F5DC": "Beige",
        "#DCD6D3": "Soft Cream",
        "#D3D3D3": "Light Gray",
        "#C0C0C0": "Silver",
        "#A9A9A9": "Dark Gray",
        "#808080": "Gray",
        "#696969": "Dim Gray",
        "#404040": "Charcoal",
        "#2F2F2F": "Dark Charcoal",
        "#1A1A1A": "Near Black",
        "#000000": "Black",
        
        "#FFC0CB": "Pink",
        "#FFB6C1": "Light Pink",
        "#FF69B4": "Hot Pink",
        "#FF1493": "Deep Pink",
        "#DB7093": "Pale Violet Red",
        "#F3EEED": "Light Blush",
        "#E8D5D5": "Dusty Rose",
        "#D4A5A5": "Rose Tan",
        "#C48080": "Muted Rose",
        "#BC8F8F": "Rosy Brown",
        
        "#FF0000": "Red",
        "#DC143C": "Crimson",
        "#B22222": "Firebrick",
        "#CD5C5C": "Indian Red",
        "#8B0000": "Dark Red",
        "#800000": "Maroon",
        "#A52A2A": "Brown Red",
        
        "#FFA500": "Orange",
        "#FF8C00": "Dark Orange",
        "#FF7F50": "Coral",
        "#FF6347": "Tomato",
        "#E9967A": "Dark Salmon",
        "#FA8072": "Salmon",
        "#F08080": "Light Coral",
        "#E9AF4C": "Warm Honey",
        "#D2691E": "Chocolate",
        "#CD853F": "Peru",
        
        "#60392D": "Cocoa Brown",
        "#8B4513": "Saddle Brown",
        "#A0522D": "Sienna",
        "#6B4423": "Warm Brown",
        "#5C4033": "Dark Brown",
        "#3D2B1F": "Deep Brown",
        "#4A3728": "Coffee Brown",
        "#7B3F00": "Rust Brown",
        "#964B00": "Brown",
        "#C4A484": "Tan",
        "#D2B48C": "Light Tan",
        "#DEB887": "Burlywood",
        "#F5DEB3": "Wheat",
        
        "#FFFF00": "Yellow",
        "#FFD700": "Gold",
        "#FFC107": "Amber",
        "#EDC75E": "Soft Gold",
        "#F0E68C": "Khaki",
        "#EEE8AA": "Pale Goldenrod",
        "#BDB76B": "Dark Khaki",
        "#FAFAD2": "Light Goldenrod",
        "#FFFACD": "Lemon Chiffon",
        "#FFEFD5": "Papaya Whip",
        "#FFE4B5": "Moccasin",
        "#FFEBCD": "Blanched Almond",
        
        "#00FF00": "Lime",
        "#32CD32": "Lime Green",
        "#90EE90": "Light Green",
        "#98FB98": "Pale Green",
        "#00FA9A": "Medium Spring Green",
        "#00FF7F": "Spring Green",
        "#3CB371": "Medium Sea Green",
        "#2E8B57": "Sea Green",
        "#228B22": "Forest Green",
        "#006400": "Dark Green",
        "#008000": "Green",
        "#6B8E23": "Olive Drab",
        "#556B2F": "Dark Olive Green",
        "#808000": "Olive",
        "#9ACD32": "Yellow Green",
        "#ADFF2F": "Green Yellow",
        "#7CFC00": "Lawn Green",
        "#8FBC8F": "Dark Sea Green",
        "#66CDAA": "Medium Aquamarine",
        "#20B2AA": "Light Sea Green",
        
        "#00FFFF": "Cyan",
        "#00CED1": "Dark Turquoise",
        "#40E0D0": "Turquoise",
        "#48D1CC": "Medium Turquoise",
        "#AFEEEE": "Pale Turquoise",
        "#7FFFD4": "Aquamarine",
        "#5F9EA0": "Cadet Blue",
        "#008B8B": "Dark Cyan",
        "#008080": "Teal",
        
        "#0000FF": "Blue",
        "#0000CD": "Medium Blue",
        "#00008B": "Dark Blue",
        "#000080": "Navy",
        "#191970": "Midnight Blue",
        "#4169E1": "Royal Blue",
        "#4682B4": "Steel Blue",
        "#1E90FF": "Dodger Blue",
        "#6495ED": "Cornflower Blue",
        "#00BFFF": "Deep Sky Blue",
        "#87CEEB": "Sky Blue",
        "#87CEFA": "Light Sky Blue",
        "#ADD8E6": "Light Blue",
        "#B0E0E6": "Powder Blue",
        "#708090": "Slate Gray",
        "#778899": "Light Slate Gray",
        "#B0C4DE": "Light Steel Blue",
        
        "#800080": "Purple",
        "#9932CC": "Dark Orchid",
        "#9400D3": "Dark Violet",
        "#8B008B": "Dark Magenta",
        "#BA55D3": "Medium Orchid",
        "#EE82EE": "Violet",
        "#DA70D6": "Orchid",
        "#DDA0DD": "Plum",
        "#D8BFD8": "Thistle",
        "#E6E6FA": "Lavender",
        "#8A2BE2": "Blue Violet",
        "#9370DB": "Medium Purple",
        "#6A5ACD": "Slate Blue",
        "#7B68EE": "Medium Slate Blue",
        "#483D8B": "Dark Slate Blue",
        "#663399": "Rebecca Purple",
        "#4B0082": "Indigo",
        
        "#FF00FF": "Magenta",
        "#C71585": "Medium Violet Red",
    ]
    
    
    static func name(forHex hex: String) -> String {
        let normalized = hex.uppercased().trimmingCharacters(in: .whitespaces)
        
        if let exactName = knownColors[normalized] {
            return exactName
        }
        
        if let rgb = hexToRGB(normalized) {
            return generateDescriptiveName(r: rgb.r, g: rgb.g, b: rgb.b)
        }
        
        return "Color"
    }
    
    static func name(r: Double, g: Double, b: Double) -> String {
        let hex = String(format: "#%02X%02X%02X", Int(r), Int(g), Int(b))
        
        if let exactName = knownColors[hex] {
            return exactName
        }
        
        return generateDescriptiveName(r: r, g: g, b: b)
    }
    
    static func name(for colorData: ColorData) -> String {
        return name(r: colorData.r, g: colorData.g, b: colorData.b)
    }
    
    
    private static func hexToRGB(_ hex: String) -> (r: Double, g: Double, b: Double)? {
        var hexString = hex
        if hexString.hasPrefix("#") {
            hexString = String(hexString.dropFirst())
        }
        guard hexString.count == 6 else { return nil }
        
        var rgbValue: UInt64 = 0
        guard Scanner(string: hexString).scanHexInt64(&rgbValue) else { return nil }
        
        return (
            r: Double((rgbValue & 0xFF0000) >> 16),
            g: Double((rgbValue & 0x00FF00) >> 8),
            b: Double(rgbValue & 0x0000FF)
        )
    }
    
    private static func generateDescriptiveName(r: Double, g: Double, b: Double) -> String {
        let (h, s, l) = rgbToHSL(r: r, g: g, b: b)
        
        if s < 0.1 {
            return grayscaleName(lightness: l)
        }
        
        var parts: [String] = []
        
        if l < 0.2 {
            parts.append("Dark")
        } else if l < 0.35 {
            parts.append("Deep")
        } else if l > 0.85 {
            parts.append("Pale")
        } else if l > 0.7 {
            parts.append("Light")
        } else if l > 0.55 {
            parts.append("Soft")
        }
        
        if s < 0.3 && l > 0.3 && l < 0.7 {
            parts.append("Muted")
        } else if s < 0.5 && s >= 0.3 {
            parts.append("Dusty")
        }
        
        parts.append(hueName(hue: h, saturation: s, lightness: l))
        
        return parts.joined(separator: " ")
    }
    
    private static func grayscaleName(lightness: Double) -> String {
        if lightness > 0.95 { return "Pure White" }
        if lightness > 0.85 { return "Off White" }
        if lightness > 0.75 { return "Light Gray" }
        if lightness > 0.55 { return "Silver Gray" }
        if lightness > 0.35 { return "Medium Gray" }
        if lightness > 0.2 { return "Dark Gray" }
        if lightness > 0.08 { return "Charcoal" }
        return "Black"
    }
    
    private static func hueName(hue: Double, saturation: Double, lightness: Double) -> String {
        switch hue {
        case 0..<15, 345..<360:
            return lightness > 0.7 ? "Pink" : "Red"
        case 15..<40:
            if lightness > 0.6 { return "Peach" }
            if lightness < 0.35 { return "Brown" }
            return "Orange"
        case 40..<55:
            if lightness < 0.4 { return "Brown" }
            return "Amber"
        case 55..<70:
            if lightness < 0.45 { return "Olive" }
            return "Yellow"
        case 70..<85:
            return "Lime"
        case 85..<150:
            return "Green"
        case 150..<175:
            return "Teal"
        case 175..<195:
            return "Cyan"
        case 195..<250:
            return "Blue"
        case 250..<285:
            return lightness > 0.6 ? "Lavender" : "Purple"
        case 285..<320:
            return lightness > 0.6 ? "Orchid" : "Violet"
        case 320..<345:
            return lightness > 0.65 ? "Pink" : "Magenta"
        default:
            return "Color"
        }
    }
    
    private static func rgbToHSL(r: Double, g: Double, b: Double) -> (h: Double, s: Double, l: Double) {
        let rNorm = r / 255.0
        let gNorm = g / 255.0
        let bNorm = b / 255.0
        
        let maxC = max(rNorm, gNorm, bNorm)
        let minC = min(rNorm, gNorm, bNorm)
        let delta = maxC - minC
        
        let l = (maxC + minC) / 2.0
        
        var s: Double = 0
        if delta > 0 {
            s = delta / (1 - abs(2 * l - 1))
        }
        
        var h: Double = 0
        if delta > 0 {
            if maxC == rNorm {
                h = 60 * (((gNorm - bNorm) / delta).truncatingRemainder(dividingBy: 6))
            } else if maxC == gNorm {
                h = 60 * (((bNorm - rNorm) / delta) + 2)
            } else {
                h = 60 * (((rNorm - gNorm) / delta) + 4)
            }
        }
        
        if h < 0 { h += 360 }
        
        return (h, min(1, max(0, s)), min(1, max(0, l)))
    }
}

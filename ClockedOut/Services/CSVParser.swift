import Foundation

final class CSVParser {
    static let shared = CSVParser()
    
    private init() {}
    
    func parse(file url: URL) throws -> [TimeEntry] {
        Logger.log("Parsing CSV file: \(url.lastPathComponent)", log: Logger.parser)
        
        guard let data = try? Data(contentsOf: url),
              let content = String(data: data, encoding: .utf8) else {
            throw ParserError.fileReadError(NSError(domain: "CSVParser", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not read file"]))
        }
        
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ParserError.emptyFile
        }
        
        let lines = content.components(separatedBy: .newlines)
        guard lines.count > 1 else {
            throw ParserError.emptyFile
        }
        
        // Parse header
        let headerLine = lines[0]
        let headers = parseCSVLine(headerLine)
        
        // Validate required columns
        // Must have "Time Tracked" and at least one of "Start" (timestamp) or "Start Text"
        guard headers.contains("Time Tracked") else {
            throw ParserError.missingColumns(["Time Tracked"])
        }
        
        guard headers.contains("Start") || headers.contains("Start Text") else {
            throw ParserError.missingColumns(["Start or Start Text"])
        }
        
        // Parse rows
        var entries: [TimeEntry] = []
        var errors: [ParserError] = []
        
        for (index, line) in lines.enumerated().dropFirst() {
            guard !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                continue
            }
            
            let values = parseCSVLine(line)
            guard values.count == headers.count else {
                Logger.error("Row \(index + 1) has incorrect number of columns", log: Logger.parser)
                continue
            }
            
            var rowDict: [String: String] = [:]
            for (idx, header) in headers.enumerated() {
                rowDict[header] = values[idx]
            }
            
            do {
                if let entry = try TimeEntry(csvRow: rowDict) {
                    try entry.validate()
                    entries.append(entry)
                }
            } catch let error as ParserError {
                errors.append(error)
                Logger.error("Failed to parse row \(index + 1)", error: error, log: Logger.parser)
            } catch {
                Logger.error("Unexpected error parsing row \(index + 1)", error: error, log: Logger.parser)
            }
        }
        
        if entries.isEmpty && !errors.isEmpty {
            throw errors.first ?? ParserError.invalidFormat("No valid entries found")
        }
        
        Logger.log("Parsed \(entries.count) time entries from CSV", log: Logger.parser)
        if !errors.isEmpty {
            Logger.log("Skipped \(errors.count) invalid rows", log: Logger.parser)
        }
        
        return entries
    }
    
    private func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var currentField = ""
        var insideQuotes = false
        
        for char in line {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                result.append(currentField.trimmingCharacters(in: .whitespacesAndNewlines))
                currentField = ""
            } else {
                currentField.append(char)
            }
        }
        
        result.append(currentField.trimmingCharacters(in: .whitespacesAndNewlines))
        return result
    }
}


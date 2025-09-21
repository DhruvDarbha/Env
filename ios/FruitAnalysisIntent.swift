import Foundation
import AppIntents

@available(iOS 16.0, *)
struct FruitAnalysisIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Fruit Ripeness"
    static var description = IntentDescription("Analyze fruit ripeness using AI")
    
    func perform() async throws -> some IntentResult {
        // Open the app with deep link to Siri fruit analysis
        let url = URL(string: "env://siri-fruit-analysis")!
        await UIApplication.shared.open(url)
        
        return .result()
    }
}
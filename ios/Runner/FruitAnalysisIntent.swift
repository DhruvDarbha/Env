import AppIntents
import Foundation

@available(iOS 16.0, *)
struct FruitAnalysisIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Fruit Ripeness"
    static var description = IntentDescription("Analyze fruit ripeness using AI-powered computer vision")

    static var parameterSummary: some ParameterSummary {
        Summary("Check if this fruit is ripe")
    }

    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        // Create URL to launch the app with the Siri deep link
        let url = URL(string: "env://siri-fruit-analysis")!

        // Open the app with the deep link
        await UIApplication.shared.open(url)

        return .result(dialog: "Opening .env to analyze your fruit...")
    }
}

@available(iOS 16.0, *)
struct EnvAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: FruitAnalysisIntent(),
            phrases: [
                "Check fruit ripeness with \(.applicationName)",
                "Ask \(.applicationName) to check if this fruit is ripe",
                "Analyze fruit with \(.applicationName)",
                "Check if my fruit is ripe using \(.applicationName)"
            ],
            shortTitle: "Check Ripeness",
            systemImageName: "camera.fill"
        )
    }
}
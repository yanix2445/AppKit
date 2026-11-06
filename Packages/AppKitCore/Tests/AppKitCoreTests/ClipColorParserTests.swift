import AppKitCore
import Testing

struct ClipColorParserTests {
    @Test(arguments: ["#FF5733", "#ff5733", "  #FF5733\n", "rgb(255, 87, 51)", "rgb(255 87 51)", "rgba(255, 87, 51, 1)", "hsl(11, 100%, 60%)"])
    func recognizesAColor(text: String) throws {
        let color = try #require(ClipColorParser.color(in: text))
        #expect(abs(color.red - 1) < 0.01)
        #expect(abs(color.green - 87.0 / 255) < 0.02)
        #expect(abs(color.blue - 51.0 / 255) < 0.02)
    }

    @Test func keepsTheTextAsItWasWritten() throws {
        #expect(try #require(ClipColorParser.color(in: "  #FF5733\n")).text == "  #FF5733\n")
    }

    @Test func readsTheShortFormAndTheAlpha() throws {
        let color = try #require(ClipColorParser.color(in: "#F00"))
        #expect(color.red == 1 && color.green == 0)
        #expect(try #require(ClipColorParser.color(in: "rgba(0, 0, 0, 0.5)")).alpha == 0.5)
    }

    @Test(arguments: ["bonjour", "#GGGGGG", "#12", "#12345", "rgb(300, 0, 0)", "rgb(1, 2)", "le #FF5733 est joli", "rgb(1, 2, 3) et plus", ""])
    func refusesWhatIsNotOnlyAColor(text: String) {
        #expect(ClipColorParser.color(in: text) == nil)
    }

    @Test func aColorWithoutTextReadsAsHex() {
        #expect(ClipColor(red: 0x3B / 255.0, green: 0x82 / 255.0, blue: 0xF6 / 255.0).text == "#3B82F6")
    }
}

import XCTest
@testable import Sdifft
#if os(OSX)
import AppKit
typealias Color = NSColor
#elseif os(iOS)
import UIKit
typealias Color = UIColor
#endif

extension CGColor: CustomStringConvertible {
    public var description: String {
        let comps: [CGFloat] = components ?? [0, 0, 0, 0]
        if comps == [1, 0, 0, 1] {
            return "{red}"
        } else if comps == [0, 1, 0, 1] {
            return "{green}"
        } else {
            return "{black}"
        }
    }
}

extension NSAttributedString {
    // swiftlint:disable line_length
    open override var description: String {
        var description = ""
        enumerateAttributes(in: NSRange(location: 0, length: string.count), options: .longestEffectiveRangeNotRequired) { (attributes, range, _) in
            let color = attributes[NSAttributedString.Key.backgroundColor] as? Color ?? Color.black
            description += string[range.location...range.location + range.length - 1] + color.cgColor.description
        }
        return description
    }
}

class NSAttributedStringDiffTests: XCTestCase {
    // swiftlint:disable line_length
    func testAttributedString() {
        let diffAttributes = DiffAttributes(add: [.backgroundColor: Color.green], delete: [.backgroundColor: Color.red], same: [.backgroundColor: Color.black])
        let to1 = "abcdhijk"
        let from1 = "bexj"
        let diff1 = Diff(from: from1, to: to1)
        let attributedString1 = NSAttributedString.attributedString(with: diff1, attributes: diffAttributes)
        assert(
            attributedString1.debugDescription == "a{green}b{black}cdhi{green}ex{red}j{black}k{green}"
        )
        let to2 = "bexj"
        let from2 = "abcdhijk"
        let diff2 = Diff(from: from2, to: to2)
        let attributedString2 = NSAttributedString.attributedString(with: diff2, attributes: diffAttributes)
        assert(
            attributedString2.debugDescription == "a{red}b{black}ex{green}cdhi{red}j{black}k{red}"
        )
        let to3 = ["bexj", "abc", "c"]
        let from3 = ["abcdhijk"]
        let diff3 = Diff(from: from3, to: to3)
        let attributedString3 = NSAttributedString.attributedString(with: diff3, attributes: diffAttributes)
        assert(
            attributedString3.debugDescription == "bexjabcc{green}abcdhijk{red}"
        )
        let to4 = ["bexj", "abc", "c", "abc"]
        let from4 = ["abcdhijk", "abc"]
        let diff4 = Diff(from: from4, to: to4)
        let attributedString4 = NSAttributedString.attributedString(with: diff4, attributes: diffAttributes)
        assert(
            attributedString4.debugDescription == "bexj{green}abcdhijk{red}abc{black}cabc{green}"
        )
    }

    static var allTests = [
        ("testAttributedString", testAttributedString)
    ]
}

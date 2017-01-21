import XCTest
@testable import PerfectICONV
import Foundation

class PerfectICONVTests: XCTestCase {
    func testExample() {
      do {
        let i = try Iconv()
        let bytes:[UInt8] =  [0xd6, 0xd0, 0xb9, 0xfa, 0x0a]
        guard let cn = i.utf8(buf: bytes) else {
          XCTFail("fault")
          return
        }//end guard
        print(cn)
        XCTAssertTrue(cn.hasPrefix("中国"))
      }catch(let err) {
        XCTFail("ERROR: \(err)")
      }
    }


    static var allTests : [(String, (PerfectICONVTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}

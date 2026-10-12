//
//  DateParsingAndNetworkErrorTests.swift
//  WildlifeAtlas
//
//  Created by Валерий Леонов on 08.09.2026.
//

import XCTest
@testable import WildlifeAtlas

final class DateParsingAndNetworkErrorTests: XCTestCase {
    func testParsesTimestampAndDayOnly() {
        let stamp = DateParsing.timestamp(from: "2026-07-12T20:22:14-04:00")
        let day = DateParsing.dayOnly(from: "2025-05-12")
        let zone = DateParsing.timeZone(from: "2026-07-12T20:22:14-04:00")

        XCTAssertNotNil(stamp)
        XCTAssertNotNil(day)
        XCTAssertEqual(zone?.secondsFromGMT(), -4 * 3600)
        XCTAssertEqual(DateParsing.timeZone(from: "2026-07-12T20:22:14Z")?.secondsFromGMT(), 0)
    }

    func testRoundTripTimestampStringPreservesOffset() {
        let original = "2026-07-12T20:22:14-04:00"
        let date = DateParsing.timestamp(from: original)!
        let zone = DateParsing.timeZone(from: original)
        let encoded = DateParsing.timestampString(from: date, timeZone: zone)

        XCTAssertTrue(encoded.contains("-04:00") || encoded.contains("-0400"))
    }

    func testNetworkErrorMappingFromURLError() {
        XCTAssertEqual(NetworkError(URLError(.notConnectedToInternet)), .offline)
        XCTAssertEqual(NetworkError(URLError(.timedOut)), .timedOut)
        XCTAssertEqual(NetworkError(NetworkError.rateLimited), .rateLimited)
    }

    func testNetworkErrorMessagesAreNonEmpty() {
        let errors: [NetworkError] = [
            .offline, .timedOut, .rateLimited, .notFound,
            .server(status: 500), .badRequest(status: 400), .decoding, .unknown
        ]
        for error in errors {
            XCTAssertFalse(error.title.isEmpty)
            XCTAssertFalse(error.message.isEmpty)
        }
    }
}

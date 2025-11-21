import XCTest
@testable import QRPaymentsCore

final class QRPaymentsCoreTests: XCTestCase {

    func testSPAYDGeneration() throws {
        // Test basic SPAYD generation
        let spayd = SPAYDGenerator.generate(
            prefix: "19",
            accountNumber: "2121134949",
            bankCode: "0800",
            amount: "1000.00",
            variableSymbol: nil,
            message: nil
        )

        // Should contain required fields
        XCTAssertTrue(spayd.contains("SPD*1.0"))
        XCTAssertTrue(spayd.contains("ACC:CZ"))
        XCTAssertTrue(spayd.contains("AM:1000.00"))
        XCTAssertTrue(spayd.contains("CC:CZK"))
    }

    func testIBANConversion() throws {
        // Test Czech account to IBAN conversion
        let iban = SPAYDGenerator.convertToIBAN(
            prefix: "19",
            accountNumber: "2121134949",
            bankCode: "0800"
        )

        // IBAN should start with CZ and contain bank code
        XCTAssertTrue(iban.hasPrefix("CZ"))
        XCTAssertTrue(iban.contains("0800"))
    }

    func testBankCodeValidation() throws {
        // Valid bank code
        XCTAssertTrue(Validator.isValidBankCode("0800"))
        XCTAssertTrue(Validator.isValidBankCode("0100"))

        // Invalid bank codes
        XCTAssertFalse(Validator.isValidBankCode(""))
        XCTAssertFalse(Validator.isValidBankCode("080"))
        XCTAssertFalse(Validator.isValidBankCode("08000"))
        XCTAssertFalse(Validator.isValidBankCode("abcd"))
    }

    func testAccountNumberValidation() throws {
        // Valid account numbers
        XCTAssertTrue(Validator.isValidAccountNumber("2121134949"))
        XCTAssertTrue(Validator.isValidAccountNumber("123"))

        // Invalid account numbers
        XCTAssertFalse(Validator.isValidAccountNumber(""))
        XCTAssertFalse(Validator.isValidAccountNumber("12345678901")) // Too long
        XCTAssertFalse(Validator.isValidAccountNumber("abc123"))
    }

    func testPrefixValidation() throws {
        // Valid prefixes
        XCTAssertTrue(Validator.isValidPrefix(""))  // Empty is valid
        XCTAssertTrue(Validator.isValidPrefix("19"))
        XCTAssertTrue(Validator.isValidPrefix("000019"))

        // Invalid prefixes
        XCTAssertFalse(Validator.isValidPrefix("1234567")) // Too long
        XCTAssertFalse(Validator.isValidPrefix("abc"))
    }

    func testBankAccountModel() throws {
        let account = BankAccount(
            id: UUID(),
            name: "Test Account",
            prefix: "19",
            accountNumber: "2121134949",
            bankCode: "0800"
        )

        XCTAssertEqual(account.name, "Test Account")
        XCTAssertEqual(account.formattedAccountNumber, "19-2121134949/0800")

        // Test without prefix
        let accountNoPrefix = BankAccount(
            id: UUID(),
            name: "Test Account 2",
            prefix: "",
            accountNumber: "1234567890",
            bankCode: "0100"
        )

        XCTAssertEqual(accountNoPrefix.formattedAccountNumber, "1234567890/0100")
    }
}

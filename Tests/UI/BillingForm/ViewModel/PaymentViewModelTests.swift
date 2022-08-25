import XCTest
import Checkout
@testable import Frames

class PaymentViewModelTests: XCTestCase {

    var viewModel: DefaultPaymentViewModel!
    
    func testInit() {
        let testCardValidator = CardValidator(environment: .sandbox)
        let testLogger = StubFramesEventLogger()
        let testBillingFormData = BillingForm(name: "John Doe",
                                              address: Address(addressLine1: "home", addressLine2: "sleeping", city: "rough night", state: "tired", zip: "Zzzz", country: nil),
                                              phone: Phone(number: "notAvailable", country: nil))
        let testSupportedSchemes: [Card.Scheme] = [.discover, .mada]
        let checkoutAPIService = Frames.CheckoutAPIService(publicKey: "", environment: Environment.sandbox)

        let viewModel = DefaultPaymentViewModel(checkoutAPIService: checkoutAPIService,
                                                cardValidator: testCardValidator,
                                                logger: testLogger,
                                                billingFormData: testBillingFormData,
                                                paymentFormStyle: nil,
                                                billingFormStyle: nil,
                                                supportedSchemes: testSupportedSchemes)
        
        XCTAssertTrue(viewModel.cardValidator === testCardValidator)
        XCTAssertTrue((viewModel.logger as? StubFramesEventLogger) === testLogger)
        XCTAssertEqual(viewModel.billingFormData, testBillingFormData)
        XCTAssertEqual(viewModel.supportedSchemes, testSupportedSchemes)
    }
    
    func testOnAppearSendsEventToLogger() {
        let testLogger = StubFramesEventLogger()
        let checkoutAPIService = Frames.CheckoutAPIService(publicKey: "", environment: Environment.sandbox)
        let viewModel = DefaultPaymentViewModel(checkoutAPIService: checkoutAPIService,
                                                cardValidator: CardValidator(environment: .sandbox),
                                                  logger: testLogger,
                                                  billingFormData: nil,
                                                  paymentFormStyle: nil,
                                                  billingFormStyle: nil,
                                                  supportedSchemes: [])
        
        XCTAssertTrue(testLogger.addCalledWithMetadataPairs.isEmpty)
        XCTAssertTrue(testLogger.logCalledWithFramesLogEvents.isEmpty)
        
        viewModel.viewControllerWillAppear()
        
        XCTAssertTrue(testLogger.addCalledWithMetadataPairs.isEmpty)
        XCTAssertEqual(testLogger.logCalledWithFramesLogEvents.count, 1)
        XCTAssertEqual(testLogger.logCalledWithFramesLogEvents.first, .paymentFormPresented)
    }
    
    func testOnBillingScreenShownSendsEventToLogger() {
        let testLogger = StubFramesEventLogger()
        let checkoutAPIService = Frames.CheckoutAPIService(publicKey: "", environment: Environment.sandbox)
        let viewModel = DefaultPaymentViewModel(checkoutAPIService: checkoutAPIService,
                                                cardValidator: CardValidator(environment: .sandbox),
                                                  logger: testLogger,
                                                  billingFormData: nil,
                                                  paymentFormStyle: nil,
                                                  billingFormStyle: nil,
                                                  supportedSchemes: [])
        
        XCTAssertTrue(testLogger.addCalledWithMetadataPairs.isEmpty)
        XCTAssertTrue(testLogger.logCalledWithFramesLogEvents.isEmpty)
        
        viewModel.onBillingScreenShown()
        
        XCTAssertTrue(testLogger.addCalledWithMetadataPairs.isEmpty)
        XCTAssertEqual(testLogger.logCalledWithFramesLogEvents.count, 1)
        XCTAssertEqual(testLogger.logCalledWithFramesLogEvents.first, .billingFormPresented)
    }

  func testUpdateExpiryDateView() {
      let checkoutAPIService = Frames.CheckoutAPIService(publicKey: "", environment: Environment.sandbox)
      viewModel = DefaultPaymentViewModel(checkoutAPIService: checkoutAPIService,
                                          cardValidator: CardValidator(environment: .sandbox),
                                            logger: StubFramesEventLogger(),
                                            billingFormData: nil,
                                            paymentFormStyle: DefaultPaymentFormStyle(),
                                            billingFormStyle: DefaultBillingFormStyle(),
                                            supportedSchemes: [.unknown])

        let expectation = expectation(description: #function)
        viewModel?.updateExpiryDateView = {
            expectation.fulfill()
        }

        viewModel?.updateAll()

        waitForExpectations(timeout: 1)
    }

    func testUpdateAddBillingSummaryView() {
        let checkoutAPIService = Frames.CheckoutAPIService(publicKey: "", environment: Environment.sandbox)
        viewModel = DefaultPaymentViewModel(checkoutAPIService: checkoutAPIService,
                                            cardValidator: CardValidator(environment: .sandbox),
                                            logger: StubFramesEventLogger(),
                                            billingFormData: nil,
                                            paymentFormStyle: DefaultPaymentFormStyle(),
                                            billingFormStyle: DefaultBillingFormStyle(),
                                            supportedSchemes: [.unknown])

        let expectation = expectation(description: #function)
        viewModel?.updateAddBillingDetailsView = {
            expectation.fulfill()
        }

        viewModel?.updateAll()

        waitForExpectations(timeout: 1)
    }

    func testUpdateEditBillingSummaryView() {
        let userName = "User Custom 1"
        let address = Address(addressLine1: "Test line1 Custom 1",
                              addressLine2: nil,
                              city: "London Custom 1",
                              state: "London Custom 1",
                              zip: "N12345",
                              country: Country(iso3166Alpha2: "GB"))
        let phone = Phone(number: "77 1234 1234",
                          country: Country(iso3166Alpha2: "GB"))
        let billingFormData = BillingForm(name: userName,
                                          address: address,
                                          phone: phone)
        let checkoutAPIService = Frames.CheckoutAPIService(publicKey: "", environment: Environment.sandbox)
        viewModel = DefaultPaymentViewModel(checkoutAPIService: checkoutAPIService, cardValidator: CardValidator(environment: .sandbox),
                                            logger: StubFramesEventLogger(),
                                            billingFormData: billingFormData,
                                            paymentFormStyle: DefaultPaymentFormStyle(),
                                            billingFormStyle: DefaultBillingFormStyle(),
                                            supportedSchemes: [.unknown])

        let expectation = expectation(description: #function)
        viewModel.updateEditBillingSummaryView = {
            expectation.fulfill()
        }

        viewModel.updateAll()
        waitForExpectations(timeout: 1)
    }

    func testSummaryText() throws {
        let userName = "User Custom 1"
        let phone = Phone(number: "77 1234 1234",
                          country: Country(iso3166Alpha2: "GB"))
        let billingFormData = BillingForm(name: userName,
                                          address: nil,
                                          phone: phone)
        let checkoutAPIService = Frames.CheckoutAPIService(publicKey: "", environment: Environment.sandbox)
        viewModel = DefaultPaymentViewModel(checkoutAPIService: checkoutAPIService,
                                            cardValidator: CardValidator(environment: .sandbox),
                                              logger: StubFramesEventLogger(),
                                              billingFormData: billingFormData,
                                              paymentFormStyle: DefaultPaymentFormStyle(),
                                              billingFormStyle: DefaultBillingFormStyle(),
                                              supportedSchemes: [.unknown])

        let summaryValue = "User Custom 1\n\n77 1234 1234"
        viewModel.updateBillingSummaryView()
        let expectedSummaryText = try XCTUnwrap(viewModel.paymentFormStyle?.editBillingSummary?.summary?.text)
        XCTAssertEqual(expectedSummaryText, summaryValue)
    }

  func testSummaryTextWithEmptyValue() throws {
      let userName = "User"

    let address = Address(addressLine1: "Checkout.com",
                          addressLine2: "",
                          city: "London city",
                          state: "London County",
                          zip: "N12345",
                          country: Country(iso3166Alpha2: "GB"))

      let phone = Phone(number: "077 1234 1234",
                        country: Country(iso3166Alpha2: "GB"))
      let billingFormData = BillingForm(name: userName,
                                        address: address,
                                        phone: phone)
      let checkoutAPIService = Frames.CheckoutAPIService(publicKey: "", environment: Environment.sandbox)
      viewModel = DefaultPaymentViewModel(checkoutAPIService: checkoutAPIService, cardValidator: CardValidator(environment: .sandbox),
                                            logger: StubFramesEventLogger(),
                                            billingFormData: billingFormData,
                                            paymentFormStyle: DefaultPaymentFormStyle(),
                                            billingFormStyle: DefaultBillingFormStyle(),
                                            supportedSchemes: [.unknown])

      let summaryValue = "User\n\nCheckout.com\n\nLondon city\n\nLondon County\n\nN12345\n\nUnited Kingdom\n\n077 1234 1234"
      viewModel.updateBillingSummaryView()
      let expectedSummaryText = try XCTUnwrap(viewModel.paymentFormStyle?.editBillingSummary?.summary?.text)
      XCTAssertEqual(expectedSummaryText, summaryValue)
  }
    
    func testPreventDuplicateCardholderInput() {
        let paymentFormStyle = DefaultPaymentFormStyle()
        let billingFormStyle = DefaultBillingFormStyle()
        var viewModel = makeViewModel(paymentFormStyle: paymentFormStyle,
                                      billingFormStyle: billingFormStyle)
        
        XCTAssertNotNil(viewModel.paymentFormStyle?.cardholderInput)
        var billingName = viewModel.billingFormStyle?.cells.first(where: {
            if case BillingFormCell.fullName = $0 {
                return true
            }
            return false
        })
        XCTAssertNotNil(billingName)
        
        viewModel.preventDuplicateCardholderInput()
        XCTAssertNotNil(viewModel.paymentFormStyle?.cardholderInput)
        billingName = viewModel.billingFormStyle?.cells.first(where: {
            if case BillingFormCell.fullName = $0 {
                return true
            }
            return false
        })
        XCTAssertNil(billingName)
    }
    
    func testCardholderIsUpdatedCallbackShouldEnablePayButton() {
        let model = makeViewModel()
        let testExpectation = expectation(description: "Should trigger callback")
        model.shouldEnablePayButton = { _ in
            testExpectation.fulfill()
        }
        model.cardholderIsUpdated(value: "new owner")
        waitForExpectations(timeout: 0.1)
    }
    
    // MARK: Mandatory input validation tests
    func testNoSchemePresentFailMandatoryInput() {
        let testPaymentForm = makeBillingFormStyle()
        let model = makeViewModel(paymentFormStyle: testPaymentForm)

        let expectation = expectation(description: "Callback is expected")
        expectation.expectedFulfillmentCount = 2
        model.shouldEnablePayButton = { isMandatoryInputProvided in
            XCTAssertFalse(isMandatoryInputProvided)
            expectation.fulfill()
        }
        model.update(result: .failure(.invalidScheme))
        model.expiryDateIsUpdated(result: .success(ExpiryDate(month: 5, year: 2067)))

        waitForExpectations(timeout: 0.1)
    }
    
    func testMandatoryCardholderNotPresentFailMandatoryInput() {
        let testPaymentForm = makeBillingFormStyle(isCardholderMandatory: true)
        let model = makeViewModel(paymentFormStyle: testPaymentForm)
        
        let expectation = expectation(description: "Callback is expected")
        expectation.expectedFulfillmentCount = 2
        model.shouldEnablePayButton = { isMandatoryInputProvided in
            XCTAssertFalse(isMandatoryInputProvided)
            expectation.fulfill()
        }
        
        model.update(result: .success(("4242424242424242", .visa)))
        model.expiryDateIsUpdated(result: .success(ExpiryDate(month: 5, year: 2067)))
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testOptionalCardholderNotPresentPassesMandatoryInput() {
        var expectedCallbacks = 3
        let testPaymentForm = makeBillingFormStyle(isCardholderMandatory: false)
        let model = makeViewModel(paymentFormStyle: testPaymentForm)
        
        let expectation = expectation(description: "Callback is expected")
        expectation.expectedFulfillmentCount = expectedCallbacks
        model.shouldEnablePayButton = { isMandatoryInputProvided in
            expectedCallbacks -= 1
            // On the last call we expect that all mandatory inputs were provided
            if expectedCallbacks == 0 {
                XCTAssertTrue(isMandatoryInputProvided)
            } else {
                XCTAssertFalse(isMandatoryInputProvided)
            }
            expectation.fulfill()
        }
        
        model.expiryDateIsUpdated(result: .success(ExpiryDate(month: 5, year: 2067)))
        model.securityCodeIsUpdated(result: .success("123"))
        model.update(result: .success(("4242424242424242", .visa)))
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testMissingCardholderPassesMandatoryInput() {
        var expectedCallbacks = 3
        var testPaymentForm = makeBillingFormStyle(isCardholderMandatory: true)
        testPaymentForm.cardholderInput = nil
        let model = makeViewModel(paymentFormStyle: testPaymentForm)
        
        let expectation = expectation(description: "Callback is expected")
        expectation.expectedFulfillmentCount = expectedCallbacks
        model.shouldEnablePayButton = { isMandatoryInputProvided in
            expectedCallbacks -= 1
            // On the last call we expect that all mandatory inputs were provided
            if expectedCallbacks == 0 {
                XCTAssertTrue(isMandatoryInputProvided)
            } else {
                XCTAssertFalse(isMandatoryInputProvided)
            }
            expectation.fulfill()
        }
        
        model.expiryDateIsUpdated(result: .success(ExpiryDate(month: 5, year: 2067)))
        model.securityCodeIsUpdated(result: .success("123"))
        model.update(result: .success(("4242424242424242", .visa)))
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testMandatorySecurityCodeNotPresentFailMandatoryInput() {
        let testPaymentForm = makeBillingFormStyle(isSecurityCodeMandatory: true)
        let model = makeViewModel(paymentFormStyle: testPaymentForm)
        
        let expectation = expectation(description: "Callback is expected")
        expectation.expectedFulfillmentCount = 2
        model.shouldEnablePayButton = { isMandatoryInputProvided in
            XCTAssertFalse(isMandatoryInputProvided)
            expectation.fulfill()
        }
        
        model.update(result: .success(("4242424242424242", .visa)))
        model.expiryDateIsUpdated(result: .success(ExpiryDate(month: 5, year: 2067)))
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testOptionalSecurityCodeNotPresentFailsMandatoryInput() {
        // Business requirements specifically asked that Security Code has specific behaviour
        // If shown it is mandatory, making it optional will have no effect in requiring it
        let testPaymentForm = makeBillingFormStyle(isSecurityCodeMandatory: true)
        let model = makeViewModel(paymentFormStyle: testPaymentForm)
        
        let expectation = expectation(description: "Callback is expected")
        expectation.expectedFulfillmentCount = 2
        model.shouldEnablePayButton = { isMandatoryInputProvided in
            XCTAssertFalse(isMandatoryInputProvided)
            expectation.fulfill()
        }
        
        model.update(result: .success(("4242424242424242", .visa)))
        model.expiryDateIsUpdated(result: .success(ExpiryDate(month: 5, year: 2067)))
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testMissingSecurityCodePassesMandatoryInput() {
        var expectedCallbacks = 2
        var testPaymentForm = makeBillingFormStyle(isSecurityCodeMandatory: true)
        testPaymentForm.securityCode = nil
        let model = makeViewModel(paymentFormStyle: testPaymentForm)
        
        let expectation = expectation(description: "Callback is expected")
        expectation.expectedFulfillmentCount = expectedCallbacks
        model.shouldEnablePayButton = { isMandatoryInputProvided in
            expectedCallbacks -= 1
            // On the last call we expect that all mandatory inputs were provided
            if expectedCallbacks == 0 {
                XCTAssertTrue(isMandatoryInputProvided)
            } else {
                XCTAssertFalse(isMandatoryInputProvided)
            }
            expectation.fulfill()
        }
        
        model.expiryDateIsUpdated(result: .success(ExpiryDate(month: 5, year: 2067)))
        model.update(result: .success(("4242424242424242", .visa)))
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testMandatoryBillingNotPresentFailMandatoryInput() {
        let testPaymentForm = makeBillingFormStyle(isBillingMandatory: true)
        let model = makeViewModel(paymentFormStyle: testPaymentForm)
        
        let expectation = expectation(description: "Callback is expected")
        expectation.expectedFulfillmentCount = 2
        model.shouldEnablePayButton = { isMandatoryInputProvided in
            XCTAssertFalse(isMandatoryInputProvided)
            expectation.fulfill()
        }
        
        model.update(result: .success(("4242424242424242", .visa)))
        model.expiryDateIsUpdated(result: .success(ExpiryDate(month: 5, year: 2067)))
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testOptionalBillingNotPresentPassesMandatoryInput() {
        var expectedCallbacks = 3
        let testPaymentForm = makeBillingFormStyle(isBillingMandatory: false)
        let model = makeViewModel(paymentFormStyle: testPaymentForm)
        
        let expectation = expectation(description: "Callback is expected")
        expectation.expectedFulfillmentCount = expectedCallbacks
        model.shouldEnablePayButton = { isMandatoryInputProvided in
            expectedCallbacks -= 1
            // On the last call we expect that all mandatory inputs were provided
            if expectedCallbacks == 0 {
                XCTAssertTrue(isMandatoryInputProvided)
            } else {
                XCTAssertFalse(isMandatoryInputProvided)
            }
            expectation.fulfill()
        }
        
        model.expiryDateIsUpdated(result: .success(ExpiryDate(month: 5, year: 2067)))
        model.update(result: .success(("4242424242424242", .visa)))
        model.securityCodeIsUpdated(result: .success("123"))
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testMissingBillingPassesMandatoryInput() {
        var expectedCallbacks = 3
        var testPaymentForm = makeBillingFormStyle(isBillingMandatory: true)
        testPaymentForm.editBillingSummary = nil
        let model = makeViewModel(paymentFormStyle: testPaymentForm)
        
        let expectation = expectation(description: "Callback is expected")
        expectation.expectedFulfillmentCount = expectedCallbacks
        model.shouldEnablePayButton = { isMandatoryInputProvided in
            expectedCallbacks -= 1
            // On the last call we expect that all mandatory inputs were provided
            if expectedCallbacks == 0 {
                XCTAssertTrue(isMandatoryInputProvided)
            } else {
                XCTAssertFalse(isMandatoryInputProvided)
            }
            expectation.fulfill()
        }
        
        model.expiryDateIsUpdated(result: .success(ExpiryDate(month: 5, year: 2067)))
        model.update(result: .success(("4242424242424242", .visa)))
        model.securityCodeIsUpdated(result: .success("123"))
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testMissingCardNumberFailMandatoryInput() {
        let testPaymentForm = makeBillingFormStyle(isCardholderMandatory: true,
                                                   isSecurityCodeMandatory: true,
                                                   isBillingMandatory: true)
        let model = makeViewModel(paymentFormStyle: testPaymentForm)
        
        let expectation = expectation(description: "Callback is expected")
        expectation.expectedFulfillmentCount = 4
        model.shouldEnablePayButton = { isMandatoryInputProvided in
            XCTAssertFalse(isMandatoryInputProvided)
            expectation.fulfill()
        }
        
        model.cardholderIsUpdated(value: "John Price")
        model.securityCodeIsUpdated(result: .success("123"))
        model.onTapDoneButton(data: makeMockBillingForm())
        model.expiryDateIsUpdated(result: .success(ExpiryDate(month: 5, year: 2067)))
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testIncompleteCardNumberFailMandatoryInput() {
        let testPaymentForm = makeBillingFormStyle(isCardholderMandatory: true,
                                                   isSecurityCodeMandatory: true,
                                                   isBillingMandatory: true)
        let model = makeViewModel(paymentFormStyle: testPaymentForm)
        
        let expectation = expectation(description: "Callback is expected")
        expectation.expectedFulfillmentCount = 5
        model.shouldEnablePayButton = { isMandatoryInputProvided in
            XCTAssertFalse(isMandatoryInputProvided)
            expectation.fulfill()
        }
        
        model.cardholderIsUpdated(value: "John Price")
        model.securityCodeIsUpdated(result: .success("123"))
        model.onTapDoneButton(data: makeMockBillingForm())
        model.expiryDateIsUpdated(result: .success(ExpiryDate(month: 5, year: 2067)))
        model.update(result: .success((cardNumber: "42424242", scheme: .visa)))
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testMissingExpiryDateFailMandatoryInput() {
        let testPaymentForm = makeBillingFormStyle(isCardholderMandatory: true,
                                                   isSecurityCodeMandatory: true,
                                                   isBillingMandatory: true)
        let model = makeViewModel(paymentFormStyle: testPaymentForm)
        
        let expectation = expectation(description: "Callback is expected")
        expectation.expectedFulfillmentCount = 4
        model.shouldEnablePayButton = { isMandatoryInputProvided in
            XCTAssertFalse(isMandatoryInputProvided)
            expectation.fulfill()
        }
        
        model.cardholderIsUpdated(value: "John Price")
        model.securityCodeIsUpdated(result: .success("123"))
        model.onTapDoneButton(data: makeMockBillingForm())
        model.update(result: .success((cardNumber: "4242424242424242", scheme: .visa)))
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testHistoricExpiryDateFailMandatoryInput() {
        let testPaymentForm = makeBillingFormStyle(isCardholderMandatory: true,
                                                   isSecurityCodeMandatory: true,
                                                   isBillingMandatory: true)
        let model = makeViewModel(paymentFormStyle: testPaymentForm)
        
        let expectation = expectation(description: "Callback is expected")
        expectation.expectedFulfillmentCount = 5
        model.shouldEnablePayButton = { isMandatoryInputProvided in
            XCTAssertFalse(isMandatoryInputProvided)
            expectation.fulfill()
        }
        
        model.cardholderIsUpdated(value: "John Price")
        model.securityCodeIsUpdated(result: .success("123"))
        model.onTapDoneButton(data: makeMockBillingForm())
        model.update(result: .success((cardNumber: "4242424242424242", scheme: .visa)))
        model.expiryDateIsUpdated(result: .success(ExpiryDate(month: 01, year: 1800)))
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testCardNumberAndExpiryDateProvidedAllOtherOptionalMissingIsValid() {
        var expectedCallbacks = 2
        var testPaymentForm = makeBillingFormStyle(isCardholderMandatory: false,
                                                   isSecurityCodeMandatory: false,
                                                   isBillingMandatory: false)
        testPaymentForm.securityCode = nil
        let model = makeViewModel(paymentFormStyle: testPaymentForm)
        
        let expectation = expectation(description: "Callback is expected")
        expectation.expectedFulfillmentCount = expectedCallbacks
        model.shouldEnablePayButton = { isMandatoryInputProvided in
            expectedCallbacks -= 1
            if expectedCallbacks == 0 {
                XCTAssertTrue(isMandatoryInputProvided)
            } else {
                XCTAssertFalse(isMandatoryInputProvided)
            }
            expectation.fulfill()
        }
        
        model.update(result: .success((cardNumber: "4242424242424242", scheme: .visa)))
        model.expiryDateIsUpdated(result: .success(ExpiryDate(month: 5, year: 2067)))
        
        waitForExpectations(timeout: 0.1)
    }
    
    func testAllFieldsRequiredAndProvided() {
        var expectedCallbacks = 6
        let testPaymentForm = makeBillingFormStyle(isCardholderMandatory: true,
                                                   isSecurityCodeMandatory: true,
                                                   isBillingMandatory: true)
        let model = makeViewModel(paymentFormStyle: testPaymentForm)
        
        let expectation = expectation(description: "Callback is expected")
        expectation.expectedFulfillmentCount = expectedCallbacks
        model.shouldEnablePayButton = { isMandatoryInputProvided in
            expectedCallbacks -= 1
            if expectedCallbacks == 0 {
                XCTAssertTrue(isMandatoryInputProvided)
            } else {
                XCTAssertFalse(isMandatoryInputProvided)
            }
            expectation.fulfill()
        }
        
        model.cardholderIsUpdated(value: "John Price")
        model.securityCodeIsUpdated(result: .success("123"))
        model.onTapDoneButton(data: makeMockBillingForm())
        model.expiryDateIsUpdated(result: .success(ExpiryDate(month: 5, year: 2067)))
        model.update(result: .success((cardNumber: "42424242", scheme: .visa)))
        model.update(result: .success((cardNumber: "4242424242424242", scheme: .visa)))
        
        waitForExpectations(timeout: 0.1)
    }
    
    private func makeViewModel(apiService: Frames.CheckoutAPIProtocol = StubCheckoutAPIService(),
                               cardValidator: CardValidator = CardValidator(environment: .sandbox),
                               logger: FramesEventLogging = StubFramesEventLogger(),
                               billingForm: BillingForm? = nil,
                               paymentFormStyle: PaymentFormStyle? = nil,
                               billingFormStyle: BillingFormStyle? = nil,
                               supportedCardSchemes: [Card.Scheme] = [.mastercard, .visa]) -> DefaultPaymentViewModel {
        DefaultPaymentViewModel(checkoutAPIService: apiService,
                                cardValidator: cardValidator,
                                logger: logger,
                                billingFormData: billingForm,
                                paymentFormStyle: paymentFormStyle,
                                billingFormStyle: billingFormStyle,
                                supportedSchemes: supportedCardSchemes)
    }
    
    private func makeMockBillingForm() -> BillingForm {
        BillingForm(name: "John", address: Address(addressLine1: "Kong Drive", addressLine2: "Blister", city: "Dreamland", state: nil, zip: "DR38ML", country: Country.allAvailable.first), phone: nil)
    }
    
    private func makeBillingFormStyle(isCardholderMandatory: Bool = false,
                                      isSecurityCodeMandatory: Bool = false,
                                      isBillingMandatory: Bool = false) -> PaymentFormStyle {
        var style = DefaultPaymentFormStyle()
        
        let cardholderInput = DefaultCardholderFormStyle(isMandatory: isCardholderMandatory)
        style.cardholderInput = cardholderInput
        
        let securityCode = DefaultSecurityCodeFormStyle(isMandatory: isSecurityCodeMandatory)
        style.securityCode = securityCode
        
        let addBillingDetails = DefaultAddBillingDetailsViewStyle(isMandatory: isBillingMandatory)
        style.addBillingSummary = addBillingDetails
        
        let billingSummary = DefaultBillingSummaryViewStyle(isMandatory: isBillingMandatory)
        style.editBillingSummary = billingSummary
        
        return style
    }
}
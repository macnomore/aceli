public class IncentiveCalculator {
  public static Map<String, Double> incentivesConstants = IncentiveCalculatorConstants.loadConstants();

  public static void calculateIncentives(Id loanId) {
    Loan__c loan = [
      SELECT
        Loan_Amount__c,
        Borrower_Status_New__c,
        Account__c,
        Impact_Points__c,
        Bonuses__c,
        Revenue__c,
        Country_New__c
      FROM Loan__c
      WHERE Id = :loanId
    ];
    List<Loan_Balance__c> balances = [
      SELECT End_of_Month_Balance__c
      FROM Loan_Balance__c
      WHERE Loan__c = :loanId
    ];

    //Get lenders incentive qualification status from Account
    Account account = [
      SELECT Id, IP_Qualified__c, FLC_Qualified__c, OI_Qualified__c
      FROM Account
      WHERE Id = :loan.Account__c
    ];

    Incentive__c incentive = new Incentive__c();
    incentive.Loan__c = loanId;

    // Check if lender qualifies for incentives
    if (account.IP_Qualified__c) {
      if (account.FLC_Qualified__c) {
        incentive.Max_FLC__c = calculateMaxFLC(loan);
      }

      if (account.OI_Qualified__c) {
        incentive.Max_OI__c = calculateMaxOI(loan);
      }

      incentive.Quarterly_Earnings__c = calculateQuarterlyEarnings(balances);

      upsert incentive;
    }
  }

  public static Decimal calculateMaxOI(Loan__c loan) {
    String constantValuesObject;

    ESG_Standard__c eSGStandard = [
      SELECT Id, Climate_Smart__c, Gender_Inclusive__c, Youth_Owned__c
      FROM ESG_Standard__c
      WHERE Account__c = :loan.Account__c
    ];

    // Initialize variables
    Decimal baseOI = 0;
    Decimal impactFactor = 0;

    // Ensure loan amount threshold is met
    if (
      loan.Loan_Amount__c == null ||
      loan.Loan_Amount__c < incentivesConstants.get('oILoanAmountThreshold')
    ) {
      return 0; // No OI for loans below the threshold
    }

    // Base OI calculation based on revenue
    if (
      loan.Revenue__c != null &&
      loan.Revenue__c >= incentivesConstants.get('oIRevenueThreshold')
    ) {
      baseOI = loan.Revenue__c * incentivesConstants.get('baseOIConstant');
    }

    // Impact points adjustment
    if (loan.Impact_Points__c != null) {
      impactFactor =
        loan.Impact_Points__c *
        incentivesConstants.get('oILoanBasImpactConstant');
    }

    // Deserialize bonuses safely
    // Map<String, Boolean> bonuses = new Map<String, Boolean>();
    // if (!String.isBlank(loan.Bonuses__c)) {
    //   try {
    //     bonuses = (Map<String, Boolean>) JSON.deserialize(
    //       loan.Bonuses__c,
    //       Map<String, Boolean>.class
    //     );
    //   } catch (Exception e) {
    //     System.debug('Failed to deserialize Bonuses__c: ' + e.getMessage());
    //   }
    // }

    // Apply bonuses
    if (eSGStandard.Youth_Owned__c) {
      baseOI += incentivesConstants.get('eSGYouthOwnedBonus');
    }
    if (eSGStandard.Climate_Smart__c) {
      baseOI += incentivesConstants.get('eSGClimateSmartBonus');
    }
    if (eSGStandard.Gender_Inclusive__c) {
      baseOI += incentivesConstants.get('eSGGenderInclusiveBonus');
    }

    // Country-specific adjustments
    if (
      !String.isBlank(loan.Country_New__c) &&
      (loan.Country_New__c.contains('Kenya') ||
      loan.Country_New__c.contains('Tanzania'))
    ) {
      baseOI *= incentivesConstants.get('countryAdjustment'); // 10% increase for specific countries
    }

    return baseOI + impactFactor;
  }

  public static Decimal calculateMaxFLC(Loan__c loan) {
    if (loan.Loan_Amount__c == null) {
      return 0; // Default to zero if no loan amount
    }

    Decimal baseFactor = incentivesConstants.get('baseFactor');
    Decimal factorIncrement = 0;

    if (
      !String.isBlank(loan.Borrower_Status_New__c) &&
      loan.Borrower_Status_New__c.contains('Returning')
    ) {
      factorIncrement = incentivesConstants.get('factorIncrement');
    }

    Decimal totalFactor =
      baseFactor +
      factorIncrement +
      (loan.Impact_Points__c != null
        ? loan.Impact_Points__c *
          incentivesConstants.get('oILoanBasImpactConstant')
        : 0);
    return loan.Loan_Amount__c * totalFactor;
  }

  public static Decimal calculateQuarterlyEarnings(
    List<Loan_Balance__c> balances
  ) {
    if (balances == null || balances.isEmpty()) {
      return 0; // Default to zero if no balances
    }

    Decimal quarterlyEarnings = 0;

    for (Loan_Balance__c balance : balances) {
      Decimal balanceOI =
        balance.End_of_Month_Balance__c *
        incentivesConstants.get('balanceOIConstant');
      Decimal balanceFLC =
        balance.End_of_Month_Balance__c *
        incentivesConstants.get('balanceFLCConstant');
      quarterlyEarnings += balanceOI + balanceFLC;
    }

    return quarterlyEarnings;
  }

  // Get bonuses from the custom metadata
  //   public static Boolean getBonusValue(
  //     Map<String, Boolean> bonuses,
  //     String key
  //   ) {
  //     return bonuses != null && bonuses.containsKey(key) && bonuses.get(key);
  //   }
}

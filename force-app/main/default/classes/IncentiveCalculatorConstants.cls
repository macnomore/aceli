public class IncentiveCalculatorConstants {
  public static String INCENTIVE_CALCULATOR_CONFIG = 'Incentive_Calculator_Config';

  public static Map<String, Double> loadConstants() {
    Map<String, Double> constantValuesMap =new<String, Double>();
    String constantValuesObject;

    for (Incentive_Config__mdt incentiveConfig : [
      SELECT Attribute_Map__c
      FROM Incentive_Config__mdt
      WHERE DeveloperName = :INCENTIVE_CALCULATOR_CONFIG LIMIT 1
    ]) {
      constantValuesObject = incentiveConfig.Attribute_Map__c;
    }

    Map<String, Object> constantValues = (Map<String, Object>) JSON.deserializeUntyped(
      constantValuesObject
    );

    constantValuesMap.put(
      'oILoanAmountThreshold',
      (Double) constantValues.get('oILoanAmountThreshold')
    );
    constantValuesMap.put(
      'oIRevenueThreshold',
      (Double) constantValues.get('oIRevenueThreshold')
    );
    constantValuesMap.put(
      'baseOIConstant',
      (Double) constantValues.get('baseOIConstant')
    );
    constantValuesMap.put(
      'oILoanBasImpactConstant',
      (Double) constantValues.get('oILoanBasImpactConstant')
    );
    constantValuesMap.put(
      'eSGYouthOwnedBonus',
      (Double) constantValues.get('eSGYouthOwnedBonus')
    );
    constantValuesMap.put(
      'eSGClimateSmartBonus',
      (Double) constantValues.get('eSGClimateSmartBonus')
    );
    constantValuesMap.put(
      'eSGGenderInclusiveBonus',
      (Double) constantValues.get('eSGGenderInclusiveBonus')
    );
    constantValuesMap.put(
      'countryAdjustment',
      (Double)constantValues.get('countryAdjustment')
    );
    constantValuesMap.put(
      'baseFactor',
      (Double) constantValues.get('baseFactor')
    );
    constantValuesMap.put(
      'factorIncrement',
      (Double) constantValues.get('factorIncrement')
    );
    constantValuesMap.put(
      'balanceOIConstant',
      (Double) constantValues.get('balanceOIConstant')
    );
    constantValuesMap.put(
      'balanceFLCConstant',
      (Double) constantValues.get('balanceFLCConstant')
    );

    return constantValuesMap;
  }
}

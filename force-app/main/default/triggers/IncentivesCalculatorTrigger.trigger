trigger IncentivesCalculatorTrigger on Loan__c(before insert, before update) {
  IncentiveCalculator.calculateIncentives(Trigger.new[0].Id);
}

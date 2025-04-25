trigger IncentivesCalculatorTrigger on Loan__c(before insert, before update) {
    if (Trigger.isBefore){
        if (Trigger.isInsert || Trigger.isUpdate){
            IncentiveCalculator.calculateIncentives(Trigger.new[0].Id);
        }
    }
}

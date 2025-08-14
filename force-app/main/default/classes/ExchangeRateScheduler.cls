/**
 * @description Scheduler class to run the exchange rate update on a schedule
 * Scheduling should be done in Salesforce Setup Apex Classes -> Schedule Apex
 */
global class ExchangeRateScheduler {
    
    /**
     * @description Executes the scheduled job to update exchange rates
     * @param context The SchedulableContext
     */
    global void execute(SchedulableContext sc) {
        List<Exchange_Rate__c> exchangeRates = new List<Exchange_Rate__c>();
        try{
            exchangeRates = ExchangeRateService.updateExchangeRates();
        } catch(Exception ex) {
            System.debug('** Error updating exchange rates: ' + ex.getMessage());
        }
    }
}
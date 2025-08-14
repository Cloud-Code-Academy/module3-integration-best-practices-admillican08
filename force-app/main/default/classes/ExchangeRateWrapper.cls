/**
 * @description Wrapper class to deserialize the JSON response from the Exchange Rate API
 * Students will implement the properties and methods to process the data
 */
public virtual class ExchangeRateWrapper {
    // Add properties for base currency
    public String base_code;
    // Add property for time last updated
    public String time_last_update_unix;
    // Add property for rates (using a map)
    public Map<String, Decimal> conversion_rates ;
    public List<ExchangeRate> indivExchangeRates {get; protected set;}
    
    
    public class ExchangeRate extends ExchangeRateWrapper{
        public String targetCurrencyCode {get; private set;}
        public Decimal targetRate {get; private set;}
        
        // Add property for external ID
        // This is an ID you will generate to uniquely identify the exchange rate record
        // This does not come from the API response
        public String externalId {get; private set;}
        
        public ExchangeRate(String base_code, String targetCurrencyCode, Decimal targetRate, String timeLastUpdate){
            this.base_code = base_code;
            this.time_last_update_unix = timeLastUpdate;
            this.targetCurrencyCode = targetCurrencyCode;
            this.targetRate = targetRate;
            this.externalId = base_code + '_' + this.targetCurrencyCode;
        }
    }
    
    public class ExchangeRateParsingException extends Exception{}
    
    public void createIndivExchangeRatesList(){
        indivExchangeRates = new List<ExchangeRate>();
        for(String currencyCode: this.conversion_rates.keySet()){
            Decimal targetRate = this.conversion_rates.get(currencyCode);
            indivExchangeRates.add(new ExchangeRate(this.base_code, currencyCode, targetRate, this.time_last_update_unix));
        }
    }
    
    /**
     * @description Converts the wrapper data to a list of Exchange_Rate__c records
     * @return List<Exchange_Rate__c> The list of exchange rate records
     */
    public List<Exchange_Rate__c> toExchangeRates() {
        // 1. Create a list to hold the Exchange_Rate__c records
        // 2. Iterate through the rates map
        // 3. For each rate, create an Exchange_Rate__c record
        // 4. Return the list of records
        List<Exchange_Rate__c> exchangeRateLst = new List<Exchange_Rate__c>();
        for(ExchangeRate exchangeRateObj: this.indivExchangeRates){
            Exchange_Rate__c exchangeRateRecord = new Exchange_Rate__c(
                Base_Currency__c = exchangeRateObj.base_code,
            Last_Updated__c = this.convertUnixToDatetime(exchangeRateObj.time_last_update_unix),
            Target_Currency__c = exchangeRateObj.targetCurrencyCode,
            Rate__c = exchangeRateObj.targetRate,
            External_Id__c = exchangeRateObj.externalId);
            exchangeRateLst.add(exchangeRateRecord);
        }
        return exchangeRateLst;
    }
    /**
     * @description Static method to parse the JSON response into the wrapper class
     * @param jsonResponse The JSON response from the API
     * @return ExchangeRateWrapper The parsed wrapper instance
     */
    public static ExchangeRateWrapper parse(String jsonResponse) {
        // Use JSON.deserialize or JSON.deserializeStrict to parse the response
        ExchangeRateWrapper wrapperObj = (ExchangeRateWrapper) JSON.deserialize(jsonResponse, ExchangeRateWrapper.class);
        wrapperObj.createIndivExchangeRatesList();
        return wrapperObj;
    }
    
    @TestVisible
    private Datetime convertUnixToDatetime(String lastUpdatedUnixValue){
        
        try{
            Long unixVal = Long.valueOf(lastUpdatedUnixValue);
            Long unixTimeMilliseconds = unixVal * 1000;
            return Datetime.newInstance(unixTimeMilliseconds);
        }
        catch(Exception ex){
            System.debug('** Error parsing ExchangeRate datetime: ' + ex.getMessage());
            throw new ExchangeRateParsingException('** Error parsing date: ' + ex.getMessage());
        }
    }
    
}
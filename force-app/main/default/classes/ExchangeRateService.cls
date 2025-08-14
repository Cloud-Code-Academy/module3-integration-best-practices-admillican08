/**
 * @description Service class that handles API callouts to the Exchange Rate API
 * Students will implement the methods to make callouts and process responses
 */
public class ExchangeRateService {
    
    // The named credential to use for the callout
    private static final String NAMED_CREDENTIAL = 'callout:ExchangeRate_API';
    //private static final String URL = 'https://v6.exchangerate-api.com/v6/b8a01d6240eeafad6345ad6c/latest';
    private static final Integer TIMEOUT = 12000;
    // The base currency to use for exchange rates
    private static final String BASE_CURRENCY = 'USD';
    
    /**
     * @description Makes a callout to the Exchange Rate API to get the latest exchange rates
     * @return ExchangeRateWrapper containing the response data
     */
    public static ExchangeRateWrapper getLatestRates() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(NAMED_CREDENTIAL + '/latest/' + BASE_CURRENCY );
        request.setMethod('GET');
        request.setTimeout(TIMEOUT);
        HttpResponse resp = http.send(request);
        ApiResponse apiResponse = new ApiResponse(resp);
        if(apiResponse.isSuccess){
            return ExchangeRateWrapper.parse(apiResponse.body);
        } else {
            throw new ExchangeRateProcessingException('** Error fetching exchange rates: ' + apiResponse.responseMsg);
        }
    }
    /**
     * @description Processes the exchange rate data and creates or updates records
     * @param rateData The wrapper containing exchange rate data
     * @return List<Exchange_Rate__c> The list of records created or updated
     */
    public static List<Exchange_Rate__c> processRates(ExchangeRateWrapper rateData) {
        if(rateData.createIndivExchangeRatesList() == null || rateData.indivExchangeRates.isEmpty()) {
            rateData.createIndivExchangeRatesList();
        }
        List<Exchange_Rate__c> processedRates = rateData.toExchangeRates();
        try{
            upsert as user processedRates external_Id__c;
            return processedRates;
        }
        catch(Exception ex){
            throw new ExchangeRateProcessingException(ex.getMessage());
        }
    }
    
    /**
     * @description Combines getting and processing rates into a single operation
     * @return List<Exchange_Rate__c> The list of records created or updated
     */
    public static List<Exchange_Rate__c> updateExchangeRates() {
        // 1. Call getLatestRates to retrieve the data
        // 2. Call processRates to create/update records
        // 3. Return the processed records
        List<Exchange_Rate__c> exchangeRates = new List<Exchange_Rate__c>();
        ExchangeRateWrapper exchangeWrapper = getLatestRates();
        try{
            exchangeRates = processRates(exchangeWrapper);
        } catch(Exception ex) {
            throw new ExchangeRateProcessingException('Error processing exchange rates: ' + ex.getMessage());
        }
        return exchangeRates;
    }
}
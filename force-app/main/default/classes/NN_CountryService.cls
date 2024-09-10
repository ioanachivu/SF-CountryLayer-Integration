/**
 * @description       : This class is responsible for fetching and updating country data in Salesforce.
 * @author            : ioana-a-chivu
 * @group             : 
 * @last modified on  : 09-10-2024
 * @last modified by  : ioana-a-chivu
**/
public class NN_CountryService {
  
    // Inner class to map the API response
    public class CountryData {
        public String name;
        public String alpha2Code;
        public String alpha3Code;
        public String capital;
        public String region;
        public List<RegionalBloc> regionalBlocs;
    }
    
    public class RegionalBloc {
        public String acronym;
    }

    // Method to fetch and update country data
    public static void updateCountryData() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:CountryLayerAPI'); //named credential
        request.setMethod('GET');
        
        try {
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                //Deserialize the response body into a list of CountryData objects.
                List<CountryData> countries = (List<CountryData>) JSON.deserialize(response.getBody(), List<CountryData>.class);
                
                // Collect all alpha2Codes into a set
                Set<String> alpha2Codes = new Set<String>();
                Map<String, NN_Country__c> existingCountriesMap = new Map<String, NN_Country__c>();
                List<NN_Country__c> countriesToInsert = new List<NN_Country__c>();
                List<NN_Country__c> countriesToUpdate = new List<NN_Country__c>();

                // Collect all alpha2Codes into a set
                addAlpha2CodesToSet(countries, alpha2Codes);
                
                // Query existing Country__c records by alpha2code and add to map
                populateExistingCountriesMap(alpha2Codes, existingCountriesMap);
                
                // Process and update the country data in Salesforce
                for (CountryData country : countries) {
                    NN_Country__c existingCountry = existingCountriesMap.get(country.alpha2Code);
                    
                    if (existingCountry == null) {
                        // Insert new record
                        countriesToInsert.add(createCountryRecord(country));
                    } else {
                        // Update existing record if data has changed
                        if (isCountryDataChanged(existingCountry, country)) {
                            updateCountryRecord(existingCountry, country);
                            countriesToUpdate.add(existingCountry);
                        }
                    }
                }
                
                // Perform DML operations
                if (!countriesToInsert.isEmpty()) {
                    insert countriesToInsert;
                    System.debug('countriesToInsert: ' + countriesToInsert);}
                    
                if (!countriesToUpdate.isEmpty()) {
                    update countriesToUpdate;
                    System.debug('countriesToUpdate: ' + countriesToUpdate);
                }
                
            } else {
                System.debug('Failed to fetch country data: ' + response.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage() + ' at line: ' + e.getLineNumber());
        }
    }

    private static void addAlpha2CodesToSet(List<CountryData> countries, Set<String> alpha2Codes) {
        for (CountryData country : countries) {
            alpha2Codes.add(country.alpha2Code);
        }
    }

    private static void populateExistingCountriesMap(Set<String> alpha2Codes, Map<String, NN_Country__c> existingCountriesMap) {
        for (NN_Country__c country : [SELECT Id, Name, NN_Alpha2Code__c, NN_Alpha3Code__c, NN_CapitalCity__c, NN_Region__c, NN_RegionalBlocs__c
                                              FROM NN_Country__c 
                                              WHERE NN_Alpha2Code__c IN :alpha2Codes]) {
            existingCountriesMap.put(country.NN_Alpha2Code__c, country);
        }
    }
    
    private static NN_Country__c createCountryRecord(CountryData country) {
        return new NN_Country__c(
            Name                = country.name,
            NN_Alpha2Code__c    = country.alpha2Code,
            NN_Alpha3Code__c    = country.alpha3Code,
            NN_CapitalCity__c   = country.capital,
            NN_Region__c        = country.region,
            NN_RegionalBlocs__c = (country.regionalBlocs != null) ? country.regionalBlocs[0].acronym : null
        );
    }
    
    private static void updateCountryRecord(NN_Country__c existingCountry, CountryData country) {
        existingCountry.Name                = country.name;
        existingCountry.NN_Alpha3Code__c    = country.alpha3Code;
        existingCountry.NN_CapitalCity__c   = country.capital;
        existingCountry.NN_Region__c        = country.region;
        existingCountry.NN_RegionalBlocs__c = (country.regionalBlocs != null) ? country.regionalBlocs[0].acronym : null;
    }
    
    private static Boolean isCountryDataChanged(NN_Country__c existingCountry, CountryData country) {
        return existingCountry.Name != country.name || 
               existingCountry.NN_Alpha3Code__c != country.alpha3Code || 
               existingCountry.NN_CapitalCity__c != country.capital || 
               existingCountry.NN_Region__c != country.region || 
               existingCountry.NN_RegionalBlocs__c != ((country.regionalBlocs != null) ? country.regionalBlocs[0].acronym : null);
    }
}

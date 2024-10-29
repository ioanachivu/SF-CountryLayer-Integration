/**
 * @description       : This class is responsible for fetching and updating country data in Salesforce.
 * @author            : ioana-a-chivu
 * @group             : 
 * @last modified on  : 10-29-2024
 * @last modified by  : ioana-a-chivu
**/
public class CM_CountryService {
  
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
                
                Set<String> alpha2Codes = new Set<String>();
                Map<String, CM_Country__c> existingCountriesMap = new Map<String, CM_Country__c>();
                List<CM_Country__c> countriesToInsert = new List<CM_Country__c>();
                List<CM_Country__c> countriesToUpdate = new List<CM_Country__c>();

                // Collect all alpha2Codes into a set
                addAlpha2CodesToSet(countries, alpha2Codes);
                
                // Query existing Country__c records by alpha2code and add to map
                populateExistingCountriesMap(alpha2Codes, existingCountriesMap);
                
                // Process and update the country data in Salesforce
                for (CountryData country : countries) {
                    CM_Country__c existingCountry = existingCountriesMap.get(country.alpha2Code);
                    
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

    //Adds the alpha2 codes from the given list of CountryData objects to the provided set.
    private static void addAlpha2CodesToSet(List<CountryData> countries, Set<String> alpha2Codes) {
        for (CountryData country : countries) {
            alpha2Codes.add(country.alpha2Code);
        }
    }

    //Populates the existing countries map with the specified alpha2 codes.
    private static void populateExistingCountriesMap(Set<String> alpha2Codes, Map<String, CM_Country__c> existingCountriesMap) {
        for (CM_Country__c country : [SELECT Id, Name, CM_Alpha2Code__c, CM_Alpha3Code__c, CM_CapitalCity__c, CM_Region__c, CM_RegionalBlocs__c
                                              FROM CM_Country__c 
                                              WHERE CM_Alpha2Code__c IN :alpha2Codes]) {
            existingCountriesMap.put(country.CM_Alpha2Code__c, country);
        }
    }
    
    //Creates a new CM_Country__c record based on the provided CountryData object.
    private static CM_Country__c createCountryRecord(CountryData country) {
        return new CM_Country__c(
            Name                = country.name,
            CM_Alpha2Code__c    = country.alpha2Code,
            CM_Alpha3Code__c    = country.alpha3Code,
            CM_CapitalCity__c   = country.capital,
            CM_Region__c        = country.region,
            CM_RegionalBlocs__c = (country.regionalBlocs != null) ? country.regionalBlocs[0].acronym : null
        );
    }
    
    //Updates the fields of an existing CM_Country__c record with the values from a CountryData object.
    private static void updateCountryRecord(CM_Country__c existingCountry, CountryData country) {
        existingCountry.Name                = country.name;
        existingCountry.CM_Alpha3Code__c    = country.alpha3Code;
        existingCountry.CM_CapitalCity__c   = country.capital;
        existingCountry.CM_Region__c        = country.region;
        existingCountry.CM_RegionalBlocs__c = (country.regionalBlocs != null) ? country.regionalBlocs[0].acronym : null;
    }
    
    // Determines if the country data has changed.
    private static Boolean isCountryDataChanged(CM_Country__c existingCountry, CountryData country) {
        return existingCountry.Name != country.name || 
               existingCountry.CM_Alpha3Code__c != country.alpha3Code || 
               existingCountry.CM_CapitalCity__c != country.capital || 
               existingCountry.CM_Region__c != country.region || 
               existingCountry.CM_RegionalBlocs__c != ((country.regionalBlocs != null) ? country.regionalBlocs[0].acronym : null);
    }
}

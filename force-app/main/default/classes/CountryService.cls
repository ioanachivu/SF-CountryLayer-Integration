/**
 * @description       : This class is responsible for fetching and updating country data in Salesforce.
 * @author            : ioana-a-chivu
 * @group             : 
 * @last modified on  : 11-11-2024
 * @last modified by  : ioana-a-chivu
**/
public class CountryService {
  
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
                Map<String, Country__c> existingCountriesMap = new Map<String, Country__c>();
                List<Country__c> countriesToUpsert = new List<Country__c>();

                // Collect all alpha2Codes into a set
                addAlpha2CodesToSet(countries, alpha2Codes);
                
                // Query existing Country__c records by alpha2code and add to map
                populateExistingCountriesMap(alpha2Codes, existingCountriesMap);
                
                // Process and update the country data in Salesforce
                for (CountryData country : countries) {
                    Country__c existingCountry = existingCountriesMap.get(country.alpha2Code);
                    
                    if (existingCountry == null) {
                        // Insert new record
                        countriesToUpsert.add(createCountryRecord(country));
                    } else {
                        // Update existing record if data has changed
                        if (isCountryDataChanged(existingCountry, country)) {
                            updateCountryRecord(existingCountry, country);
                            countriesToUpsert.add(existingCountry);
                        }
                    }
                }
                
                // Perform DML operations
                if (!countriesToUpsert.isEmpty()) {
                    upsert countriesToUpsert; 
                } 
            } else {
                Error_Log__c errLog = ErrorLog.logError('CountryService', 'updateCountryData', response.getBody(), null, 71, null);
                insert errLog;
            }
        } catch (Exception e) {
            Error_Log__c errLog = ErrorLog.logError('CountryService', 'updateCountryData', ex.getMessage(), ex.getStackTraceString(), ex.getLineNumber(), null);
            insert errLog;
        }
    }

    //Adds the alpha2 codes from the given list of CountryData objects to the provided set.
    private static void addAlpha2CodesToSet(List<CountryData> countries, Set<String> alpha2Codes) {
        for (CountryData country : countries) {
            alpha2Codes.add(country.alpha2Code);
        }
    }

    //Populates the existing countries map with the specified alpha2 codes.
    private static void populateExistingCountriesMap(Set<String> alpha2Codes, Map<String, Country__c> existingCountriesMap) {
        for (Country__c country : [SELECT Id, Name, Alpha2Code__c, Alpha3Code__c, CapitalCity__c, Region__c, RegionalBlocs__c
                                              FROM Country__c 
                                              WHERE Alpha2Code__c IN :alpha2Codes]) {
            existingCountriesMap.put(country.Alpha2Code__c, country);
        }
    }
    
    //Creates a new Country__c record based on the provided CountryData object.
    private static Country__c createCountryRecord(CountryData country) {
        return new Country__c(
            Name                = country.name,
            Alpha2Code__c    = country.alpha2Code,
            Alpha3Code__c    = country.alpha3Code,
            CapitalCity__c   = country.capital,
            Region__c        = country.region,
            RegionalBlocs__c = (country.regionalBlocs != null) ? country.regionalBlocs[0].acronym : null
        );
    }
    
    //Updates the fields of an existing Country__c record with the values from a CountryData object.
    private static void updateCountryRecord(Country__c existingCountry, CountryData country) {
        existingCountry.Name                = country.name;
        existingCountry.Alpha3Code__c    = country.alpha3Code;
        existingCountry.CapitalCity__c   = country.capital;
        existingCountry.Region__c        = country.region;
        existingCountry.RegionalBlocs__c = (country.regionalBlocs != null) ? country.regionalBlocs[0].acronym : null;
    }
    
    // Determines if the country data has changed.
    private static Boolean isCountryDataChanged(Country__c existingCountry, CountryData country) {
        return existingCountry.Name != country.name || 
               existingCountry.Alpha3Code__c != country.alpha3Code || 
               existingCountry.CapitalCity__c != country.capital || 
               existingCountry.Region__c != country.region || 
               existingCountry.RegionalBlocs__c != ((country.regionalBlocs != null) ? country.regionalBlocs[0].acronym : null);
    }
}

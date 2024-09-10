/**
 * @description       : provides methods to populate country information on Leads.
 * @author            : ioana-a-chivu
 * @group             : 
 * @last modified on  : 09-10-2024
 * @last modified by  : ioana-a-chivu
**/
public class NN_LeadHandler {

    public static void populateCountryInfo(List<Lead> leads) {
        if (leads == null || leads.isEmpty()) {
            return; // Exit if leads list is null or empty
        }

        Set<String> countrieSet = new Set<String>();
        
        // Collect unique country names from leads
        for (Lead lead : leads) {
            if (lead.Country != null) {
                countrieSet.add(lead.Country);
            }
        }
        System.debug('countrieSet: ' + countrieSet);
        
        // Query Country__c records based on country names
        if (!countrieSet.isEmpty()) {
            List<NN_Country__c> countryList = [SELECT Name, NN_Alpha2Code__c, NN_Alpha3Code__c, NN_CapitalCity__c, NN_Region__c, NN_RegionalBlocs__c
                                               FROM NN_Country__c 
                                               WHERE Name IN :countrieSet];
            System.debug('countryList: ' + countryList);                       

            // Creates a map of country names as key to NN_Country__c objects.
            Map<String, NN_Country__c> countryMap = new Map<String, NN_Country__c>();
            
            for (NN_Country__c country : countryList) {
                countryMap.put(country.Name, country);
            }  
            
            // Loop through the leads and populate fields
            for (Lead lead : leads) {
                if (lead.Country != null && countryMap.containsKey(lead.Country)) {
                    NN_Country__c country = countryMap.get(lead.Country);
                    populateLeadFields(lead, country);
                } else {
                    // Handle case where country is spelled wrong / not found
                    clearFields(lead);
                }
            } 
        } else {
            // Handle case where country is null
            for (Lead lead : leads) {
                clearFields(lead);
            }
        }
    }

    // Method to populate lead fields with country info
    private static void populateLeadFields(Lead lead, NN_Country__c country) {
        lead.Country                    = country.Name;
        lead.NN_CountryAlpha2Code__c    = country.NN_Alpha2Code__c;
        lead.NN_CountryAlpha3Code__c    = country.NN_Alpha3Code__c;
        lead.NN_CountryCapitalCity__c   = country.NN_CapitalCity__c;
        lead.NN_CountryRegion__c        = country.NN_Region__c;
        lead.NN_CountryRegionalBlocs__c = country.NN_RegionalBlocs__c;
    }

    // Method to clear lead fields
    private static void clearFields(Lead lead) {
        lead.NN_CountryAlpha2Code__c    = null;
        lead.NN_CountryAlpha3Code__c    = null;
        lead.NN_CountryCapitalCity__c   = null;
        lead.NN_CountryRegion__c        = null;
        lead.NN_CountryRegionalBlocs__c = null;
    }
}

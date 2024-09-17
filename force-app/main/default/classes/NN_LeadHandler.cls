/**
 * @description       : provides methods to populate country information on Leads.
 * @author            : ioana-a-chivu
 * @group             : 
 * @last modified on  : 09-16-2024
 * @last modified by  : ioana-a-chivu
**/
public class NN_LeadHandler {

    public static void populateLeadCountryInfo(List<Lead> leads) {
        if (leads == null || leads.isEmpty()) {
            return; // Exit if leads list is null or empty
        }

        Set<String> countrySet = new Set<String>();
        Map<String, NN_Country__c> countryMap = new Map<String, NN_Country__c>();
        
        // Collect country names from leads and add to set
        addCountriesToSet(leads, countrySet);
        
        // Query Country__c records based on country names
        if (!countrySet.isEmpty()) {
            List<NN_Country__c> countryList = [SELECT Name, NN_Alpha2Code__c, NN_Alpha3Code__c, NN_CapitalCity__c, NN_Region__c, NN_RegionalBlocs__c
                                               FROM NN_Country__c 
                                               WHERE Name IN :countrySet];                      

            // Creates a map of country names as key to NN_Country__c objects.
            populateCountryMap(countryList, countryMap);

            // Loop through the leads and populate fields
            for (Lead lead : leads) {
                //if lead's country exists in the countryMap, we get NN_Country__c object and populate lead fields
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

    //Adds the countries from the given list of leads to the specified set.
    private static void addCountriesToSet(List<Lead> leads, Set<String> countrySet) {
        for (Lead lead : leads) {
            if (lead.Country != null) {
                countrySet.add(lead.Country);
            }
        }
    }

    //Populates a map with country records.
    private static void populateCountryMap(List<NN_Country__c> countryList, Map<String, NN_Country__c> countryMap) {
        for (NN_Country__c country : countryList) {
            countryMap.put(country.Name, country);
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

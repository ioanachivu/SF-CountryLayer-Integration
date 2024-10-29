/**
 * @description       : provides methods to populate country information on Leads.
 * @author            : ioana-a-chivu
 * @group             : 
 * @last modified on  : 10-29-2024
 * @last modified by  : ioana-a-chivu
**/
public class CM_LeadHandler {

    public static void populateLeadCountryInfo(List<Lead> leads) {
        if (leads == null || leads.isEmpty()) {
            return; // Exit if leads list is null or empty
        }

        Set<String> countrySet = new Set<String>();
        Map<String, CM_Country__c> countryMap = new Map<String, CM_Country__c>();
        
        // Collect country names from leads and add to set
        addCountriesToSet(leads, countrySet);
        
        // Query Country__c records based on country names
        if (!countrySet.isEmpty()) {
            List<CM_Country__c> countryList = [SELECT Name, CM_Alpha2Code__c, CM_Alpha3Code__c, CM_CapitalCity__c, CM_Region__c, CM_RegionalBlocs__c
                                               FROM CM_Country__c 
                                               WHERE Name IN :countrySet];                      

            // Creates a map of country names as key to CM_Country__c objects.
            populateCountryMap(countryList, countryMap);

            // Loop through the leads and populate fields
            for (Lead lead : leads) {
                //if lead's country exists in the countryMap, we get CM_Country__c object and populate lead fields
                if (lead.Country != null && countryMap.containsKey(lead.Country)) {
                    CM_Country__c country = countryMap.get(lead.Country);
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
    private static void populateCountryMap(List<CM_Country__c> countryList, Map<String, CM_Country__c> countryMap) {
        for (CM_Country__c country : countryList) {
            countryMap.put(country.Name, country);
        }
    }

    // Method to populate lead fields with country info
    private static void populateLeadFields(Lead lead, CM_Country__c country) {
        lead.Country                    = country.Name;
        lead.CM_CountryAlpha2Code__c    = country.CM_Alpha2Code__c;
        lead.CM_CountryAlpha3Code__c    = country.CM_Alpha3Code__c;
        lead.CM_CountryCapitalCity__c   = country.CM_CapitalCity__c;
        lead.CM_CountryRegion__c        = country.CM_Region__c;
        lead.CM_CountryRegionalBlocs__c = country.CM_RegionalBlocs__c;
    }

    // Method to clear lead fields
    private static void clearFields(Lead lead) {
        lead.CM_CountryAlpha2Code__c    = null;
        lead.CM_CountryAlpha3Code__c    = null;
        lead.CM_CountryCapitalCity__c   = null;
        lead.CM_CountryRegion__c        = null;
        lead.CM_CountryRegionalBlocs__c = null;
    }
}

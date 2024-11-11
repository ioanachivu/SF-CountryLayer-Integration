/**
 * @description       : provides methods to populate country information on Leads.
 * @author            : ioana-a-chivu
 * @group             : 
 * @last modified on  : 11-11-2024
 * @last modified by  : ioana-a-chivu
**/
public class LeadHandler {

    public static void populateLeadCountryInfo(List<Lead> leads) {
        if (leads == null || leads.isEmpty()) {
            return; // Exit if leads list is null or empty
        }

        Set<String> countrySet = new Set<String>();
        Map<String, Country__c> countryMap = new Map<String, Country__c>();
        
        // Collect country names from leads and add to set
        addCountriesToSet(leads, countrySet);
        
        // Query Country__c records based on country names
        if (!countrySet.isEmpty()) {
            List<Country__c> countryList = [SELECT Name, Alpha2Code__c, Alpha3Code__c, CapitalCity__c, Region__c, RegionalBlocs__c
                                               FROM Country__c 
                                               WHERE Name IN :countrySet];                      

            // Creates a map of country names as key to Country__c objects.
            populateCountryMap(countryList, countryMap);

            // Loop through the leads and populate fields
            for (Lead lead : leads) {
                //if lead's country exists in the countryMap, we get Country__c object and populate lead fields
                if (lead.Country != null && countryMap.containsKey(lead.Country)) {
                    Country__c country = countryMap.get(lead.Country);
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
    private static void populateCountryMap(List<Country__c> countryList, Map<String, Country__c> countryMap) {
        for (Country__c country : countryList) {
            countryMap.put(country.Name, country);
        }
    }

    // Method to populate lead fields with country info
    private static void populateLeadFields(Lead lead, Country__c country) {
        lead.Country                    = country.Name;
        lead.CountryAlpha2Code__c    = country.Alpha2Code__c;
        lead.CountryAlpha3Code__c    = country.Alpha3Code__c;
        lead.CountryCapitalCity__c   = country.CapitalCity__c;
        lead.CountryRegion__c        = country.Region__c;
        lead.CountryRegionalBlocs__c = country.RegionalBlocs__c;
    }

    // Method to clear lead fields
    private static void clearFields(Lead lead) {
        lead.CountryAlpha2Code__c    = null;
        lead.CountryAlpha3Code__c    = null;
        lead.CountryCapitalCity__c   = null;
        lead.CountryRegion__c        = null;
        lead.CountryRegionalBlocs__c = null;
    }
}

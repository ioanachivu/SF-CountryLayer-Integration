/**
 * @description       : provides methods to populate country information on Leads.
 * @author            : ioana-a-chivu
 * @group             : 
 * @last modified on  : 09-08-2024
 * @last modified by  : ioana-a-chivu
**/
public class NN_LeadHelper {
    
    // Method to populate country info on Leads
    public static void populateCountryInfo(List<Lead> leads) {
        Set<String> countries = new Set<String>();
        
        // Collect unique country names from leads
        for (Lead lead : leads) {
            if (lead.Country != null) {
                countries.add(lead.Country);
            }
        }
        
        // Query Country__c records based on country names
        if (!countries.isEmpty()) {
            Map<String, Country__c> countryMap = new Map<String, Country__c>([SELECT Name, Alpha2Code__c, Alpha3Code__c, Capital__c, Region__c 
                                                                                FROM Country__c 
                                                                                WHERE Name IN :countries]);
            
            // Loop through the leads and populate fields
            for (Lead lead : leads) {
                if (lead.Country != null && countryMap.containsKey(lead.Country)) {
                    Country__c country          = countryMap.get(lead.Country);
                    lead.Country                = country.Name;
                    lead.Country_Alpha2Code__c  = country.Alpha2Code__c;
                    lead.Country_Alpha3Code__c  = country.Alpha3Code__c;
                    lead.Country_Capital__c     = country.Capital__c;
                    lead.Country_Region__c      = country.Region__c;
                }
            }
        }
    }
}

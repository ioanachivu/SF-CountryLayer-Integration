/**
 * @description       : This is a test class for the NN_LeadHandler class.
 * @author            : ioana-a-chivu
 * @group             : 
 * @last modified on  : 09-08-2024
 * @last modified by  : ioana-a-chivu
**/
public with sharing class NN_LeadHandlerTest {
    @IsTest
    static void testLeadTriggerHandler() {
        // Create a mock country record
        Country__c country = new Country__c(
            Name = 'United States', 
            Alpha2Code__c = 'US', 
            Alpha3Code__c = 'USA', 
            Capital__c = 'Washington, D.C.', 
            Region__c = 'Americas'
        );
        insert country;
        
        // Create a new Lead record
        Lead lead = new Lead(
            FirstName = 'John', 
            LastName = 'Doe', 
            Country = 'United States', 
            Company = 'TestCorp'
        );
        insert lead;
        
        // Retrieve the lead and verify that the country information was populated correctly
        Lead insertedLead = [SELECT Country_Name__c, Country_Alpha2Code__c, Country_Alpha3Code__c, Country_Capital__c, Country_Region__c 
                             FROM Lead WHERE Id = :lead.Id];
        
        System.assertEquals('United States', insertedLead.Country_Name__c);
        System.assertEquals('US', insertedLead.Country_Alpha2Code__c);
        System.assertEquals('USA', insertedLead.Country_Alpha3Code__c);
        System.assertEquals('Washington, D.C.', insertedLead.Country_Capital__c);
        System.assertEquals('Americas', insertedLead.Country_Region__c);
    }
}
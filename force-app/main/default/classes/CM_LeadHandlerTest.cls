/**
 * @description       : This is a test class for the CM_LeadHandler class and it's associated trigger
 * @author            : ioana-a-chivu
 * @group             : 
 * @last modified on  : 10-29-2024
 * @last modified by  : ioana-a-chivu
**/
@isTest
public class CM_LeadHandlerTest {
    
    @testSetup
    static void setup() {
        // Create test data for Country records
        CM_Country__c romania = new CM_Country__c(
            Name = 'Romania',
            CM_Alpha2Code__c = 'RO',
            CM_Alpha3Code__c = 'ROU',
            CM_CapitalCity__c = 'Bucharest',
            CM_Region__c = 'Europe',
            CM_RegionalBlocs__c = 'EU'
        );
        insert romania;

        CM_Country__c germany = new CM_Country__c(
            Name = 'Germany',
            CM_Alpha2Code__c = 'DE',
            CM_Alpha3Code__c = 'DEU',
            CM_CapitalCity__c = 'Berlin',
            CM_Region__c = 'Europe',
            CM_RegionalBlocs__c = 'EU'
        );
        insert germany;
    }
    
    @isTest
    static void testLeadTriggerBeforeInsert() {
        // Create test leads
        Lead lead1 = new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            Company = 'Test Company',
            Country = 'Romania'
        );
        
        Lead lead2 = new Lead(
            FirstName = 'Jane',
            LastName = 'Doe',
            Company = 'Test Company 2',
            Country = 'Germany'
        );
        
        Lead lead3 = new Lead(
            FirstName = 'InvalidCountry',
            LastName = 'Lead',
            Company = 'Invalid Company',
            Country = 'Atlantis' // Non-existent country
        );
        
        // Insert leads and fire the trigger
        Test.startTest();
        insert new List<Lead>{ lead1, lead2, lead3 };
        Test.stopTest();
        
        // Requery leads to check if country fields are populated correctly
        Lead insertedLead1 = [SELECT Country, CM_CountryAlpha2Code__c, CM_CountryAlpha3Code__c, CM_CountryCapitalCity__c, CM_CountryRegion__c, CM_CountryRegionalBlocs__c FROM Lead WHERE Id = :lead1.Id];
        Lead insertedLead2 = [SELECT Country, CM_CountryAlpha2Code__c, CM_CountryAlpha3Code__c, CM_CountryCapitalCity__c, CM_CountryRegion__c, CM_CountryRegionalBlocs__c FROM Lead WHERE Id = :lead2.Id];
        Lead insertedLead3 = [SELECT Country, CM_CountryAlpha2Code__c, CM_CountryAlpha3Code__c, CM_CountryCapitalCity__c, CM_CountryRegion__c, CM_CountryRegionalBlocs__c FROM Lead WHERE Id = :lead3.Id];
        
        // Validate the first lead (Romania)
        System.assertEquals('Romania', insertedLead1.Country);
        System.assertEquals('RO', insertedLead1.CM_CountryAlpha2Code__c);
        System.assertEquals('ROU', insertedLead1.CM_CountryAlpha3Code__c);
        System.assertEquals('Bucharest', insertedLead1.CM_CountryCapitalCity__c);
        System.assertEquals('Europe', insertedLead1.CM_CountryRegion__c);
        System.assertEquals('EU', insertedLead1.CM_CountryRegionalBlocs__c);

        // Validate the second lead (Germany)
        System.assertEquals('Germany', insertedLead2.Country);
        System.assertEquals('DE', insertedLead2.CM_CountryAlpha2Code__c);
        System.assertEquals('DEU', insertedLead2.CM_CountryAlpha3Code__c);
        System.assertEquals('Berlin', insertedLead2.CM_CountryCapitalCity__c);
        System.assertEquals('Europe', insertedLead2.CM_CountryRegion__c);
        System.assertEquals('EU', insertedLead2.CM_CountryRegionalBlocs__c);

        // Validate the third lead (Invalid country)
        System.assertEquals('Atlantis', insertedLead3.Country);
        System.assertEquals(null, insertedLead3.CM_CountryAlpha2Code__c);
        System.assertEquals(null, insertedLead3.CM_CountryAlpha3Code__c);
        System.assertEquals(null, insertedLead3.CM_CountryCapitalCity__c);
        System.assertEquals(null, insertedLead3.CM_CountryRegion__c);
        System.assertEquals(null, insertedLead3.CM_CountryRegionalBlocs__c);
    }

    @isTest
    static void testLeadTriggerBeforeUpdate() {
        // Insert a lead without country details
        Lead lead = new Lead(
            FirstName = 'John',
            LastName = 'Smith',
            Company = 'Test Company',
            Country = 'Romania'
        );
        insert lead;

        // Update the lead with a new country
        lead.Country = 'Germany';
        
        Test.startTest();
        update lead;
        Test.stopTest();

        // Requery the lead and check the updated country fields
        Lead updatedLead = [SELECT Country, CM_CountryAlpha2Code__c, CM_CountryAlpha3Code__c, CM_CountryCapitalCity__c, CM_CountryRegion__c, CM_CountryRegionalBlocs__c FROM Lead WHERE Id = :lead.Id];
        
        // Validate that the lead has been updated with new country details
        System.assertEquals('Germany', updatedLead.Country);
        System.assertEquals('DE', updatedLead.CM_CountryAlpha2Code__c);
        System.assertEquals('DEU', updatedLead.CM_CountryAlpha3Code__c);
        System.assertEquals('Berlin', updatedLead.CM_CountryCapitalCity__c);
        System.assertEquals('Europe', updatedLead.CM_CountryRegion__c);
        System.assertEquals('EU', updatedLead.CM_CountryRegionalBlocs__c);
    }
}


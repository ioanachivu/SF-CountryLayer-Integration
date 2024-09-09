/**
 * @description       : This is a test class for the NN_LeadHandler class.
 * @author            : ioana-a-chivu
 * @group             : 
 * @last modified on  : 09-09-2024
 * @last modified by  : ioana-a-chivu
**/
@isTest
public class NN_LeadHandlerTest {
    
    @testSetup
    static void setup() {
        // Create test data for Country records
        NN_Country__c romania = new NN_Country__c(
            Name = 'Romania',
            NN_Alpha2Code__c = 'RO',
            NN_Alpha3Code__c = 'ROU',
            NN_CapitalCity__c = 'Bucharest',
            NN_Region__c = 'Europe',
            NN_RegionalBlocs__c = 'EU'
        );
        insert romania;

        NN_Country__c germany = new NN_Country__c(
            Name = 'Germany',
            NN_Alpha2Code__c = 'DE',
            NN_Alpha3Code__c = 'DEU',
            NN_CapitalCity__c = 'Berlin',
            NN_Region__c = 'Europe',
            NN_RegionalBlocs__c = 'EU'
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
        Lead insertedLead1 = [SELECT Country, NN_CountryAlpha2Code__c, NN_CountryAlpha3Code__c, NN_CountryCapitalCity__c, NN_CountryRegion__c, NN_CountryRegionalBlocs__c FROM Lead WHERE Id = :lead1.Id];
        Lead insertedLead2 = [SELECT Country, NN_CountryAlpha2Code__c, NN_CountryAlpha3Code__c, NN_CountryCapitalCity__c, NN_CountryRegion__c, NN_CountryRegionalBlocs__c FROM Lead WHERE Id = :lead2.Id];
        Lead insertedLead3 = [SELECT Country, NN_CountryAlpha2Code__c, NN_CountryAlpha3Code__c, NN_CountryCapitalCity__c, NN_CountryRegion__c, NN_CountryRegionalBlocs__c FROM Lead WHERE Id = :lead3.Id];
        
        // Validate the first lead (Romania)
        System.assertEquals('Romania', insertedLead1.Country);
        System.assertEquals('RO', insertedLead1.NN_CountryAlpha2Code__c);
        System.assertEquals('ROU', insertedLead1.NN_CountryAlpha3Code__c);
        System.assertEquals('Bucharest', insertedLead1.NN_CountryCapitalCity__c);
        System.assertEquals('Europe', insertedLead1.NN_CountryRegion__c);
        System.assertEquals('EU', insertedLead1.NN_CountryRegionalBlocs__c);

        // Validate the second lead (Germany)
        System.assertEquals('Germany', insertedLead2.Country);
        System.assertEquals('DE', insertedLead2.NN_CountryAlpha2Code__c);
        System.assertEquals('DEU', insertedLead2.NN_CountryAlpha3Code__c);
        System.assertEquals('Berlin', insertedLead2.NN_CountryCapitalCity__c);
        System.assertEquals('Europe', insertedLead2.NN_CountryRegion__c);
        System.assertEquals('EU', insertedLead2.NN_CountryRegionalBlocs__c);

        // Validate the third lead (Invalid country)
        System.assertEquals('Atlantis', insertedLead3.Country);
        System.assertEquals(null, insertedLead3.NN_CountryAlpha2Code__c);
        System.assertEquals(null, insertedLead3.NN_CountryAlpha3Code__c);
        System.assertEquals(null, insertedLead3.NN_CountryCapitalCity__c);
        System.assertEquals(null, insertedLead3.NN_CountryRegion__c);
        System.assertEquals(null, insertedLead3.NN_CountryRegionalBlocs__c);
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
        Lead updatedLead = [SELECT Country, NN_CountryAlpha2Code__c, NN_CountryAlpha3Code__c, NN_CountryCapitalCity__c, NN_CountryRegion__c, NN_CountryRegionalBlocs__c FROM Lead WHERE Id = :lead.Id];
        
        // Validate that the lead has been updated with new country details
        System.assertEquals('Germany', updatedLead.Country);
        System.assertEquals('DE', updatedLead.NN_CountryAlpha2Code__c);
        System.assertEquals('DEU', updatedLead.NN_CountryAlpha3Code__c);
        System.assertEquals('Berlin', updatedLead.NN_CountryCapitalCity__c);
        System.assertEquals('Europe', updatedLead.NN_CountryRegion__c);
        System.assertEquals('EU', updatedLead.NN_CountryRegionalBlocs__c);
    }
}


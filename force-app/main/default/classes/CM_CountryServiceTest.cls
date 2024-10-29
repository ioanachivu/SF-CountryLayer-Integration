/**
 * @description       : Test class for CM_CountryService that tests the updateCountryData method.
 * @author            : ioana-a-chivu
 * @group             : 
 * @last modified on  : 10-29-2024
 * @last modified by  : ioana-a-chivu
**/
@IsTest
public class CM_CountryServiceTest {
    
    // Mock class for simulating HTTP callouts to the countrylayer API.
    private class CountryServiceMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            
            // Simulated JSON response from countrylayer API
            res.setBody('[{"name": "Czechia", "alpha2Code": "CZ", "alpha3Code": "CZE", "capital": "Prague", "region": "Europe", "regionalBlocs": [{"acronym": "EU"}]},' +
                        '{"name": "Romania", "alpha2Code": "RO", "alpha3Code": "ROU", "capital": "Bucharest", "region": "Europe", "regionalBlocs": [{"acronym": "EU"}]}]');
            
            return res;
        }
    }
    
    @IsTest
    static void testCountryUpdate() {
        // Set mock for the HTTP callout to use the CountryServiceMock class
        Test.setMock(HttpCalloutMock.class, new CountryServiceMock());
        
        // Create existing country to test the update (Czechia with old data)
        CM_Country__c existingCountry = new CM_Country__c(
            Name = 'Czechia',
            CM_Alpha2Code__c = 'CZ',
            CM_Alpha3Code__c = 'CZE',
            CM_CapitalCity__c = 'Old Capital',
            CM_Region__c = 'Old Region',
            CM_RegionalBlocs__c = 'Old Bloc'
        );
        insert existingCountry;

        // Call the method to update country data
        Test.startTest();
        CM_CountryService.updateCountryData();
        Test.stopTest();

        // Verify that the existing country (Czechia) was updated
        CM_Country__c updatedCountry = [SELECT Name, CM_Alpha2Code__c, CM_Alpha3Code__c, CM_CapitalCity__c, CM_Region__c, CM_RegionalBlocs__c
                                        FROM CM_Country__c WHERE CM_Alpha2Code__c = 'CZ' LIMIT 1];
        System.assertEquals('Czechia', updatedCountry.Name);
        System.assertEquals('CZE', updatedCountry.CM_Alpha3Code__c);
        System.assertEquals('Prague', updatedCountry.CM_CapitalCity__c);
        System.assertEquals('Europe', updatedCountry.CM_Region__c);
        System.assertEquals('EU', updatedCountry.CM_RegionalBlocs__c);

        // Verify that a new country (Romania) was inserted
        CM_Country__c newCountry = [SELECT Name, CM_Alpha2Code__c, CM_Alpha3Code__c, CM_CapitalCity__c, CM_Region__c, CM_RegionalBlocs__c
                                    FROM CM_Country__c WHERE CM_Alpha2Code__c = 'RO' LIMIT 1];
        System.assertEquals('Romania', newCountry.Name);
        System.assertEquals('ROU', newCountry.CM_Alpha3Code__c);
        System.assertEquals('Bucharest', newCountry.CM_CapitalCity__c);
        System.assertEquals('Europe', newCountry.CM_Region__c);
        System.assertEquals('EU', newCountry.CM_RegionalBlocs__c);
    }
}

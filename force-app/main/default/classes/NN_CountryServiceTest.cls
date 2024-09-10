/**
 * @description       : Test class for NN_CountryService that tests the updateCountryData method.
 * @author            : ioana-a-chivu
 * @group             : 
 * @last modified on  : 09-10-2024
 * @last modified by  : ioana-a-chivu
**/
@IsTest
public class NN_CountryServiceTest {
    
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
        NN_Country__c existingCountry = new NN_Country__c(
            Name = 'Czechia',
            NN_Alpha2Code__c = 'CZ',
            NN_Alpha3Code__c = 'CZE',
            NN_CapitalCity__c = 'Old Capital',
            NN_Region__c = 'Old Region',
            NN_RegionalBlocs__c = 'Old Bloc'
        );
        insert existingCountry;

        // Call the method to update country data
        Test.startTest();
        NN_CountryService.updateCountryData();
        Test.stopTest();

        // Verify that the existing country (Czechia) was updated
        NN_Country__c updatedCountry = [SELECT Name, NN_Alpha2Code__c, NN_Alpha3Code__c, NN_CapitalCity__c, NN_Region__c, NN_RegionalBlocs__c
                                        FROM NN_Country__c WHERE NN_Alpha2Code__c = 'CZ' LIMIT 1];
        System.assertEquals('Czechia', updatedCountry.Name);
        System.assertEquals('CZE', updatedCountry.NN_Alpha3Code__c);
        System.assertEquals('Prague', updatedCountry.NN_CapitalCity__c);
        System.assertEquals('Europe', updatedCountry.NN_Region__c);
        System.assertEquals('EU', updatedCountry.NN_RegionalBlocs__c);

        // Verify that a new country (Romania) was inserted
        NN_Country__c newCountry = [SELECT Name, NN_Alpha2Code__c, NN_Alpha3Code__c, NN_CapitalCity__c, NN_Region__c, NN_RegionalBlocs__c
                                    FROM NN_Country__c WHERE NN_Alpha2Code__c = 'RO' LIMIT 1];
        System.assertEquals('Romania', newCountry.Name);
        System.assertEquals('ROU', newCountry.NN_Alpha3Code__c);
        System.assertEquals('Bucharest', newCountry.NN_CapitalCity__c);
        System.assertEquals('Europe', newCountry.NN_Region__c);
        System.assertEquals('EU', newCountry.NN_RegionalBlocs__c);
    }
}

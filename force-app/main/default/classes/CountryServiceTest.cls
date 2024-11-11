/**
 * @description       : Test class for CountryService that tests the updateCountryData method.
 * @author            : ioana-a-chivu
 * @group             : 
 * @last modified on  : 11-11-2024
 * @last modified by  : ioana-a-chivu
**/
@IsTest
public class CountryServiceTest {
    
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
        Country__c existingCountry = new Country__c(
            Name = 'Czechia',
            Alpha2Code__c = 'CZ',
            Alpha3Code__c = 'CZE',
            CapitalCity__c = 'Old Capital',
            Region__c = 'Old Region',
            RegionalBlocs__c = 'Old Bloc'
        );
        insert existingCountry;

        // Call the method to update country data
        Test.startTest();
        CountryService.updateCountryData();
        Test.stopTest();

        // Verify that the existing country (Czechia) was updated
        Country__c updatedCountry = [SELECT Name, Alpha2Code__c, Alpha3Code__c, CapitalCity__c, Region__c, RegionalBlocs__c
                                        FROM Country__c WHERE Alpha2Code__c = 'CZ' LIMIT 1];
        System.assertEquals('Czechia', updatedCountry.Name);
        System.assertEquals('CZE', updatedCountry.Alpha3Code__c);
        System.assertEquals('Prague', updatedCountry.CapitalCity__c);
        System.assertEquals('Europe', updatedCountry.Region__c);
        System.assertEquals('EU', updatedCountry.RegionalBlocs__c);

        // Verify that a new country (Romania) was inserted
        Country__c newCountry = [SELECT Name, Alpha2Code__c, Alpha3Code__c, CapitalCity__c, Region__c, RegionalBlocs__c
                                    FROM Country__c WHERE Alpha2Code__c = 'RO' LIMIT 1];
        System.assertEquals('Romania', newCountry.Name);
        System.assertEquals('ROU', newCountry.Alpha3Code__c);
        System.assertEquals('Bucharest', newCountry.CapitalCity__c);
        System.assertEquals('Europe', newCountry.Region__c);
        System.assertEquals('EU', newCountry.RegionalBlocs__c);
    }
}

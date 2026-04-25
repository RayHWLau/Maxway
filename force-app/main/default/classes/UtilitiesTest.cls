@isTest
private class UtilitiesTest {
    
    @isTest static void test_getData() {
        Account a = new Account(
            Name='Test Account',
            BillingStreet='Test Street',
            BillingCity='Test City',
            BillingState='Test State',
            BillingCountry='Test Country',
            BillingPostalCode='Test Postal Code');
        insert a;
        String jsonString = '{"searchField":"Name", "object": "Account", "filter": "Name = \'Test Account\'", "order": "Name", "limit": "5", "searchTerm": "Test"}';
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        Test.startTest();
        
        Utilities.convertObjectToMap(response);
        
        Test.stopTest();
        
    }
    @isTest static void test_getData1() {
        Account a = new Account(
            Name='Test Account',
            BillingStreet='Test Street',
            BillingCity='Test City',
            BillingState='Test State',
            BillingCountry='Test Country',
            BillingPostalCode='Test Postal Code');
        insert a;
        String jsonString = '{"searchField":"Name", "object": "Account", "filter": "Name = \'Test Account\'", "order": "Name", "limit": "5", "searchTerm": "Test"}';
        
        Test.startTest();
        
        String response = Utilities.serializeWithoutNamespace(jsonString);
        
        Test.stopTest();
        
    }
    
}
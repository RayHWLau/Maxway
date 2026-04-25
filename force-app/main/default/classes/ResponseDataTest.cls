@isTest
private class ResponseDataTest {
       
     @isTest 
    static void test_getData_addressField1() {
        Account a = new Account(
            Name='Test Account',
            BillingStreet='Test Street',
            BillingCity='Test City',
            BillingState='Test State',
            BillingCountry='Test Country',
            BillingPostalCode='Test Postal Code');
        insert a;
        String jsonString = '{"searchField":"Name", "subtitleField": "BillingAddress", "object": "Account", "filter": "Name = \'Test Account\'", "searchTerm": "Test"}';
        Test.startTest();
        ResponseData sr = new ResponseData();
        String responseString1 = sr.getJsonString();
        Test.stopTest();
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(responseString1);
        Map<string, Object> results = (Map<String, Object>)response.get('results');
        
    }
    
}
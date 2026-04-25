@isTest
public class QueuebleDeleteCheckTest {
    @isTest
    public static void DocDeleteCheck()
    {
         Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        set<id> u=new set<id>();
     	User usr = new User(LastName = 'LIVESTON111',
                           FirstName='JASON',
                           Alias = 'jliv',
                           Email = 'jason111.liveston@asdf.com',
                           Username = 'jason111.liveston@asdf.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US',
                            isActive=true
                            
                           );
        insert usr;
        u.add(usr.Id);
         
         QueuebleToUpdateDocDeleteCheck obj=new QueuebleToUpdateDocDeleteCheck(u);
    		Test.startTest();
            System.enqueueJob(obj);
          Test.stopTest();
    }

}
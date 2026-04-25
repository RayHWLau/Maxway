public class QueuebleToUpdateDectivateUser implements Queueable{
    
    @testVisible
    private static Boolean doChainJob = true;
    public void execute(QueueableContext qc) {
        

        list<user> UserlistToDeactivate = new list<user>();
        map<string,integer> inactiveupdatemap = new map<string,integer>();
        map<string,decimal> activeusers = new map<string,decimal>();
        date currentDay = system.today();
        //date dayAfter = system.today()-1;
        for(user u : [select name, contact.account.License_End_Date__c,contact.accountid,contact.account.Active_License__c from user where  contact.account.License_End_Date__c=:currentDay and isactive = true])
        {
            UserlistToDeactivate.add(new user(Id= u.Id,isactive=false));
            
            activeusers.put(u.contact.accountid,(u.contact.account.Active_License__c!=null ? u.contact.account.Active_License__c: 0));
            
            if  (inactiveupdatemap.containskey(u.contact.accountid))  inactiveupdatemap.put(u.contact.accountid,inactiveupdatemap.get(u.contact.accountid)+1);
            else  inactiveupdatemap.put(u.contact.accountid,1);
            
        }
        
        if(UserlistToDeactivate.size()>0) {
            
            Database.SaveResult[] srList =database.update(UserlistToDeactivate,false); 
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    System.debug('Successfully updated account. Account ID: ' + sr.getId());
                }
                else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        if(doChainJob){
            ID jobID1 = System.enqueueJob(new QueuebleToUpdateCountOfDeactivateUser(inactiveupdatemap,activeusers));
       		system.debug('jobID1-->'+jobID1);
        
        }
        
    }
}
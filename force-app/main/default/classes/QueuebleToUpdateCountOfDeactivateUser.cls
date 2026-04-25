public class QueuebleToUpdateCountOfDeactivateUser  implements Queueable{
    
    map<string,integer> inactiveupdatemap = new map<string,integer>(); 
    map<string,decimal> activeusers = new map<string,decimal>(); 
    
    public QueuebleToUpdateCountOfDeactivateUser(map<string,integer> inactiveupdatemap, map<string,decimal> activeusers) { 
        
        this.inactiveupdatemap = inactiveupdatemap;  
        this.activeusers = activeusers;    
    }  
    
    public void execute(QueueableContext qc) {  
   
        list<account> accountlisttoupdate = new list<account>();
        
        for(string str : activeusers.keyset()){
            if(inactiveupdatemap.containskey(str)){
                decimal activelicence = activeusers.get(str) - inactiveupdatemap.get(str); 
                accountlisttoupdate.add(new account(id = str,Active_License__c = activelicence >0 ?activelicence:0 ));    
            }
        }
        if(accountlisttoupdate.size()>0) {
            
            Database.SaveResult[] srList =database.update(accountlisttoupdate,false); 
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    System.debug('Successfully updated user. user ID: ' + sr.getId());
                }
                else {
                    
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('user fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }  
    }    
}
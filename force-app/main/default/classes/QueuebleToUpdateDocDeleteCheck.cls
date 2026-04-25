public class QueuebleToUpdateDocDeleteCheck  implements Queueable{
    
    set<id> userids = new set<id>(); 
    
    public QueuebleToUpdateDocDeleteCheck(set<id> userid) { 
        
        this.userids = userid;    
    }  
    
    public void execute(QueueableContext qc) {  
   
        list<user> userlist = new list<user>();
        for(string userid : userids){
            userlist.add(new user(doc_deleted__c=true,id=userid));
        }
        update userlist;
    }    
}
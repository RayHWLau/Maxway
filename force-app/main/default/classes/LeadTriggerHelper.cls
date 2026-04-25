public class LeadTriggerHelper {
    public static void populatestaff(list<lead> leadlist){
    list<string> userids = new list<string>();
        list<lead> leadtoupdate = new list<lead>();
        list<Staff__c> staftable = new list<Staff__c>();
        profile pro = [Select id from profile where name = 'Maxway System Administrator'];
        for(user userdetail : [select id from user where profileid = :pro.id and isactive = true]){
            userids.add(userdetail.id); 
        }
        if(userids.size()>0)
         staftable = [Select name , id from Staff__c where name ='HQ Admin' and OwnerId in :userids LIMIT 1];
        if(staftable.size()>0){
            for(lead ld : leadlist){
                if(string.isblank(ld.Case_Manager__c)){
                  leadtoupdate.add(new lead(Case_Manager__c=staftable[0].id,id=ld.id));  
                }
            }
           if(leadtoupdate.size()>0) update leadtoupdate ;
        }   
    }
    
    public static void branchofficeconflictupdate(list<lead> leadlist ,map<id, lead> triggerOldMap){
        list<lead> leadstoupdate = new list<lead>();
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Agent Acquisition').getRecordTypeId(); 
        if( avoidRecursive.isFirstRunOpp ){
            avoidRecursive.isFirstRunOpp = false;
            
            for( lead objld  : leadlist ){
                System.debug('objld-->'+objld);
                if( objld.status == 'Closed_Lost' && objld.Closed_Lost_Reason__c.contains('Branch office location overlap with Maxway\'s')){
                    lead ld = new lead();
                    ld.id = objld.id;
                    ld.Branch_Conflicts_with_Maxway__c='Yes';
                    leadstoupdate.add(ld);
                }
                if( objld.status == 'Closed_Lost' && !objld.Closed_Lost_Reason__c.contains('Branch office location overlap with Maxway\'s')){
                    lead ld = new lead();
                    ld.id = objld.id;
                    ld.Branch_Conflicts_with_Maxway__c='No';
                    leadstoupdate.add(ld);
                }
                if( objld.Branch_Conflicts_with_Maxway__c =='Yes' && objld.status != 'Closed_Lost' ){
                    lead ld = new lead();
                    ld.id = objld.id;
                    ld.status='Closed_Lost';
                    ld.Closed_Lost_Reason__c ='Branch office location overlap with Maxway\'s';
                    leadstoupdate.add(ld);
                }
            }
            if(leadstoupdate.size()>0)update leadstoupdate;
            
        }
    }
    
}
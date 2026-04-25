public class FollowupTask {
    @AuraEnabled
    public static wrapopportunitytask taskcomponentOnLoad(string recodid){
        wrapopportunitytask wraptsk = new wrapopportunitytask();
        string followuplist ='';
        Schema.DescribeFieldResult result19 = Opportunity.Follow_Up_Situation__c.getDescribe();
        List<Schema.PicklistEntry> pl19 = result19.getPicklistValues();
        for( Schema.PicklistEntry fe : pl19){
            wraptsk.FollowUpSituation.add(fe.getValue());
            followuplist = followuplist +';'+ fe.getValue();
        }
        for(StudentClosedLostReason__mdt ClosedLost : [SELECT MasterLabel,Value__c,DeveloperName FROM StudentClosedLostReason__mdt]){
            if(ClosedLost.MasterLabel == 'Opportunity')
                wraptsk.ClosedLostReason = ClosedLost.Value__c.split(',');
        }
        opportunity opp = [select Name,StageName from opportunity where id = :recodid];
        wraptsk.opp = opp;
        task tasktodisplay = new task();
        for(task tsk : [select ActivityDate,whatid,status,IsFollowUpOppTask__c,Subject from task where whatid = :recodid and status != 'Completed' order by createddate asc]){
            if(followuplist.contains(tsk.subject)){
                wraptsk.tsk = tsk; 
                break;
            }
            else{
                wraptsk.tsk = tsk;    
            }
            
        }
        
        return wraptsk;
    }
    
    @AuraEnabled
    public static wrapnexttask savetask(date duedate,string subject,string closelostreason, string followupremarks,string onholdreason,string taskid,string oppstagename){
        try{
            list<task> tasklist = [select id,Task_Owner__c,whatid,status,OwnerId from task where id = :taskid];
            
            
            if(tasklist.size()>0){
                wrapnexttask wraptask = new wrapnexttask();
                task nxttsk = new task(); 
                
                if(string.isNotBlank(subject)){
                    
                    nxttsk.WhatId = tasklist[0].whatid;
                    nxttsk.Subject = subject;
                    nxttsk.Task_Owner__c=tasklist[0].Task_Owner__c;
                    nxttsk.OwnerId=tasklist[0].ownerid;
                    nxttsk.ActivityDate=duedate;
                    nxttsk.IsFollowUpOppTask__c=true;
                    insert nxttsk;
                    
                    task curtsk = new task(); 
                    curtsk.status ='Completed';
                    curtsk.id = tasklist[0].id;
                    curtsk.Description=followupremarks;
                    update curtsk;
                    
                    opportunity opp = new opportunity();
                    opp.id = tasklist[0].whatid;
                    opp.Follow_Up_Situation__c = subject;
                    system.debug(oppstagename);
                 /*   if(oppstagename == 'On Hold'){
                        system.debug(oppstagename);
                        opp.stagename ='Prospective';   
                    }*/
                    
                    update opp;
                    
                /*    if(string.isNotBlank(onholdreason)){
                        opportunity opponhold = new opportunity();
                        opponhold.id = tasklist[0].whatid;
                        opponhold.Follow_Up_Situation__c = subject;
                        opponhold.stagename = 'On Hold';
                        update opponhold;   
                    }*/
                    
                }
                
                if(string.isBlank(subject) && oppstagename != 'Prospective' && oppstagename != 'On Hold' ){ 
                    task curtsk = new task(); 
                    curtsk.status ='Completed';
                    curtsk.id = tasklist[0].id;
                    curtsk.Description=followupremarks;
                    update curtsk;   
                }
                
                if(string.isNotBlank(closelostreason)){
                    opportunity opp = new opportunity();
                    opp.id = tasklist[0].whatid;
                    opp.stagename = 'Closed Lost';
                    update opp;
                    
                    task curtsk = new task(); 
                    curtsk.status ='Completed';
                    curtsk.id = tasklist[0].id;
                    curtsk.Description=followupremarks;
                    update curtsk;   
                }
                string followuplist ='';
                Schema.DescribeFieldResult result19 = Opportunity.Follow_Up_Situation__c.getDescribe();
                List<Schema.PicklistEntry> pl19 = result19.getPicklistValues();
                for( Schema.PicklistEntry fe : pl19){
                    followuplist = followuplist +';'+ fe.getValue();
                }
                
                for(task tsk : [select ActivityDate,whatid,status,IsFollowUpOppTask__c,Subject from task where whatid = :tasklist[0].whatid and status != 'Completed' order by createddate asc]){
                    if(followuplist.contains(tsk.subject)){
                        wraptask.tsk = tsk; 
                        break;
                    }
                    else{
                        wraptask.tsk = tsk;    
                    }
                    
                }
                wraptask.str='success';
                return wraptask; 
            }
            return null;
            
        }
        catch(DmlException e) {
            wrapnexttask wraptask = new wrapnexttask();
            wraptask.str= e.getMessage();
            return wraptask;
        }
    }
    
    public class wrapopportunitytask{
        @auraenabled
        public task tsk = new task();
        @auraenabled
        public opportunity opp = new opportunity();
        @auraenabled
        public list<string> FollowUpSituation = new list<string>();
        @auraenabled
        public list<string> ClosedLostReason = new list<string>();
    }
    public class wrapnexttask{
        @auraenabled
        public task tsk = new task();
        @auraenabled
        public string str = '';
        
    }
}
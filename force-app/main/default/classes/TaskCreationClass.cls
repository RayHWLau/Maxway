public class TaskCreationClass {
    public static final String SUBJECT_UPLOAD_PASSPORT = 'Upload transcript & passport & click submit application';
    
    public static void Opportunityrejected(list<opportunity> opplist,map<id,opportunity> oldmap){
        list<task> tasktoinsert = new list<task>();
        for(opportunity opp : opplist){
            if(opp.recordtypeid == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ConstantsClass.studentRecTypeName).getRecordTypeId() && opp.stagename=='Rejected'
               && opp.stagename != oldmap.get(opp.id).stagename){
                   
                   tasktoinsert.add(TaskCreationClass.taskcreate('All applications rejected, open future prospective opportunity with future reminder to follow up or apply another schools under this opportunity?', system.today(), opp.Id,opp.OwnerId, opp.Case_Manager__c));   
               }
        } 
        insert tasktoinsert;
    }
    //Application Creation
    public static void taskWhenapplicationcreated(list<case> caselist){
        list<task> tasktoinsert = new list<task>();
        Id recordTypeIdOptin = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Application(Opt-In)').getRecordTypeId();
        Id recordTypeIdOptOutNIN = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Application(Opt-Out/NIN/Maxway)').getRecordTypeId();
        // Added By Ravi on 29 june 2020
        
        map<string,string> mapAccountManagerSchool = new map<string,string>();
        map<string,string> mapCaseSchool = new map<string,string>();
        for( case cse : caselist ){
            mapCaseSchool.put(cse.School__c,cse.Id); 
        }
        List<Account> schList = [select Id,Account_Manager__c from Account where Id in:mapCaseSchool.keySet()];
        for(Account acc:schList){
            if(mapCaseSchool.containsKey(acc.Id)){
                mapAccountManagerSchool.put(mapCaseSchool.get(acc.Id),acc.Account_Manager__c);   
            }
        }
        // Added By Ravi on 29 june 2020
        //added on 20 may 2020 as in case of optin Renew school contract / school contract\'s should be assigned to school's owner
        /*map< Id, Account > mapSchoolIdWithOwner = new map< Id, Account > ();
        for( case cse : caselist ){
            if( String.isNotBlank( cse.School_Name2__c ) ){
                
                mapSchoolIdWithOwner.put( cse.School_Name2__c, Null );
            }
            
        }//end of case list
        mapSchoolIdWithOwner = new map< Id, Account > ( [ SELECT Id,OwnerId FROM Account WHERE Id IN : mapSchoolIdWithOwner.keySet() ] );
        */
        
        list< User >listSystemAdmin = [select id from user WHERE Profile.Name = 'Maxway System Administrator' ]; 
        system.debug('listSystemAdmin ---> ' + listSystemAdmin);
        for(case cse : caselist){
            if(cse.recordtypeid == recordTypeIdOptin){ 
                if(cse.Agent_Application_Manager__c !=null)
                    tasktoinsert.add(TaskCreationClass.taskcreate(SUBJECT_UPLOAD_PASSPORT, system.today(), cse.Id,cse.OwnerId, cse.Agent_Application_Manager__c));
                
                //added on 18 may 2020 NTF-0728 now for Optin as well this task should go.
                /*
                if(cse.Maxway_Application_Manager__c !=null){
                    tasktoinsert.add(TaskCreationClass.taskcreate('An application is in for this marketing contract, check quota', system.today() , cse.Id, cse.OwnerId, cse.Maxway_Application_Manager__c));
                    tasktoinsert.add(TaskCreationClass.taskcreate('Renew school contract / school contract\'s valid  & check if school allows parallel process of application & contract', system.today() , cse.Id, cse.OwnerId, cse.Maxway_Application_Manager__c));
                }*/
                
                //added on 20 may 2020
                //now it will go to system admin
                if( listSystemAdmin.size() > 0  && cse.Maxway_Application_Manager__c !=null){
                    tasktoinsert.add(TaskCreationClass.taskcreate('An application is in for this marketing contract, check quota', system.today() , cse.Id, listSystemAdmin[0].Id,mapAccountManagerSchool.containsKey(cse.Id)?mapAccountManagerSchool.get(cse.Id):NULL /*cse.Maxway_Application_Manager__c*/));
                    tasktoinsert.add(TaskCreationClass.taskcreate('Renew school contract / school contract\'s valid  & check if school allows parallel process of application & contract', system.today() , cse.Id, listSystemAdmin[0].Id,mapAccountManagerSchool.containsKey(cse.Id)?mapAccountManagerSchool.get(cse.Id):NULL /*cse.Maxway_Application_Manager__c*/));
                }
                //end may 2020
            }
            if(cse.recordtypeid == recordTypeIdOptOutNIN){
                if(cse.Maxway_Application_Manager__c !=null){
                    //Commented on 17 June 2020 as per NTF - 0035 only for optin application, tassk should create.
                    //tasktoinsert.add(TaskCreationClass.taskcreate('Upload Passport and Transcript', system.today() , cse.Id, cse.OwnerId, cse.Maxway_Application_Manager__c));
                    tasktoinsert.add(TaskCreationClass.taskcreate('Renew school contract / school contract\'s valid  & check if school allows parallel process of application & contract', system.today() , cse.Id, cse.OwnerId,mapAccountManagerSchool.containsKey(cse.Id)?mapAccountManagerSchool.get(cse.Id):NULL /*cse.Maxway_Application_Manager__c*/));
                    tasktoinsert.add(TaskCreationClass.taskcreate('An application is in for this marketing contract, check quota', system.today() , cse.Id, cse.OwnerId,mapAccountManagerSchool.containsKey(cse.Id)?mapAccountManagerSchool.get(cse.Id):NULL /* cse.Maxway_Application_Manager__c*/));
                }
                if(cse.Agent_Application_Manager__c !=null){
                    //Commented on 17 June 2020 as per NTF - 0035 only for optin application, tassk should create.
                    //tasktoinsert.add(TaskCreationClass.taskcreate('Upload Passport and Transcript', system.today() , cse.Id, cse.OwnerId, cse.Agent_Application_Manager__c));
                }
            }
        }
        
        
        if(tasktoinsert.size()>0){
            insert tasktoinsert;
        }     
       
    }
    
    //@Priyanka Sharma - 30 March 2020
    //Application(Opt-In) Deposit Paid Date Not Null
     public static void taskWhenDepositPaidDateNotNull(list<case> caselist){
         list<task> tasktoinsert = new list<task>();
        // Added By Ravi on 29 june 2020
        User usr =[select Id from User where Profile.Name='Maxway System Administrator'];
        // Added By Ravi on 29 june 2020
        Id recordTypeIdOptIN = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Application(Opt-In)').getRecordTypeId();
        system.debug('recordTypeIdOptIN'+recordTypeIdOptIN);
        for(case cse : caselist){
            if(cse.Deposit_Paid_Date__c != null){
                system.debug('cse.recordtypeid'+cse.recordtypeid);
                if(cse.recordtypeid == recordTypeIdOptIN){
                    
                    //changes in 17 June 2020 as these task are repeatly created after record gets update , so fixing this.
                    //if(cse.Maxway_Application_Manager__c !=null){ //old condition
                    //tasktoinsert.add(TaskCreationClass.taskcreate('Upload Unconditional Offer', cse.Deposit_Paid_Date__c.addDays(7) , cse.Id, cse.OwnerId, cse.Maxway_Application_Manager__c));
                    //}
                    
                    if( trigger.isInsert && cse.Maxway_Application_Manager__c !=null){
                        tasktoinsert.add(TaskCreationClass.taskcreate('Upload Unconditional Offer', cse.Deposit_Paid_Date__c.addDays(7) , cse.Id,usr.Id /*cse.OwnerId*/, cse.Maxway_Application_Manager__c));
                       
                    }
                    
                    //added 17 June 2020
                    if( trigger.isUpdate ){
                        
                        Case oldCaseValues = ( ( map< Id, Case >) trigger.oldMap ).get( cse.Id );
                        
                        if( cse.Maxway_Application_Manager__c !=null && cse.Deposit_Paid_Date__c != null && cse.Deposit_Paid_Date__c != oldCaseValues.Deposit_Paid_Date__c ){
                        tasktoinsert.add(TaskCreationClass.taskcreate('Upload Unconditional Offer', cse.Deposit_Paid_Date__c.addDays(7) , cse.Id, usr.Id /*cse.OwnerId*/, cse.Maxway_Application_Manager__c));
                       
                    }
                    }
                }
            }
        }   
        
        if(tasktoinsert.size()>0) {
            insert tasktoinsert;
        } 
    }
    
    //@Priyanka Sharma - 30 March 2020
    //Application(Opt-Out/NIN/Maxway) Other Conditions is Yes
    public static void taskWhenOtherConditionYes(list<case> caselist){
     /*   list<task> tasktoinsert = new list<task>();
        string taskOwner='';
        
        Id recordTypeIdOptOutNIN = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Application(Opt-Out/NIN/Maxway)').getRecordTypeId();
        
        for(case cse : caselist){
            if(cse.Other_Conditions__c == 'Yes'){
                
                if(cse.recordTypeId == recordTypeIdOptOutNIN){
                    if(cse.Application_Type__c=='Maxway Application' && cse.Maxway_Application_Manager__c !=null){
                        taskOwner=cse.Maxway_Application_Manager__c;
                    }
                    else if(cse.Application_Type__c!='Maxway Application' && cse.Agent_Application_Manager__c !=null)
                    {
                        taskOwner=cse.Agent_Application_Manager__c;
                    }
                   
                    if(taskOwner!=null || String.isNotEmpty(taskOwner)){
                      tasktoinsert.add(TaskCreationClass.taskcreate('when client can fulfill other conditions?', system.today() , cse.Id, cse.OwnerId, taskOwner));  
                    }
                     
                }
            }
        }   
        
        if(tasktoinsert.size()>0) {
            insert tasktoinsert;
        } */
    }
    
    //Application Offer Not Null
   /* public static void taskWhenOfferTypeNotNull(list<case> caselist,map<id,case> oldmap){
        
        list<task> tasktoinsert = new list<task>();
        
        Id recordTypeIdOptOutNIN = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Application(Opt-Out/NIN/Maxway)').getRecordTypeId();
        
        for(case cse : caselist){
            if(cse.Offer__c != null  && oldmap.get(cse.id).Other_Conditions__c == null){
                
                if(cse.recordtypeid == recordTypeIdOptOutNIN){
                    if(cse.Agent_Application_Manager__c !=null){
                        tasktoinsert.add(TaskCreationClass.taskcreate('when to meet conditions / firm offer?', system.today() , cse.Id, cse.OwnerId, cse.Agent_Application_Manager__c));
                        /*  tasktoinsert.add(TaskCreationClass.taskcreate('update deposit paid date to system', cse.Deposit_Due_date__c.adddays(-7), cse.Id, cse.OwnerId, cse.Maxway_Application_Manager__c));*/
                  //  }
                    /*   if(cse.Agent_Application_Manager__c !=null){
tasktoinsert.add(TaskCreationClass.taskcreate('Chase Deposit', system.today() , cse.Id, cse.OwnerId, cse.Agent_Application_Manager__c));
tasktoinsert.add(TaskCreationClass.taskcreate('update deposit paid date to system',cse.Deposit_Due_date__c.adddays(-7), cse.Id, cse.OwnerId, cse.Agent_Application_Manager__c));
}*/
              /*  }
            }
        }   
        
        if(tasktoinsert.size()>0) insert tasktoinsert; 
    }*/
    
    // Application Creation  Other Conditions YES OR MET Conditions
    public static void taskWhenClientCanfullfillOtherConditions(list<case> caselist,map<id,case> oldmap){
        
        list<task> tasktoinsert = new list<task>();
        
        Id recordTypeIdOptOutNIN = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Application(Opt-Out/NIN/Maxway)').getRecordTypeId();
        
        for(case cse : caselist){
            if(cse.Other_Conditions__c=='Yes' && cse.Other_Conditions__c != oldmap.get(cse.id).Other_Conditions__c){
                
                if(cse.recordtypeid == recordTypeIdOptOutNIN){
                    if(cse.Agent_Application_Manager__c !=null){
                        tasktoinsert.add(TaskCreationClass.taskcreate('when client can fulfill other conditions?', system.today() , cse.Id, cse.OwnerId, cse.Agent_Application_Manager__c));
                        //tasktoinsert.add(TaskCreationClass.taskcreate('collect unconditional offer, define visa required', system.today() , cse.Id, cse.OwnerId, cse.Agent_Application_Manager__c));
                    }
                    // Added on 25 march 2020 ,Extra condition (Met_Conditions__c) for the task collect unconditional offer, define visa required
                    if(cse.Agent_Application_Manager__c !=null && cse.Met_Conditions__c==true){
                        tasktoinsert.add(TaskCreationClass.taskcreate('collect unconditional offer, define visa required', system.today() , cse.Id, cse.OwnerId, cse.Agent_Application_Manager__c));
                    }
                    if(cse.Maxway_Application_Manager__c !=null && cse.Met_Conditions__c==true){
                        tasktoinsert.add(TaskCreationClass.taskcreate('collect unconditional offer, define visa required', system.today() , cse.Id, cse.OwnerId, cse.Agent_Application_Manager__c));
                    }
                    if(cse.Maxway_Application_Manager__c !=null){
                        tasktoinsert.add(TaskCreationClass.taskcreate('when client can fulfill other conditions?', system.today() , cse.Id, cse.OwnerId, cse.Maxway_Application_Manager__c));
                        //tasktoinsert.add(TaskCreationClass.taskcreate('collect unconditional offer, define visa required', system.today() , cse.Id, cse.OwnerId, cse.Maxway_Application_Manager__c));
                    }
                    
                }
            }
        }   
        
        if(tasktoinsert.size()>0) insert tasktoinsert; 
    }
    
    //Application Deposit Amount != 0
    public static void taskWhendepositfilled(list<case> caselist,map<id,case> oldmap){
        list<string> userids = new list<string>();
        list<task> tasktoinsert = new list<task>();
        map<string,string> mapschoolwithmanager = new map<string,string>();
        profile pro = [Select id from profile where name = 'Maxway System Administrator'];
        for(user userdetail : [select id from user where profileid = :pro.id and isactive = true]){
            userids.add(userdetail.id); 
        }
        Id recordTypeIdOptin = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Application(Opt-In)').getRecordTypeId();
        Id recordTypeIdOptOutNIN = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Application(Opt-Out/NIN/Maxway)').getRecordTypeId();
        if(userids.size()>0){
            for(case cse : caselist){
                if(cse.Deposit_Amount__c != 0 && cse.Deposit_Amount__c != oldmap.get(cse.id).Deposit_Amount__c){
                    if(cse.recordtypeid == recordTypeIdOptin){
                        if(cse.Maxway_Application_Manager__c !=null)
                            tasktoinsert.add(TaskCreationClass.taskcreate('where’s deposit',cse.Deposit_Due_date__c.adddays(-7), cse.Id, userids[0], cse.Maxway_Application_Manager__c)); 
                        if(cse.Agent_Application_Manager__c !=null)
                            tasktoinsert.add(TaskCreationClass.taskcreate('Chase Deposit', system.today(), cse.Id,cse.OwnerId, cse.Agent_Application_Manager__c));
                    }
                    if(cse.recordtypeid == recordTypeIdOptOutNIN){
                        if(cse.Maxway_Application_Manager__c !=null){
                            //@ commented by Gitika w.r.t to NTF-384
                          //  tasktoinsert.add(TaskCreationClass.taskcreate('send deposit proof to school, chase offer', system.today() , cse.Id, cse.OwnerId, cse.Maxway_Application_Manager__c));
                            tasktoinsert.add(TaskCreationClass.taskcreate('Chase Deposit', system.today() , cse.Id, cse.OwnerId, cse.Maxway_Application_Manager__c));
                            tasktoinsert.add(TaskCreationClass.taskcreate('update deposit paid date to system', cse.Deposit_Due_date__c.adddays(-7), cse.Id, cse.OwnerId, cse.Maxway_Application_Manager__c));
                        }
                        if(cse.Agent_Application_Manager__c !=null){
                            //@ commented by Gitika w.r.t to NTF-384
                           //  tasktoinsert.add(TaskCreationClass.taskcreate('send deposit proof to school, chase offer', system.today() , cse.Id, cse.OwnerId, cse.Agent_Application_Manager__c));
                            tasktoinsert.add(TaskCreationClass.taskcreate('Chase Deposit', system.today() , cse.Id, cse.OwnerId, cse.Agent_Application_Manager__c));
                            tasktoinsert.add(TaskCreationClass.taskcreate('update deposit paid date to system',cse.Deposit_Due_date__c.adddays(-7), cse.Id, cse.OwnerId, cse.Agent_Application_Manager__c));
                        }
                    }
                }
            }   
        }
        if(tasktoinsert.size()>0) insert tasktoinsert; 
    }
    //Application stage Pending Arrival
    public static void taskWhenpendingArrival(list<case> caselist,map<id,case> oldmap){
        list<string> userids = new list<string>();
        //@ added by gitika
        map<string,string> mapofOfPortalUseridWithAccountId = new map<string,string>();
        map<string,string> mapofOfPortalUserAccountIdWithHQAdminId = new map<string,string>();
        list<string> accountids = new list<string>();
        
        list<task> tasktoinsert = new list<task>();
        list<Staff__c> staftable = new list<Staff__c>();
        Set<String> applicationStage = new Set<String>{'Preparing application','Application Submitted to School','"Pending Student Confirmation','Visa In Progress'};
        map<string,integer> mapcasecaseinoneoppOutin = new map<string,integer>();
            // Added By Ravi this will added filter in child query where
        
        map<string,integer> mapcasewithtotalcaseinoneopp = new map<string,integer>();
        for(case cs : caselist){
            if(cs.Opportunity__c!=null){
                mapcasewithtotalcaseinoneopp.put(cs.Opportunity__c,null);
                mapofOfPortalUseridWithAccountId.put(cs.ownerid,null);
            }  
        }
        //----> @ added by gitika
        for(user us : [select AccountId,id from user where id in:mapofOfPortalUseridWithAccountId.keyset()]){
            if(us.AccountId != null){
                mapofOfPortalUseridWithAccountId.put(us.id,string.valueof(us.AccountId).left(15));
            } 
        }
        
        for(staff__c st : [select id ,OwnerAccountId__c from staff__c where ownerid in :mapofOfPortalUseridWithAccountId.keyset()]){
            if(st.OwnerAccountId__c != null)
            mapofOfPortalUserAccountIdWithHQAdminId.put(st.OwnerAccountId__c,st.id);
        }
        
       //<---- 
        for(opportunity opp : [select id,(select id from applications__r) from opportunity where id in : mapcasewithtotalcaseinoneopp.keyset()]){
            mapcasewithtotalcaseinoneopp.put(opp.id,opp.applications__r.size());
        }
        for(opportunity opp : [select id,(select id from applications__r where Stage__c  in:applicationStage) from opportunity where id in : mapcasewithtotalcaseinoneopp.keyset()]){
            mapcasecaseinoneoppOutin.put(opp.id,opp.applications__r.size());
        }
        for(user userdetail : [select id from user where profile.name = 'Maxway System Administrator' and isactive = true]){
            userids.add(userdetail.id); 
        }
        Id recordTypeIdOptin = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Application(Opt-In)').getRecordTypeId();
        Id recordTypeIdOptOutNIN = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Application(Opt-Out/NIN/Maxway)').getRecordTypeId();
        if(userids.size()>0){
            staftable = [Select name , id from Staff__c where name ='HQ Admin' and OwnerId in :userids LIMIT 1];
            if(staftable.size()>0){
                for(case cse : caselist){
                    if(string.valueof(cse.stage__c) =='Pending Arrival' && cse.stage__c != oldmap.get(cse.id).stage__c){
                        if(cse.recordtypeid == recordTypeIdOptin){
                            if(cse.Maxway_Application_Manager__c !=null && mapcasewithtotalcaseinoneopp.containskey(cse.Opportunity__c)){
                                if(mapcasewithtotalcaseinoneopp.get(cse.Opportunity__c) == 1){
                                    tasktoinsert.add(TaskCreationClass.taskcreate('Prepare Commission', system.today(), cse.Id, userids[0], staftable[0].id));
                                    // @gitika w.r.t NTF-494
                                    tasktoinsert.add(TaskCreationClass.taskcreate('housing, pick up / orientation', system.today(), cse.Id, userids[0], cse.Maxway_Application_Manager__c));
                                }
                                else{
                                    tasktoinsert.add(TaskCreationClass.taskcreate('after knowing which school the student will go, reject other applicationst', system.today(), cse.Id, userids[0], cse.Maxway_Application_Manager__c));
                                   // @gitika w.r.t NTF-494
                                    tasktoinsert.add(TaskCreationClass.taskcreate('housing, pick up / orientation', system.today(), cse.Id, userids[0], cse.Maxway_Application_Manager__c));
                                    tasktoinsert.add(TaskCreationClass.taskcreate('Prepare Commission', system.today(), cse.Id, userids[0], staftable[0].id));
                                }
                                
                            }
                            
                            if(cse.Agent_Application_Manager__c !=null && mapcasewithtotalcaseinoneopp.containskey(cse.Opportunity__c)){
                                if(mapcasewithtotalcaseinoneopp.get(cse.Opportunity__c) == 1){
                                    //  tasktoinsert.add(TaskCreationClass.taskcreate('Prepare Commission', system.today(), cse.Id, userids[0], staftable[0].id));
                                    tasktoinsert.add(TaskCreationClass.taskcreate('housing and arrival arrangement', system.today(), cse.Id,cse.OwnerId, cse.Agent_Application_Manager__c));  
                                }
                                else{
                                    tasktoinsert.add(TaskCreationClass.taskcreate('can only claim commission on 1 application, pls reject others', system.today(), cse.Id, cse.OwnerId,  cse.Agent_Application_Manager__c));
                                    // tasktoinsert.add(TaskCreationClass.taskcreate('check which school this student arrived & change application status', system.today(), cse.Id, cse.OwnerId,  cse.Agent_Application_Manager__c));
                                    // @gitika w.r.t NTF-494 
                                    tasktoinsert.add(TaskCreationClass.taskcreate('housing and arrival arrangement', system.today(), cse.Id,cse.OwnerId, cse.Agent_Application_Manager__c));
                                } 
                            } 
                        }
                        if(cse.recordtypeid == recordTypeIdOptOutNIN){
                            system.debug(cse.Opportunity__c);
                            if(cse.Maxway_Application_Manager__c !=null && mapcasewithtotalcaseinoneopp.containskey(cse.Opportunity__c)){
                                if(mapcasecaseinoneoppOutin.get(cse.Opportunity__c) < 1){
                                    tasktoinsert.add(TaskCreationClass.taskcreate('Prepare Commission', system.today(), cse.Id, userids[0], staftable[0].id));
                                    tasktoinsert.add(TaskCreationClass.taskcreate('housing and arrival arrangement', system.today(), cse.Id,userids[0],staftable[0].id));
                                }
                                else{
                                    tasktoinsert.add(TaskCreationClass.taskcreate('which applications to reject', system.today(), cse.Id, userids[0], cse.Maxway_Application_Manager__c));
                                }
                                // Added By Ravi on 30 March 2020
                                Staff__c staff = [Select name , id from Staff__c where name ='HQ Admin' Limit 1 ];
                                if(mapcasecaseinoneoppOutin.get(cse.Opportunity__c) >=1){
                                 //  tasktoinsert.add(TaskCreationClass.taskcreate('Which application to reject', system.today(), cse.Id, userids[0], staftable[0].id));
                                    tasktoinsert.add(TaskCreationClass.taskcreate('Housing and Arrival Arrangement', system.today(), cse.Id,userids[0],staftable[0].id));
                                    tasktoinsert.add(TaskCreationClass.taskcreate('Prepare Commission', system.today(), cse.Id, userids[0], staff.Id));
                                   
                                }
                                
                            }
                            if(cse.Agent_Application_Manager__c !=null && mapcasewithtotalcaseinoneopp.containskey(cse.Opportunity__c)){
                                if(mapcasecaseinoneoppOutin.get(cse.Opportunity__c) < 1){
                                    //  tasktoinsert.add(TaskCreationClass.taskcreate('Prepare Commission', system.today(), cse.Id, userids[0], staftable[0].id));
                                    tasktoinsert.add(TaskCreationClass.taskcreate('housing and arrival arrangement', system.today(), cse.Id,cse.OwnerId, cse.Agent_Application_Manager__c));
                                    if(mapofOfPortalUseridWithAccountId.containskey(cse.OwnerId)){
                                        if(mapofOfPortalUserAccountIdWithHQAdminId.containskey(mapofOfPortalUseridWithAccountId.get(cse.OwnerId))){
                                      tasktoinsert.add(TaskCreationClass.taskcreate('Commission', system.today(), cse.Id,cse.OwnerId, mapofOfPortalUserAccountIdWithHQAdminId.get(mapofOfPortalUseridWithAccountId.get(cse.OwnerId))));      
                                        }
                                    }
                                    
                                }
                                else{
                                    tasktoinsert.add(TaskCreationClass.taskcreate('can only claim commission on 1 application, pls reject others', system.today(), cse.Id, cse.OwnerId,  cse.Agent_Application_Manager__c));
                                    tasktoinsert.add(TaskCreationClass.taskcreate('check which school this student arrived & change application status', system.today(), cse.Id, cse.OwnerId,  cse.Agent_Application_Manager__c));
                                    tasktoinsert.add(TaskCreationClass.taskcreate('housing and arrival arrangement', system.today(), cse.Id,cse.OwnerId, cse.Agent_Application_Manager__c));
                                }
                                // Added By Ravi on 30 March 2020
                                //Staff__c staff = [Select name , id from Staff__c where name ='HQ Admin' Limit 1 ];
                                /*if(mapcasecaseinoneoppOutin.get(cse.Opportunity__c) >=1){
                                    tasktoinsert.add(TaskCreationClass.taskcreate('Which application to reject', system.today(), cse.Id, userids[0], staftable[0].id));
                                    tasktoinsert.add(TaskCreationClass.taskcreate('Housing and Arrival Arrangement', system.today(), cse.Id,userids[0],staftable[0].id));
                                    tasktoinsert.add(TaskCreationClass.taskcreate('Prepare Commission', system.today(), cse.Id, userids[0],staff.Id));
                                }*/
                            }
                        }
                    }  
                }
                if(tasktoinsert.size()>0) insert tasktoinsert;
            }
        }  
    }
    
    //Application stage Visa In progress
    public static void taskWhenVisaInprogress(list<case> caselist,map<id,case> oldmap){
        list<string> userids = new list<string>();
        list<task> tasktoinsert = new list<task>();
        map<string,string> mapschoolwithmanager = new map<string,string>();
        profile pro = [Select id from profile where name = 'Maxway System Administrator'];
        for(user userdetail : [select id from user where profileid = :pro.id and isactive = true]){
            userids.add(userdetail.id); 
        }
        Id recordTypeIdOptin = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Application(Opt-In)').getRecordTypeId();
        Id recordTypeIdOptOutNIN = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Application(Opt-Out/NIN/Maxway)').getRecordTypeId();
        if(userids.size()>0){
            for(case cse : caselist){
                if(string.valueof(cse.stage__c) =='Visa In Progress' && cse.stage__c != oldmap.get(cse.id).stage__c){
                    if(cse.recordtypeid == recordTypeIdOptin){
                        if(cse.Maxway_Application_Manager__c !=null){
                            tasktoinsert.add(TaskCreationClass.taskcreate('when to submit visa', system.today().addmonths(3), cse.Id, userids[0], cse.Maxway_Application_Manager__c)); 
                            tasktoinsert.add(TaskCreationClass.taskcreate('Input Visa Decision to system', system.today().addmonths(1), cse.Id, userids[0], cse.Maxway_Application_Manager__c)); 
                        }
                        
                        if(cse.Agent_Application_Manager__c !=null)
                            tasktoinsert.add(TaskCreationClass.taskcreate('Do Visa', system.today(), cse.Id,cse.OwnerId, cse.Agent_Application_Manager__c));
                    }
                    if(cse.recordtypeid == recordTypeIdOptOutNIN){
                        if(cse.Maxway_Application_Manager__c !=null){
                            //  tasktoinsert.add(TaskCreationClass.taskcreate('Do Visa', system.today(), cse.Id, cse.OwnerId, cse.Maxway_Application_Manager__c)); 
                            tasktoinsert.add(TaskCreationClass.taskcreate('Client needs Visa service?', system.today(), cse.Id, cse.OwnerId,cse.Maxway_Application_Manager__c)); 
                            tasktoinsert.add(TaskCreationClass.taskcreate('Input Visa Decision to system', system.today().addmonths(1), cse.Id,cse.OwnerId, cse.Maxway_Application_Manager__c));
                        }
                        
                        if(cse.Agent_Application_Manager__c !=null){
                            tasktoinsert.add(TaskCreationClass.taskcreate('Do Visa', system.today(), cse.Id, cse.OwnerId, cse.Agent_Application_Manager__c));
                            /* tasktoinsert.add(TaskCreationClass.taskcreate('when to submit visa', system.today().addmonths(3), cse.Id, cse.OwnerId,cse.Agent_Application_Manager__c));*/
                            // @Gitika uncommented w.r.t NTF - 414
                            tasktoinsert.add(TaskCreationClass.taskcreate('Update Visa Decision', system.today().addmonths(1), cse.Id,cse.OwnerId, cse.Agent_Application_Manager__c));
                        }
                    }
                }
            }   
        }
        if(tasktoinsert.size()>0) insert tasktoinsert; 
    }
    
    //Application Submitted to school date is filled
    public static void taskWhensubmittedtoschooldateisfilled(list<case> caselist,map<id,case> oldmap){
        list<string> userids = new list<string>();
        list<task> tasktoinsert = new list<task>();
        map<string,string> mapschoolwithmanager = new map<string,string>();
        profile pro = [Select id from profile where name = 'Maxway System Administrator'];
        for(user userdetail : [select id from user where profileid = :pro.id and isactive = true]){
            userids.add(userdetail.id); 
        }
        Id recordTypeIdOptin = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Application(Opt-In)').getRecordTypeId();
        Id recordTypeIdOptOutNIN = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Application(Opt-Out/NIN/Maxway)').getRecordTypeId();
        if(userids.size()>0){
            for(case cse : caselist){
                if(string.isNotBlank(string.valueof(cse.Submit_Application_to_School_Date__c)) && cse.Submit_Application_to_School_Date__c != oldmap.get(cse.id).Submit_Application_to_School_Date__c){
                    if(cse.recordtypeid == recordTypeIdOptin){
                        if(cse.Maxway_Application_Manager__c !=null){
                            // replaced-- added 7 days in  task due date after the Submit Application To School Date on 25th march 2020
                            tasktoinsert.add(TaskCreationClass.taskcreate('Follow Up Offer', cse.Submit_Application_to_School_Date__c.adddays(7), cse.Id, userids[0], cse.Maxway_Application_Manager__c));   
                        }
                        if(cse.Agent_Application_Manager__c !=null)
                            tasktoinsert.add(TaskCreationClass.taskcreate('Follow up Offer with Maxway application manager', system.today().adddays(14), cse.Id,cse.OwnerId, cse.Agent_Application_Manager__c));
                    }
                    if(cse.recordtypeid == recordTypeIdOptOutNIN){
                        if(cse.Maxway_Application_Manager__c !=null)
                            tasktoinsert.add(TaskCreationClass.taskcreate('Follow Up Offer', cse.Submit_Application_to_School_Date__c.adddays(7), cse.Id, cse.OwnerId, cse.Maxway_Application_Manager__c));
                        if(cse.Agent_Application_Manager__c !=null)
                            tasktoinsert.add(TaskCreationClass.taskcreate('Follow Up Offer', cse.Submit_Application_to_School_Date__c.adddays(7), cse.Id, cse.OwnerId, cse.Agent_Application_Manager__c)); 
                    }
                }
            }   
        }
        if(tasktoinsert.size()>0) insert tasktoinsert;
    }
    
    
    //Application Stage Pending Student Confirmation changed to paid date
    public static void taskWhenstagependingstudentconformation(list<case> caselist,map<id,case> oldmap){
        list<string> userids = new list<string>();
        list<task> tasktoinsert = new list<task>();
        map<string,string> mapschoolwithmanager = new map<string,string>();
        profile pro = [Select id from profile where name = 'Maxway System Administrator'];
        for(user userdetail : [select id from user where profileid = :pro.id and isactive = true]){
            userids.add(userdetail.id); 
        }
        Id recordTypeIdOptin = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Application(Opt-In)').getRecordTypeId();
        Id recordTypeIdOptOutNIN = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Application(Opt-Out/NIN/Maxway)').getRecordTypeId();
        if(userids.size()>0){
            for(case cse : caselist){
                if( cse.Deposit_Paid_Date__c!=null && cse.Deposit_Paid_Date__c != oldmap.get(cse.id).Deposit_Paid_Date__c){
                    if(cse.recordtypeid == recordTypeIdOptin){
                        if(cse.Maxway_Application_Manager__c !=null)
                            tasktoinsert.add(TaskCreationClass.taskcreate('Send deposit proof to school, chase offer', system.today(), cse.Id, userids[0], cse.Maxway_Application_Manager__c)); 
                        //if(cse.Agent_Application_Manager__c !=null)
//tasktoinsert.add(TaskCreationClass.taskcreate('Send deposit proof to school, chase offer', system.today(), cse.Id,cse.OwnerId, cse.Agent_Application_Manager__c));
                    }
                    if(cse.recordtypeid == recordTypeIdOptOutNIN){
                        if(cse.Maxway_Application_Manager__c !=null)
                            tasktoinsert.add(TaskCreationClass.taskcreate('Send deposit proof to school, chase offer', system.today(), cse.Id, cse.OwnerId, cse.Maxway_Application_Manager__c));
                        if(cse.Agent_Application_Manager__c !=null)
                            tasktoinsert.add(TaskCreationClass.taskcreate('Send deposit proof to school, chase offer', system.today(), cse.Id, cse.OwnerId, cse.Agent_Application_Manager__c)); 
                    }
                }
            }   
        }
        if(tasktoinsert.size()>0) insert tasktoinsert;
    }
    
    //Application Opt-In Approval
    public static void taskCreationWhenOptInApplicationForApproval(list<case> caselist,map<id,case> oldmap){
        list<string> userids = new list<string>();
        list<task> tasktoinsert = new list<task>();
        map<string,string> mapschoolwithmanager = new map<string,string>();
        profile pro = [Select id from profile where name = 'Maxway System Administrator'];
        for(user userdetail : [select id from user where profileid = :pro.id and isactive = true]){
            userids.add(userdetail.id); 
        }
        
        if(userids.size()>0){
            for(case cs : caselist){
                mapschoolwithmanager.put(cs.School__c,null);  
            }
            for(account acc : [select account_manager__c from account where id in :mapschoolwithmanager.keyset()]){
                mapschoolwithmanager.put(acc.id,acc.account_manager__c);  
            }
            for(case acc : caselist){
                if(acc.Approval_Status__c=='Pending' && acc.Approval_Status__c !=oldmap.get(acc.id).Approval_Status__c && string.isNotBlank(acc.Maxway_Application_Manager__c)){
                    tasktoinsert.add(TaskCreationClass.taskcreate('check admissibility & if school offering matches expectation, collect other application docs', system.today(), acc.Id, userids[0], acc.Maxway_Application_Manager__c));
                    if(mapschoolwithmanager.containskey(acc.School__c)){
                        if(mapschoolwithmanager.get(acc.School__c)!=null){
                           // tasktoinsert.add(TaskCreationClass.taskcreate('Renew School Contract and / or Contract Type & check if school allows parallel processing of application & contract / contract is valid', system.today(), acc.Id, userids[0],mapschoolwithmanager.get(acc.School__c))); //... Commented by Ravi as dicussed with neha... 7 aug 2020 
                           // tasktoinsert.add(TaskCreationClass.taskcreate('An application is in for this marketing contract, check quota', system.today(), acc.Id, userids[0], mapschoolwithmanager.get(acc.School__c)));//Commented on 29 june 2020
                        }
                    }
                    
                }
                if(acc.Approval_Status__c=='Approved' && acc.Approval_Status__c !=oldmap.get(acc.id).Approval_Status__c && string.isNotBlank(acc.Maxway_Application_Manager__c) && string.isNotBlank(acc.Agent_Application_Manager__c)){
                    //   tasktoinsert.add(TaskCreationClass.taskcreate('Application Approved', system.today(), acc.Id, userids[0],acc.Maxway_Application_Manager__c));
                    tasktoinsert.add(TaskCreationClass.taskcreate('Application Approved', system.today(), acc.Id, acc.OwnerId,acc.Agent_Application_Manager__c));                
                }
                if(acc.Approval_Status__c=='Rejected' && acc.Approval_Status__c !=oldmap.get(acc.id).Approval_Status__c && string.isNotBlank(acc.Maxway_Application_Manager__c) && string.isNotBlank(acc.Agent_Application_Manager__c)){
                    // tasktoinsert.add(TaskCreationClass.taskcreate('Application Rejected', system.today(), acc.Id, userids[0],acc.Maxway_Application_Manager__c));
                    tasktoinsert.add(TaskCreationClass.taskcreate('Application Rejected', system.today(), acc.Id, acc.OwnerId,acc.Agent_Application_Manager__c));                
                }
            }
            if(tasktoinsert.size()>0) insert tasktoinsert;
        }    
    }
    
    //Application Opt-IN Rejected
    public static set< Id > setRecursiveCheckAccnt = new set< Id >();
    public static void taskCreationWhenNINapproverejected(list<account> acclist, map<id,account> accmap){
        list<string> userids = new list<string>();
        list<task> tasktoinsert = new list<task>();
        list<Staff__c> staftable = new list<Staff__c>();
        list< Account > listValidAccnt = new List< Account >();
        for( Account acc : acclist ){
            
            if( !setRecursiveCheckAccnt.contains( acc.id )){
                listValidAccnt.add(acc);
            }
        }
        system.debug('@@@@@listValidAccnt.size() --> ' + listValidAccnt.size());
        if( listValidAccnt.size() == 0 ) return;
        
        profile pro = [Select id from profile where name = 'Maxway System Administrator'];
        for(user userdetail : [select id from user where profileid = :pro.id and isactive = true]){
            userids.add(userdetail.id); 
        }
        if(userids.size()>0){
            staftable = [Select name , id from Staff__c where name ='HQ Admin' and OwnerId in :userids LIMIT 1];
            if(staftable.size()>0){
                for(account acc:listValidAccnt){//acclist
                    if(acc.Approval_Status__c=='Pending' && acc.Approval_Status__c !=accmap.get(acc.id).Approval_Status__c){
                        tasktoinsert.add(TaskCreationClass.taskcreate('NIN School Follow & approve/deny NIN', system.today(), acc.Id, userids[0], staftable[0].id));
                        setRecursiveCheckAccnt.add(acc.Id);
                    }
                    if(acc.Approval_Status__c=='Approved' && acc.Approval_Status__c !=accmap.get(acc.id).Approval_Status__c){
                        tasktoinsert.add(TaskCreationClass.taskcreate('Covert NIN & create M- school account', system.today(), acc.Id, userids[0], staftable[0].id));
                        tasktoinsert.add(TaskCreationClass.taskcreate('Account Approved', system.today(), acc.Id, acc.OwnerId,acc.Account_Manager__c)); 
                        setRecursiveCheckAccnt.add(acc.Id);
                    }
                    if(acc.Approval_Status__c=='Rejected' && acc.Approval_Status__c !=accmap.get(acc.id).Approval_Status__c){
                        tasktoinsert.add(TaskCreationClass.taskcreate('NIN school Rejected', system.today(), acc.Id, userids[0], staftable[0].id));
                        tasktoinsert.add(TaskCreationClass.taskcreate('Account Rejected', system.today(), acc.Id, acc.OwnerId,acc.Account_Manager__c));  
                        setRecursiveCheckAccnt.add(acc.Id);
                    }
                    setRecursiveCheckAccnt.add(acc.Id);
                }
                if(tasktoinsert.size()>0) insert tasktoinsert;
            }
        }
    }
    //Application when Student_Confirm_Offer__c = yes
    public static void taskWhenstudentconforminterview(list<case> caselist,map<id,case> oldmap){
        /* commneted on 20 may 2020 as we are creating same task on another creteria
        list<string> userids = new list<string>();
        list<task> tasktoinsert = new list<task>();
        
        Id recordTypeIdOptin = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Application(Opt-In)').getRecordTypeId();
        Id recordTypeIdOptOutNIN = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Application(Opt-Out/NIN/Maxway)').getRecordTypeId();
        
        for(case cse : caselist){
            if( cse.Student_Confirm_Offer__c =='Yes' && cse.Stage__c != oldmap.get(cse.id).Stage__c){
                if(cse.recordtypeid == recordTypeIdOptin){ 
                    
                    if(cse.Agent_Application_Manager__c !=null){
                        tasktoinsert.add(TaskCreationClass.taskcreate('Confirm interview with Schl', system.today(), cse.Id,cse.OwnerId, cse.Agent_Application_Manager__c));
                        tasktoinsert.add(TaskCreationClass.taskcreate('Set task to remind agent 1 day before interview & Set task to follow up with school 2 days after interview', system.today(), cse.Id,cse.OwnerId, cse.Agent_Application_Manager__c));
                    }
                }
                if(cse.recordtypeid == recordTypeIdOptOutNIN){
                    if(cse.Maxway_Application_Manager__c !=null){
                        tasktoinsert.add(TaskCreationClass.taskcreate('Confirm interview with Schl', system.today(), cse.Id, cse.OwnerId, cse.Maxway_Application_Manager__c));
                        tasktoinsert.add(TaskCreationClass.taskcreate('Set task to remind agent 1 day before interview & Set task to follow up with school 2 days after interview', system.today(), cse.Id,cse.OwnerId, cse.Maxway_Application_Manager__c));   
                    }
                    
                    if(cse.Agent_Application_Manager__c !=null){
                        tasktoinsert.add(TaskCreationClass.taskcreate('Confirm interview with Schl', system.today(), cse.Id, cse.OwnerId, cse.Agent_Application_Manager__c)); 
                        tasktoinsert.add(TaskCreationClass.taskcreate('Set task to remind agent 1 day before interview & Set task to follow up with school 2 days after interview', system.today(), cse.Id,cse.OwnerId, cse.Agent_Application_Manager__c));   
                    }
                    
                }
            }
            
        }
        if(tasktoinsert.size()>0) insert tasktoinsert;*/
    }
    //Application when Student_Confirm_Offer__c = no
    public static void taskWhenstudentdoesnotconforminterview(list<case> caselist,map<id,case> oldmap){
        list<string> userids = new list<string>();
        list<task> tasktoinsert = new list<task>();
        
        Id recordTypeIdOptin = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Application(Opt-In)').getRecordTypeId();
        Id recordTypeIdOptOutNIN = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Application(Opt-Out/NIN/Maxway)').getRecordTypeId();
        
        for(case cse : caselist){
            if( cse.Student_Confirm_Offer__c =='No' && cse.Stage__c != oldmap.get(cse.id).Stage__c){
                if(cse.recordtypeid == recordTypeIdOptin){
                    if(cse.Agent_Application_Manager__c !=null){
                        tasktoinsert.add(TaskCreationClass.taskcreate('Counter propose interview date time', system.today(), cse.Id,cse.OwnerId, cse.Agent_Application_Manager__c));
                    }
                }
                if(cse.recordtypeid == recordTypeIdOptOutNIN){
                    if(cse.Maxway_Application_Manager__c !=null){
                        tasktoinsert.add(TaskCreationClass.taskcreate('Counter propose interview date time', system.today(), cse.Id, cse.OwnerId, cse.Maxway_Application_Manager__c));
                    }
                    
                    if(cse.Agent_Application_Manager__c !=null){
                        tasktoinsert.add(TaskCreationClass.taskcreate('Counter propose interview date time', system.today(), cse.Id, cse.OwnerId, cse.Agent_Application_Manager__c));
                    }
                }
            }
        }
        if(tasktoinsert.size()>0) insert tasktoinsert;
    }
    
    //----------------------------------------------------  Task Creation for Application Manager -----------------------------------------------------------------------------------
     /**
        Name : Karan Singh Soni 
        Company: Techmatrix
        Description: To create Task on The basis of the Interviewer and Student Contact Means
        Inputs:None
        Returns: void
        Last Modified On : 18 Apr 2020
        History:
        ====================================================
        1.0 18 Apr 2020 Karan Singh Initial Version
    **/
    
    static set< Id > setRecursiveCheck = new set< Id >();
    public static void taskForApplicationManager(){
        
       list< Task > listTask = new list< Task >();
        
        set< Id > setValidRecTypID= ( new Map< Id, RecordType >([ SELECT Id 
                                                                    FROM  RecordType 
                                                                    WHERE SobjectType = 'Case' AND IsActive = true 
                                                                        AND DeveloperName IN ( 'Application_Opt_In', 'Application_Opt_Out_NIN_Maxway' ) ]) ).keySet();
        
        for( Case objCase : ( list< Case > ) trigger.new ){
            
            if( !setValidRecTypID.contains( objCase.RecordTypeId ) || setRecursiveCheck.contains( objCase.Id ) ) continue;
            
            if( trigger.isInsert ){
                
                //for Interviewer Contact Means
                if( string.isNotBlank( objCase.Interviewee_Contact_Means__c ) && string.isNotBlank( objCase.Agent_Application_Manager__c ) ){
                    
                    listTask.add( taskcreate( 'Confirm interview with student', Date.today(), objCase.Id, objCase.OwnerId, 
                                                objCase.Agent_Application_Manager__c ));   
                    setRecursiveCheck.add(objCase.Id);
                }
                //for Student Contact Means
                if( string.isNotBlank( objCase.Interview_Contact_Means__c ) && string.isNotBlank( objCase.Maxway_Application_Manager__c )){
                    
                    listTask.add( taskcreate( 'Confirm interview with school', Date.today(), objCase.Id, objCase.OwnerId, 
                                                objCase.Maxway_Application_Manager__c ));
                    
                    listTask.add( taskcreate( 'Set task to remind student 1 day before interview & Set task to follow up with school 2 days after interview', 
                                             Date.today(), objCase.Id, objCase.OwnerId, objCase.Maxway_Application_Manager__c ));
                    setRecursiveCheck.add(objCase.Id);
                }
                    
            }
            if( trigger.isUpdate ){
                
                map< Id , Case > mapOldCase = ( map < Id, Case > ) trigger.OldMap ;
                
                //for Interviewer Contact Means
                if( string.isNotBlank( objCase.Interviewee_Contact_Means__c )&& string.isNotBlank( objCase.Agent_Application_Manager__c )
                   && objCase.Interviewee_Contact_Means__c != mapOldCase.get( objCase.Id).Interviewee_Contact_Means__c ){
                    
                    listTask.add( taskcreate( 'Confirm interview with student', Date.today(), objCase.Id, objCase.OwnerId, 
                                                objCase.Agent_Application_Manager__c ));      
                       setRecursiveCheck.add(objCase.Id);
                }
                
                 //for Student Contact Means
                if( string.isNotBlank( objCase.Interview_Contact_Means__c ) && string.isNotBlank( objCase.Maxway_Application_Manager__c )
                   && objCase.Interview_Contact_Means__c != mapOldCase.get( objCase.Id).Interview_Contact_Means__c){
                    
                    listTask.add( taskcreate( 'Confirm interview with school', Date.today(), objCase.Id, objCase.OwnerId, 
                                                objCase.Maxway_Application_Manager__c ));
                    
                    listTask.add( taskcreate( 'Set task to remind student 1 day before interview & Set task to follow up with school 2 days after interview', 
                                             Date.today(), objCase.Id, objCase.OwnerId, objCase.Maxway_Application_Manager__c ));
                       setRecursiveCheck.add(objCase.Id);
                }
            }
        }//end of case for loop
        
        system.debug('listTask --> ' + listTask );
        if( listTask.size() > 0 )
            insert listTask;
                system.debug('listTask --> ' + listTask );
        
        //------------------------------------------------ Heap Clean  -----------------------------------------------------------------
        listTask = Null;
        
    }//end of taskForApplicationManager
    //--------------------------------------------------  Task Creation END  ---------------------------------------------------------------------------------
    
    // Account Creation
    //added on 16 june 2020
    //As after lead conversion, Expected_Graduation_Date__c is not mapped automatically
    public static void accountcreation(list<account> triggernew){
        /* Commented on 23-Nov-2024, Dont generate for graduate follow up task
        list<task> tasktoinsert = new list<task>();
        for(account acc : triggernew){
            //if(acc.Expected_Graduation_Date__c != null && acc.Account_Manager__c != null) commented on 16 june 2020
            if( trigger.isInsert && acc.Expected_Graduation_Date__c != null && acc.Account_Manager__c != null)
                //tasktoinsert.add(TaskCreationClass.taskcreate('student will graduate next year, pitch again',acc.Expected_Graduation_Date__c.addmonths(-12),acc.Id,acc.OwnerId, acc.Account_Manager__c));            
            
            if( trigger.isUpdate ){
                
                Account oldAccnt = ( ( map< Id, Account > ) trigger.oldMap ).get( acc.Id );
                
                if( acc.Expected_Graduation_Date__c != null && acc.Expected_Graduation_Date__c != oldAccnt.Expected_Graduation_Date__c && acc.Account_Manager__c != null ){
                    
                   //tasktoinsert.add(TaskCreationClass.taskcreate('student will graduate next year, pitch again',acc.Expected_Graduation_Date__c.addmonths(-12),acc.Id,acc.OwnerId, acc.Account_Manager__c));            
                }
            }
        }
        if(tasktoinsert.size()>0)
            insert tasktoinsert;
        */
    }
    // Opportunity Creation
    //added on 16 june 2020
    //As after lead conversion, Intended_Go_Abroad_Date__c is not mapped automatically
    public static void opportunitycreation(list<opportunity> triggernew){
        list<task> tasktoinsert = new list<task>();
        for(opportunity opp : triggernew){
            //if(opp.Intended_Go_Abroad_Date__c!= null && opp.Case_Manager__c != null) commented on 16 june 2020
            if( trigger.isInsert && opp.Intended_Go_Abroad_Date__c!= null && opp.Case_Manager__c != null)
                tasktoinsert.add(TaskCreationClass.taskcreate('time to pitch according to the student’s intended study abroad date',opp.Intended_Go_Abroad_Date__c.addmonths(-12),opp.Id,opp.OwnerId, opp.Case_Manager__c));            
            
            if( trigger.isUpdate ){
                
                Opportunity objOppOld = (( map< Id, Opportunity > ) trigger.oldMap ).get( opp.Id );
                
                if( opp.Intended_Go_Abroad_Date__c!= null && objOppOld.Intended_Go_Abroad_Date__c != opp.Intended_Go_Abroad_Date__c && opp.Case_Manager__c != null)
                    tasktoinsert.add(TaskCreationClass.taskcreate('time to pitch according to the student’s intended study abroad date',opp.Intended_Go_Abroad_Date__c.addmonths(-12),opp.Id,opp.OwnerId, opp.Case_Manager__c));            
                
            }
        }
        if(tasktoinsert.size()>0)
            insert tasktoinsert;
        
    }
    
    public static Task taskcreate(string subject ,date duedate,string whatid , string assingedowner,string taskowner){
        task tsk = new task();
        tsk.WhatId = whatid;
        tsk.Subject = subject;
        tsk.Task_Owner__c=taskowner;
        tsk.OwnerId=assingedowner;
        tsk.ActivityDate=duedate; 
        //tsk.IsVisibleInSelfService = true;
        return tsk;
    }
    
}
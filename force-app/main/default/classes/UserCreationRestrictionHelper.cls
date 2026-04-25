public class UserCreationRestrictionHelper {
    @future
    public static void activelicenceupdteacc(set<id> conidlist,string userstring){
        List<user> triggerNew = (List<user>)(JSON.deserialize(userstring,List<user>.class));
        map<string,decimal> accountidwithactivelicensecount = new map<string,decimal>();
        set<id> conids = new set<id>();
        map<string,string> activecontactsandaccountids = new map<string,string>();
        map<string,string> conaccountid = new map<string,string>();
        list<account> accountlist = new list<account>();
        
        for(user usr :[select contactid from user where contactid != null and isactive=true]){
            conids.add(usr.ContactId);
        }
        
        for(contact con :[select accountid,account.Total_Number_Of_License__c from contact where id in :conidlist])
        {
            accountidwithactivelicensecount.put(con.accountid,integer.valueof(con.account.Total_Number_Of_License__c));
            conaccountid.put(con.id,con.AccountId);
        }
        for(account account :[select id,(select id from contacts where id in :conids) from account where id in :accountidwithactivelicensecount.keyset()]){
            if(account.contacts.size()>0){
                string size = string.valueof(account.contacts.size());
                activecontactsandaccountids.put(account.id,size);
                
                account acc = new account();
                acc.id =account.id;
                acc.Active_License__c = account.contacts.size();
                accountlist.add(acc); 
                
            }
            else{
                string size = string.valueof(account.contacts.size());
                activecontactsandaccountids.put(account.id,size);
                
                account acc = new account();
                acc.id =account.id;
                acc.Active_License__c = 0;
                accountlist.add(acc); 
                
            }
        }
        if(accountlist.size()>0)
            database.update(accountlist,false);
        
        
    }
    @future
    public static void taskcreation(set<id> conidlist,string userstring){
        List<user> triggerNew = (List<user>)(JSON.deserialize(userstring,List<user>.class));
        map<string,string> accountmangerid = new map<string,string>();
        
        for(contact con :[select accountid,account.Account_Manager__c,account.OwnerId from contact where id in :conidlist])
        {
            accountmangerid.put(con.id,con.account.Account_Manager__c+'#'+con.account.OwnerId);
        }
        
        list<task> taskcreationlist = new list<task>();
        for(user usr: triggerNew){
            Task tsk = new Task();
            tsk.Subject = 'User Traning';
            tsk.ActivityDate = system.today();
            tsk.WhoId = usr.ContactId;
            if(accountmangerid.containskey(usr.ContactId)){
                string[] significantids = accountmangerid.get(usr.ContactId).split('#');
                tsk.Task_Owner__c = significantids[0]; 
                tsk.OwnerId = significantids[1];
            }
            
            taskcreationlist.add(tsk);  
        }
        if(taskcreationlist.size()>0)
            insert taskcreationlist;   
    }
    
    public static void userrestrictionbefore(set<id> conidlist,list<user> triggernew){
        map<string,decimal> accountidwithactivelicensecount = new map<string,decimal>();
        set<id> conids = new set<id>();
        map<string,string> activecontactsandaccountids = new map<string,string>();
        map<string,string> conaccountid = new map<string,string>();
        list<account> accountlist = new list<account>();
        
        for(user usr :[select contactid from user where contactid != null and isactive=true]){
            conids.add(usr.ContactId);
        }
        
        for(contact con :[select accountid,account.Total_Number_Of_License__c from contact where id in :conidlist])
        {
            accountidwithactivelicensecount.put(con.accountid,con.account.Total_Number_Of_License__c);
            conaccountid.put(con.id,con.AccountId);
        }
        for(account account :[select id,(select id from contacts where id in :conids) from account where id in :accountidwithactivelicensecount.keyset()]){
            if(account.contacts.size()>0){
                string size = string.valueof(account.contacts.size());
                activecontactsandaccountids.put(account.id,size);  
            }  
            else{
                string size = string.valueof(0);
                activecontactsandaccountids.put(account.id,size);  
            }
        }
        if(activecontactsandaccountids.size()>0 ){
            for(user usr:triggerNew){
                system.debug('check0');
                if(conaccountid.containskey(usr.contactid) && activecontactsandaccountids.containskey(conaccountid.get(usr.ContactId))){
                    system.debug('check1');
                    if(usr.IsActive==true){
                        if(accountidwithactivelicensecount.get(conaccountid.get(usr.ContactId))==integer.valueof(activecontactsandaccountids.get(conaccountid.get(usr.ContactId)))){
                            usr.adderror('Please acquire more licenses to create user');
                            system.debug('checkif');  
                        }
                        else{
                            usr.doc_deleted__c = false;
                            system.debug('checkelse');
                        }
                    }
                }        
            }
        }
        
    }
    @future
    public static void provideschoolaccess(string contactid, string userid){
        List<id> RecordtypeIds = new list<id>();
        List<id> accountidnottobeshared = new list<id>();
        list<accountshare> ListSchoolToBeShared = new list<accountshare>();
        
        for(string str : label.SchoolRecordtypes.split(';')){
            RecordtypeIds.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get(str).getRecordTypeId()); 
        }
        system.debug('--->>>>>'+contactid);
        if(contactid != null){
            contact con = [select account.School_List_Purchased__c,accountid from contact where id = :contactid];
            system.debug('con '+con);
            if(string.isNotBlank(con.account.School_List_Purchased__c )){
                list<string> countrylist = new list<string>();
                if(con.account.School_List_Purchased__c.contains(';'))
                    countrylist = con.account.School_List_Purchased__c.split(';');
                else
                    countrylist.add(con.account.School_List_Purchased__c);
                
                for (account acc : [select OwnerId,Owner.contact.accountid,Maxway_School__r.Ownerid,NIN__c,Visible_to_Agent__c,Maxway_School__c,School_s_Country__c from account where recordtypeid  in :recordtypeids and NIN__c ='Yes' and Maxway_School__c != null and Maxway_School__r.School_s_Country__c in :countrylist and Owner.contact.AccountId = :con.accountid and Maxway_School__r.Visible_to_Agent__c ='Yes']){
                    accountidnottobeshared.add(acc.Maxway_School__c);
                }
                for( Account acc : [select Maxway_School__c,NIN__c,Visible_to_Agent__c,School_s_Country__c from Account where RecordtypeId in :recordtypeids and School_s_Country__c = :countrylist  and Owner.IsPortalEnabled = false and Visible_to_Agent__c ='Yes']){
                    if( !accountidnottobeshared.contains(acc.id)){
                        ListSchoolToBeShared.add(new AccountShare ( AccountId = acc.id ,UserOrGroupId = userid ,AccountAccessLevel='Read',OpportunityAccessLevel='None')); 
                    }
                }
                if(ListSchoolToBeShared.size()>0) insert ListSchoolToBeShared;
            }
        }
        
    }
    
    /**
        Name : Karan Singh Soni 
        Company: Techmatrix
        Description: To add particular user to Account team member once it is active
        Inputs: None
        Returns: void
        Last Modified On : 20 May 2020
        History:
        ====================================================
        1.0 20 May 2020 Karan Singh Initial Version
    **/
    /*public static set< Id > setRecursiveCheckAddTeam = new set< Id > ();
    @future
    public static void addToAccountTeam( set< Id > setUserIds ){
        
        if( setUserIds.isEmpty() ) return;
        
        map< Id, list< Id > > mapAccntIdWithUserIds = new map< Id, list< Id > >();
        map< Id, list< AccountTeamMember > > mapAccntIdWithAccntTeamMember = new map< Id, list< AccountTeamMember > >();
        list< AccountTeamMember > listAccntTeamMember = new list< AccountTeamMember >();
        
        for( User objUser : [ SELECT Id,contact.AccountId 
                             FROM User 
                             WHERE Id In : setUserIds ] ){
                                 
                                 if( setRecursiveCheckAddTeam.contains(objUser.Id )) continue;
                                 
                                 setRecursiveCheckAddTeam.add( objUser.Id );                               
                                 if( !mapAccntIdWithUserIds.containsKey( objUser.contact.AccountId ) ){
                                     mapAccntIdWithUserIds.put( objUser.contact.AccountId, new list< Id > () );
                                     
                                     mapAccntIdWithUserIds.get( objUser.contact.AccountId ).add( objUser.Id );
                                     
                                 }
                             }//end of user loop
        
        if( mapAccntIdWithUserIds.isEmpty() ) return;
        
        //fetching the existing Account Team members from the accounts
        for( AccountTeamMember objAccTeamMembr : [ SELECT Id, AccountId, UserId 
                                                  FROM AccountTeamMember 
                                                  WHERE AccountId In : mapAccntIdWithUserIds.keySet() ]){
                                                      
                                                      if( !mapAccntIdWithAccntTeamMember.containsKey( objAccTeamMembr.AccountId ) )
                                                          mapAccntIdWithAccntTeamMember.put( objAccTeamMembr.AccountId, new list< AccountTeamMember > () );
                                                      
                                                      mapAccntIdWithAccntTeamMember.get( objAccTeamMembr.AccountId ).add( objAccTeamMembr );
                                                      
                                                  }//end of AccountTeamMember Loop
        
        for( Id objAccntId : mapAccntIdWithUserIds.keySet() ){
            
            set< Id > setPortalUserIds = new set< Id >();
            
            setPortalUserIds.addAll( mapAccntIdWithUserIds.get( objAccntId ) );
            
            if( mapAccntIdWithAccntTeamMember.containsKey( objAccntId )){
                
                //since we are not removing the User from account team once it is deactivated so it should not be added again.
                for( AccountTeamMember objAccTeamMembr : mapAccntIdWithAccntTeamMember.get( objAccntId ) ){
                    
                    if( setPortalUserIds.contains( objAccTeamMembr.UserId ) ){
                        
                        setPortalUserIds.remove( objAccTeamMembr.UserId );
                    }
                }//end of AccountTeamMember Loop
            
            }
            
            if( setPortalUserIds.size() == 0 ) continue;
            
            for( Id userIds : setPortalUserIds ){
                
                AccountTeamMember objAccTeamMem = new AccountTeamMember();
                
                objAccTeamMem.AccountId = objAccntId;
                objAccTeamMem.UserId = userIds;
                objAccTeamMem.TeamMemberRole = 'Sales Rep';
                objAccTeamMem.AccountAccessLevel = 'Edit';
                objAccTeamMem.CaseAccessLevel = 'Edit';
                objAccTeamMem.ContactAccessLevel = 'Edit';
                objAccTeamMem.OpportunityAccessLevel= 'Edit';
                listAccntTeamMember.add(objAccTeamMem);
                
            }//end of loop setPortalUserIds
        }//end of mapAccntIdWithUserIds loop
        
        if( listAccntTeamMember.size() > 0 ) 
            database.insert( listAccntTeamMember, false );
        
    }//end of method
*/
}
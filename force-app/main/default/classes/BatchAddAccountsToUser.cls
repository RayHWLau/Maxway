global class BatchAddAccountsToUser implements Database.Batchable<sObject>{
     
    global set< Id > setUserIds;
    
    global BatchAddAccountsToUser( set< Id > setUserIdsParam){
       
        setUserIds = setUserIdsParam;
         system.debug('@@@@@@setUserIds ---> ' + setUserIds);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        set< Id > setUserAccountId = new set< Id >();
        set< String > setValidrecordType  = new set< String >();
        set< Id > setValidrecordTypeStu  = new set< Id >();
        
        if(String.isNotBlank(Label.SchoolRecordtypes) && Label.SchoolRecordtypes.contains(';') ){
            
            setValidrecordType.addAll( Label.SchoolRecordtypes.split(';') );
        }else if( String.isNotBlank(Label.SchoolRecordtypes) ){
            
            setValidrecordType.add( Label.SchoolRecordtypes );
        }
        setValidrecordType.add( 'Student Account' );
        
        
        for( RecordType objRecType : [ SELECT ID,Name FROM RecordType 
                                      WHERE  SobjectType = 'Account' AND Name IN: setValidrecordType ]){
                                          
                                          setValidrecordTypeStu.add(objRecType.Id);
                                      }
        
        
        for( User objUser : [ SELECT contact.AccountId FROM User 
                             WHERE Id In:setUserIds ] ){
                                
                                 setUserAccountId.add( objUser.contact.AccountId );
                             }
        
        
        //sharing only student and school records whose owner are portal user.
        String queryString = ' SELECT Id,Owner.Contact.AccountId,Name FROM Account WHERE Owner.Contact.AccountId IN: setUserAccountId ';
        queryString += ' AND RecordTypeId In: setValidrecordTypeStu AND Owner.IsPortalEnabled = true AND Owner.IsActive = true';
        
        return Database.getQueryLocator( queryString );
    }
    
    global void execute(Database.BatchableContext BC, List<Account> listAccnt){
        
        map< Id,list< Id > > mapPortalAccntWithAccntTeam = new map< Id,list< Id > >();
        map< Id,list< Id > > mapPortalAccntWithExistAccntTeam = new map< Id,list< Id > >();
        list< AccountTeamMember > listAccountTeamMember = new list< AccountTeamMember >();
        
        //for existing account team user account and account record
        for( Account objAcc : listAccnt ){
        	system.debug('@@@@@@@@objAcc.Name --> ' + objAcc.Name);
            mapPortalAccntWithAccntTeam.put( objAcc.Owner.Contact.AccountId, new List< Id > () );
            mapPortalAccntWithExistAccntTeam.put( objAcc.Id, new List< Id > () );
        }
        
        //account Team of Portal user account
        for( AccountTeamMember objAccntTeam : [ SELECT Id, AccountId, UserId 
                                               FROM AccountTeamMember 
                                               WHERE AccountId In : mapPortalAccntWithAccntTeam.keySet() LIMIT 50000]){
                                                   
                                                   mapPortalAccntWithAccntTeam.get( objAccntTeam.AccountId ).add( objAccntTeam.UserId );
                                                   
                                               }
        system.debug('@@@@@@mapPortalAccntWithAccntTeam ---> '+ mapPortalAccntWithAccntTeam );
        //checking the account team of the existing  Account records
        for( AccountTeamMember objAccntTeam : [ SELECT Id, AccountId, UserId 
                                               FROM AccountTeamMember 
                                               WHERE AccountId In : mapPortalAccntWithExistAccntTeam.KeySet() LIMIT 50000]){
                                                   
                                                    mapPortalAccntWithExistAccntTeam.get( objAccntTeam.AccountId ).add( objAccntTeam.UserId );
                                                   
                                               }
        system.debug('@@@@@@@@mapPortalAccntWithExistAccntTeam --> ' + mapPortalAccntWithExistAccntTeam);
        for( Account objAcc : listAccnt ){
            
            if( mapPortalAccntWithAccntTeam.get( objAcc.Owner.Contact.AccountId ).size() > 0 ){
                
                for( Id userId : mapPortalAccntWithAccntTeam.get( objAcc.Owner.Contact.AccountId ) ){
                    
                    //if user is already part of the account record
                    if( mapPortalAccntWithExistAccntTeam.get( objAcc.Id ).contains( userId ) ) continue;
                    
                    AccountTeamMember objAccTeamMem = new AccountTeamMember();
                    
                    system.debug('objAcc.Id --->  ' + objAcc.Id );
                    system.debug('objAcc.Name --->  ' + objAcc.Name );
                    objAccTeamMem.AccountId = objAcc.Id;
                    objAccTeamMem.UserId = userId;
                    objAccTeamMem.TeamMemberRole = 'Sales Rep';
                    objAccTeamMem.AccountAccessLevel = 'Edit';
                    objAccTeamMem.CaseAccessLevel = 'Edit';
                    objAccTeamMem.ContactAccessLevel = 'Edit';
                    objAccTeamMem.OpportunityAccessLevel= 'Edit';
                    listAccountTeamMember.add(objAccTeamMem);
                    
                }//end of user Id loop
            }//end of mapPortalAccntWithAccntTeam check
        }//end of account loop
        
        if( listAccountTeamMember.size() > 0 ){
            
            Database.insert(listAccountTeamMember,false);
        }
        
    }//end of execute method
    
    
    global void finish(Database.BatchableContext BC){
        
        try{
            
            Database.executeBatch( new BatchAddStaffToUser( setUserIds ), 200 );
        }Catch( Exception objExp ){
            
            system.debug('@@@@@@@@ Error msg -->  ' + objExp.getMessage() + 'Line --> ' + objExp.getLineNumber() );
        }
    }
}
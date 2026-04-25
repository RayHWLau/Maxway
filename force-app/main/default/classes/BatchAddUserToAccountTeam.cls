global class BatchAddUserToAccountTeam implements Database.Batchable<Id>,Database.Stateful{
     
    global set< Id > setUserIds;
    global set< Id > setAddedUserInTeam;
    
    global BatchAddUserToAccountTeam( set< Id > setUserIdsParam ){
        
        setAddedUserInTeam = new set< Id >();
        setUserIds = setUserIdsParam;
    }
    
    global Iterable<Id> start(Database.BatchableContext BC)
    {
        List< Id > listUserId = new List< Id >();
        listUserId.addAll( setUserIds );
        return listUserId;
    }
    
    global void execute(Database.BatchableContext info, List<Id> listUserIds)
    {
        map< Id, list< Id > > mapAccntIdWithUserIds = new map< Id, list< Id > >();
        map< Id, list< AccountTeamMember > > mapAccntIdWithAccntTeamMember = new map< Id, list< AccountTeamMember > >();
        list< AccountTeamMember > listAccntTeamMember = new list< AccountTeamMember >();
        
        //fetch the data of the activated user and the account it is related to
        for( User objUser : [ SELECT Id,contact.AccountId 
                             FROM User 
                             WHERE Id In : setUserIds ] ){
                                 
                                 if( !mapAccntIdWithUserIds.containsKey( objUser.contact.AccountId ) ){
                                     mapAccntIdWithUserIds.put( objUser.contact.AccountId, new list< Id > () );
                                 }
                                 mapAccntIdWithUserIds.get( objUser.contact.AccountId ).add( objUser.Id );
                             }//end of user loop
        
        
        if( mapAccntIdWithUserIds.isEmpty() ) return;
        
        //fetching the existing Account Team members from the accounts
        //this is commented as if a user get's deactivated then reactivate then it should show all the records which were 
        //created when user was deactivated.
        /*for( AccountTeamMember objAccTeamMembr : [ SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE AccountId In : mapAccntIdWithUserIds.keySet() ]){if( !mapAccntIdWithAccntTeamMember.containsKey( objAccTeamMembr.AccountId ) )mapAccntIdWithAccntTeamMember.put( objAccTeamMembr.AccountId, new list< AccountTeamMember > () );mapAccntIdWithAccntTeamMember.get( objAccTeamMembr.AccountId ).add( objAccTeamMembr );}//end of AccountTeamMember Loop*/
        
        
        for( Id objAccntId : mapAccntIdWithUserIds.keySet() ){
            
            set< Id > setPortalUserIds = new set< Id >();
            
            setPortalUserIds.addAll( mapAccntIdWithUserIds.get( objAccntId ) );
            
            /*
//this is commented as if a user get's deactivated then reactivate then it should show all the records which were 
//created when user was deactivated.
if( mapAccntIdWithAccntTeamMember.containsKey( objAccntId )){

//since we are not removing the User from account team once it is deactivated so it should not be added again.
for( AccountTeamMember objAccTeamMembr : mapAccntIdWithAccntTeamMember.get( objAccntId ) ){if( setPortalUserIds.contains( objAccTeamMembr.UserId ) ){ setPortalUserIds.remove( objAccTeamMembr.UserId );}}//end of AccountTeamMember Loop}
*/
            
            if( setPortalUserIds.size() == 0 ) continue;
            
            for( Id userIds : setPortalUserIds ){
                AccountTeamMember objAccTeamMem = new AccountTeamMember();
                
                objAccTeamMem.AccountId = objAccntId;
                objAccTeamMem.UserId = userIds;
                objAccTeamMem.TeamMemberRole = 'Sales Rep';
                objAccTeamMem.AccountAccessLevel = 'Read';
                objAccTeamMem.CaseAccessLevel = 'Edit';
                objAccTeamMem.ContactAccessLevel = 'Read';
                
                //objAccTeamMem.OpportunityAccessLevel= 'Edit'; changed on 18 June 2020 NTF-0135 as portal user should not see it' own Agent opportunity.
                objAccTeamMem.OpportunityAccessLevel= 'None';
                listAccntTeamMember.add(objAccTeamMem);
                
            }//end of loop setPortalUserIds
        }//end of mapAccntIdWithUserIds loop
        
        if( listAccntTeamMember.size() > 0 ) {
            
            List<Database.saveResult> databaseResult = database.insert( listAccntTeamMember, false );
            
            for( Integer index = 0; index < databaseResult.size(); index++ ){
                
                if( databaseResult[ index ].isSuccess() ){
                    //those whihc are successfully added in the team will be futher shared other custom records
                    setAddedUserInTeam.add( listAccntTeamMember[index].UserId );
                }
            }//end of database result loop
            
        }//end of listAccntTeamMember size check
        
    }//end of execute method
    
    global void finish(Database.BatchableContext info) { 
        
        if( setAddedUserInTeam.size() > 0 ){
            
            try{
                //those whihc are successfully added in the team will be futher shared other custom records
                system.debug('@@@@@@@@setAddedUserInTeam ---> ' + setAddedUserInTeam );
                Database.executeBatch( new BatchAddAccountsToUser( setAddedUserInTeam ), 200 );
            }Catch( Exception objExp ){
                
                system.debug(' @@@@@@@@@@Error msg -->  ' + objExp.getMessage() + 'Line --> ' + objExp.getLineNumber() );
            }
        }
    }
}
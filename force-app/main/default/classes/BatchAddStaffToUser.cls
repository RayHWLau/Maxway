global class BatchAddStaffToUser implements Database.Batchable<sObject>{
 
    global set< Id > setUserIds;
    
    global BatchAddStaffToUser( set< Id > setUserIdsParam){
        
        setUserIds = setUserIdsParam;
        system.debug('@@@@@@@setUserIds ---> ' + setUserIds);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        set< Id > setUserAccountId = new set< Id >();
        for( User objUser : [ SELECT contact.AccountId FROM User 
                             WHERE Id In:setUserIds ] ){
                                
                                 setUserAccountId.add( objUser.contact.AccountId );
                             }
        
        //owner.contact.id is not accessible in the query
        //https://salesforce.stackexchange.com/questions/47467/owner-custom-fields-and-some-standard-fields-are-not-accessible-in-relations
        //only fetching records which are cretaed by Portal user (Active)
        return Database.getQueryLocator( 'SELECT Id,Name,CreatedBy.contact.AccountId FROM Staff__c WHERE CreatedBy.contact.AccountId IN: setUserAccountId AND CreatedBy.isPortalEnabled = true AND CreatedBy.IsActive = true ' );
    }
    global void execute(Database.BatchableContext BC, List<Staff__c> listStaff){
        
         map< Id,list< Id > > mapPortalAccntWithAccntTeam = new map< Id,list< Id > >();
        map< Id,list< Id > > mapExistStaffShare = new map< Id,list< Id > >();
        list< Staff__Share > listStaffShare = new list< Staff__Share > ();
        
        for(  Staff__c objStaff : listStaff ){
            
            system.debug('@@@@ objStaff.Name --> '+ objStaff.Name);
            mapPortalAccntWithAccntTeam.put( objStaff.CreatedBy.contact.AccountId, new List< Id > ());
            mapExistStaffShare.put( objStaff.Id, new List< Id > () );
        }
        
        //fetching the existing Staff_Share
        for( Staff__Share objStaffShare : [ SELECT Id,ParentId,UserOrGroupId 
                                           		FROM Staff__Share 
                                           	WHERE ParentId IN: mapExistStaffShare.keySet() LIMIT 50000] ){
            system.debug('@@@@@@objStaffShare.ParentId --> ' + objStaffShare.ParentId);
                                                system.debug('@@@@@objStaffShare.UserOrGroupId --> '+ objStaffShare.UserOrGroupId);
                                                mapExistStaffShare.get( objStaffShare.ParentId ).add( objStaffShare.UserOrGroupId );
        }
        
         //account Team of Portal user account
        for( AccountTeamMember objAccntTeam : [ SELECT Id, AccountId, UserId 
                                               FROM AccountTeamMember 
                                               WHERE AccountId In : mapPortalAccntWithAccntTeam.keySet() LIMIT 50000]){
                                                   
                                                   mapPortalAccntWithAccntTeam.get( objAccntTeam.AccountId ).add( objAccntTeam.UserId );
                                                   
                                               }
		system.debug('@@@@@mapPortalAccntWithAccntTeam----> ' + mapPortalAccntWithAccntTeam );
        
        for( Staff__c objStaff : listStaff ){
            
            if( mapPortalAccntWithAccntTeam.get( objStaff.CreatedBy.contact.AccountId ).size() > 0 ){
               
                for( Id UserId : mapPortalAccntWithAccntTeam.get( objStaff.CreatedBy.contact.AccountId ) ){
                    
                    //if record is already shared to the User
                    system.debug('@@@@@@@mapExistStaffShare.containsKey( UserId )' + mapExistStaffShare.containsKey( objStaff.Id ) );
                    system.debug('@@@@ UserId----> ' + UserId );
                    system.debug('@@@@@@@mapExistStaffShare.get( UserId )' + mapExistStaffShare.get( objStaff.Id ) );
                    
                    if( mapExistStaffShare.containsKey( objStaff.Id ) && mapExistStaffShare.get( objStaff.Id ).contains( UserId )) continue;
                    system.debug('@@@@objStaff.Id --> ' + objStaff.Id);
                    system.debug('@@@@@@objStaff.Name --> ' + objStaff.Name);
                    Staff__Share objStaffShare = new Staff__Share();
                    objStaffShare.ParentId = objStaff.Id;
                    objStaffShare.AccessLevel = 'Edit';
                    objStaffShare.UserOrGroupId = UserId;
                    listStaffShare.add( objStaffShare );
                }//end of user Id loop
            }//end of size check
        }//end of Staff Share Loop
        
        if( listStaffShare.size() > 0 ){
            
            Database.insert(listStaffShare,false);
        }
    }
     global void finish(Database.BatchableContext BC){
        
         try{
             
            Database.executeBatch( new BatchAddRecommendedSchoolToUser( setUserIds ), 200 );
        }Catch( Exception objExp ){
            
            system.debug('@@@@@@@@@ Error msg -->  ' + objExp.getMessage() + 'Line --> ' + objExp.getLineNumber() );
        }
    }
}
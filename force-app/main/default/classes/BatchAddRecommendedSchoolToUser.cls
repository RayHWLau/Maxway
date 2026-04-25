global class BatchAddRecommendedSchoolToUser implements Database.Batchable<sObject>{
    
    global set< Id > setUserIds; 
    
    global BatchAddRecommendedSchoolToUser( set< Id > setUserIdsParam){
        
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
        ////only fetching records which are cretaed by Portal user (Active)
        return Database.getQueryLocator( 'SELECT Id,Name,CreatedBy.contact.AccountId FROM Recommended_Schools__c WHERE CreatedBy.contact.AccountId IN: setUserAccountId AND CreatedBy.isPortalEnabled = true AND CreatedBy.IsActive = true ' );
    }
    
    global void execute(Database.BatchableContext BC, List<Recommended_Schools__c> listRecommSchl){
        
        map< Id,list< Id > > mapPortalAccntWithAccntTeam = new map< Id,list< Id > >();
        map< Id,list< Id > > mapExistRecommSchlShare = new map< Id,list< Id > >();
        list< Recommended_Schools__Share > listRecommSchlShare = new list< Recommended_Schools__Share > ();
        
        for(  Recommended_Schools__c objRecommSchl : listRecommSchl ){
            system.debug('@@@@ objRecommSchl.Name --> '+ objRecommSchl.Name);
            mapPortalAccntWithAccntTeam.put( objRecommSchl.CreatedBy.contact.AccountId, new List< Id > ());
            mapExistRecommSchlShare.put( objRecommSchl.Id, new List< Id > () );
        }
        
        //fetching the existing Recommended_Schools__Share
        for( Recommended_Schools__Share objRecommSchl : [ SELECT Id,ParentId,UserOrGroupId 
                                                         FROM Recommended_Schools__Share 
                                                         WHERE ParentId IN: mapExistRecommSchlShare.keySet() LIMIT 50000] ){
                                                             
                                                             mapExistRecommSchlShare.get( objRecommSchl.ParentId ).add( objRecommSchl.UserOrGroupId );
                                                         }
        
        //account Team of Portal user account
        for( AccountTeamMember objAccntTeam : [ SELECT Id, AccountId, UserId 
                                               FROM AccountTeamMember 
                                               WHERE AccountId In : mapPortalAccntWithAccntTeam.keySet() LIMIT 50000]){
                                                   
                                                   mapPortalAccntWithAccntTeam.get( objAccntTeam.AccountId ).add( objAccntTeam.UserId );
                                                   
                                               }
        
         for( Recommended_Schools__c objRecommSchl : listRecommSchl ){
            
            if( mapPortalAccntWithAccntTeam.get( objRecommSchl.CreatedBy.contact.AccountId ).size() > 0 ){
               
                for( Id UserId : mapPortalAccntWithAccntTeam.get( objRecommSchl.CreatedBy.contact.AccountId ) ){
                    
                    //if record is already shared to the User
                    system.debug('@@@@@@@@mapExistRecommSchlShare.containsKey( UserId )' + mapExistRecommSchlShare.containsKey( objRecommSchl.Id ) );
                    if( mapExistRecommSchlShare.containsKey( objRecommSchl.Id )  && mapExistRecommSchlShare.get( objRecommSchl.Id ).contains( UserId )) continue;
                    system.debug('@@@@@@@objRecommSchl.Id --> ' + objRecommSchl.Id);
                    system.debug('@@@@objRecommSchl.Name --> ' + objRecommSchl.Name);
                    Recommended_Schools__Share objRecommSchlShare = new Recommended_Schools__Share();
                    objRecommSchlShare.ParentId = objRecommSchl.Id;
                    objRecommSchlShare.AccessLevel = 'Edit';
                    objRecommSchlShare.UserOrGroupId = UserId;
                    listRecommSchlShare.add( objRecommSchlShare );
                }//end of user Id loop
            }//end of size check
        }//end of Staff Share Loop
        
        if( listRecommSchlShare.size() > 0 ){
            
            Database.insert(listRecommSchlShare,false);
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
        
        
        try{
             
            Database.executeBatch( new BatchAddInvoiceToUser( setUserIds ), 200 );
        }Catch( Exception objExp ){
            
            system.debug('@@@@@@@@@@@@@@ Error msg -->  ' + objExp.getMessage() + 'Line --> ' + objExp.getLineNumber() );
        }
    }
}
global class BatchAddInvoiceToUser  implements Database.Batchable<sObject>{
    
    global set< Id > setUserIds;
    
    global BatchAddInvoiceToUser( set< Id > setUserIdsParam){
        
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
        return Database.getQueryLocator( 'SELECT Id,Name,CreatedBy.contact.AccountId FROM Invoice__c WHERE CreatedBy.contact.AccountId IN: setUserAccountId AND CreatedBy.isPortalEnabled = true AND CreatedBy.IsActive = true ' );
    }
    
    global void execute(Database.BatchableContext BC, List<Invoice__c> listInv){
        
        map< Id,list< Id > > mapPortalAccntWithAccntTeam = new map< Id,list< Id > >();
        map< Id,list< Id > > mapExistRecommInvShare = new map< Id,list< Id > >();
        list< Invoice__Share > listInvShare = new list< Invoice__Share > ();
        
        for(  Invoice__c objInv : listInv ){
            system.debug('@@@@ objInv.Name --> '+ objInv.Name);
            mapPortalAccntWithAccntTeam.put( objInv.CreatedBy.contact.AccountId, new List< Id > ());
            mapExistRecommInvShare.put( objInv.Id, new List< Id > () );
        }
        //fetching the existing Invoice SHare
        for( Invoice__Share objInvShare : [ SELECT Id,ParentId,UserOrGroupId 
                                           FROM Invoice__Share 
                                           WHERE ParentId IN: mapExistRecommInvShare.keySet() LIMIT 50000] ){
                                               
                                               mapExistRecommInvShare.get( objInvShare.ParentId ).add( objInvShare.UserOrGroupId );
                                           }
        
        //account Team of Portal user account
        for( AccountTeamMember objAccntTeam : [ SELECT Id, AccountId, UserId 
                                               FROM AccountTeamMember 
                                               WHERE AccountId In : mapPortalAccntWithAccntTeam.keySet() LIMIT 50000]){
                                                   
                                                   mapPortalAccntWithAccntTeam.get( objAccntTeam.AccountId ).add( objAccntTeam.UserId );
                                                   
                                               }
        system.debug('@@@@@mapPortalAccntWithAccntTeam----> ' + mapPortalAccntWithAccntTeam );
        
        for( Invoice__c objInv : listInv ){
            
            if( mapPortalAccntWithAccntTeam.get( objInv.CreatedBy.contact.AccountId ).size() > 0 ){
                
                for( Id UserId : mapPortalAccntWithAccntTeam.get( objInv.CreatedBy.contact.AccountId ) ){
                    
                    //if record is already shared to the User
                    system.debug('mapExistRecommInvShare.containsKey( UserId )' + mapExistRecommInvShare.containsKey( objInv.ID ) );
                    system.debug('@@@@ objInv.Name --> '+ objInv.Name);
                    system.debug('@@@@ UserId----> ' + UserId );
                    system.debug('@@@@@@@mapExistRecommInvShare.get( UserId )' + mapExistRecommInvShare.get( objInv.Id ) );
                    if( mapExistRecommInvShare.containsKey( objInv.ID ) && mapExistRecommInvShare.get( objInv.Id ).contains( UserId )) continue;
                    system.debug('objInv.Id --> ' + objInv.Id);
                    system.debug('@@@@ objInv.Name --> '+ objInv.Name);
                    Invoice__Share objInvShare = new Invoice__Share();
                    objInvShare.ParentId = objInv.Id;
                    objInvShare.AccessLevel = 'Edit';
                    objInvShare.UserOrGroupId = UserId;
                    listInvShare.add( objInvShare );
                }//end of user Id loop
            }//end of size check 
        }//end of Staff Share Loop
        
        if( listInvShare.size() > 0 ){
            
            Database.insert(listInvShare,false);
        }
        
    }
    global void finish(Database.BatchableContext BC){
        
        
    }
}
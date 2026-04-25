/**
* @File Name : RecommendedSchoolTriggerNewHelper.cls
* @Description : 
* @Author : Karan Singh Soni
* @Last Modified By : Karan Singh Soni
* @Last Modified On : 21 May 2020
* @Modification Log :
* @Test Class : 
*==============================================================================
* Ver Date           Author                       Modification
*==============================================================================
* 1.0  21 May 2020   Karan Singh                  Initial Version
**/
public class RecommendedSchoolTriggerNewHelper {

    /**
		Name : Karan Singh Soni	
		Company: Techmatrix
		Description: Method to share Staff record to the other portal user.
		Inputs:None
		Returns: void
		Last Modified On :
		History:
		====================================================
		1.0 21 May 2020   Karan Singh 	Initial Version

	**/
    public static set< Id > setRecursiveCheckAddUser = new set< Id >();
    public static void shareInvoiceToOtherPortalUser(){
        
        list< Recommended_Schools__Share > listRecommSchoolShare = new  list< Recommended_Schools__Share >();
        map< Id, list< Id > > mapCurrentAccntwithContactIds = new map< Id, list< Id > >();
        set< Id > setContactIds = new set< Id > ();
        map< Id, User > mapContactToActiveUser = new map< Id, User >();
        
        //check if current user is portal user or not
        list< user > listCurrrentUser = [ SELECT Id,isPortalEnabled,contact.AccountId  FROM User WHERE Id =: UserInfo.getUserId() ];
        
        //if the current user is portal user then only share the records
        if( listCurrrentUser[0].isPortalEnabled && String.isNotBlank( listCurrrentUser[0].contact.AccountId ) ){
            
            for( Account objAccnt : [ SELECT Id,( SELECT Id FROM Contacts ) FROM Account 
                                     WHERE Id =: listCurrrentUser[0].contact.AccountId ]){
                                        
                                         if( !mapCurrentAccntwithContactIds.containsKey( objAccnt.Id ) ){
                                             mapCurrentAccntwithContactIds.put( objAccnt.Id, new list< Id > () );
                                         }
                                         
                                         mapCurrentAccntwithContactIds.get( objAccnt.Id).addAll(( new map< Id, Contact > ( objAccnt.Contacts ) ).keySet());
                                         setContactIds.addAll( mapCurrentAccntwithContactIds.get( objAccnt.Id ));
                                     }//end of portal user account loop
            
            system.debug('@@@@@ mapCurrentAccntwithContactIds --> ' + mapCurrentAccntwithContactIds);
            system.debug('@@@@@ setContactIds --> ' + setContactIds);
            
            if( setContactIds.size() > 0  ){
            
                for( User objUser : [SELECT Id,ContactId FROM user WHERE ContactId IN: setContactIds AND isActive = true] ){
                    
                    mapContactToActiveUser.put( objUser.ContactId, objUser );
                        
                }//end of user loop
                system.debug('@@@@@ mapContactToActiveUser --> ' + mapContactToActiveUser);
                for( Recommended_Schools__c objRecommSch : ( list< Recommended_Schools__c > ) trigger.new ){
                    
                    if( setRecursiveCheckAddUser.contains( objRecommSch.id )) continue;
                    
                    if( objRecommSch.ownerId == listCurrrentUser[0].Id 
                       && mapCurrentAccntwithContactIds.containsKey( listCurrrentUser[0].contact.AccountId )){
                        
                           for( Id contactId : mapCurrentAccntwithContactIds.get( listCurrrentUser[0].contact.AccountId )){
                               system.debug('@@@@@ contactId --> ' + contactId);
                               
                               if( !mapContactToActiveUser.containsKey(contactId)) continue;
                               //if contact user is same as current User then we didnt need sharing for that.
                               if( mapContactToActiveUser.get( contactId ).Id == listCurrrentUser[0].Id )continue;
                               
                               Recommended_Schools__Share objRecommShare = new Recommended_Schools__Share();
                               objRecommShare.ParentId = objRecommSch.Id;
                               objRecommShare.AccessLevel = 'Edit';
                               objRecommShare.UserOrGroupId = mapContactToActiveUser.get( contactId ).Id;
                               listRecommSchoolShare.add( objRecommShare );
                               setRecursiveCheckAddUser.add( objRecommSch.Id );
                           }//end of Contact Id loop
                    }
                }//end of trigger.new loop
                
                if( listRecommSchoolShare.size() > 0 ){
                    insert listRecommSchoolShare; 
                    system.debug('@@@@@ listRecommSchoolShare --> ' + listRecommSchoolShare);
                }
            }//end of contact Ids check
        }//end of current portal user check
    }//end of shareInvoiceToOtherPortalUser
    
}
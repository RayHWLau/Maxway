public class SchoolSharingForComunityUser {
    
    public static void schoolshare(list<account> triggernew, map<id,account> triggeroldmap){
        if(recursiveCheck.schoolshareCheck == false){
            recursiveCheck.schoolshareCheck = true;
            List<id> RecordtypeIds = new list<id>();
            set<id> accountIds = new set<id>();
            list<accountshare> ListSchoolToBeShared = new list<accountshare>();
            list<accountshare> ListSchoolAccessToBeDeleted = new list<accountshare>();  
            map<string,set<string>> MapCountryListWithAccountIdProvideAccess = new map<string,set<string>>();
            map<string,set<string>> MapCountryListWithAccountIdDeleteAccess = new map<string,set<string>>();
            map<string,string> MapUserIdWithCountryPurchasedList = new map<string,string>();
            map<string,string> MapUserIdWithSchoolNotToBeShared = new map<string,string>();
            map<string,set<string>> MapUserIdWithSchoolToBeShared = new map<string,set<string>>();
            map<string,set<string>> MapUserIdWithSchoolToDeleteAccess = new map<string,set<string>>();
            map<string,string> MapUserAccountIdWithSchoolNotToBeShared = new map<string,string>();
            map<string,set<string>> MapUserAccountIdWithUserId = new map<string,set<string>>();
            
            
            for(string str : label.SchoolRecordtypes.split(';')){
                RecordtypeIds.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get(str).getRecordTypeId()); 
            }
            
            for (Account acc : triggernew){
                System.debug('acc.School_s_Country__c-->'+acc.School_s_Country__c);
                system.debug('recordtypeids.contains(acc.RecordtypeId)'+recordtypeids.contains(acc.RecordtypeId));
                system.debug('triggeroldmap.get(acc.id).Visible_to_Agent__c'+triggeroldmap.get(acc.id).Visible_to_Agent__c);
                system.debug('acc.Visible_to_Agent__c'+acc.Visible_to_Agent__c);
                if(triggeroldmap.containskey(acc.id) &&  triggeroldmap.get(acc.id).Visible_to_Agent__c != acc.Visible_to_Agent__c && recordtypeids.contains(acc.RecordtypeId) && acc.Owner.IsPortalEnabled ==false){
                    if(acc.Visible_to_Agent__c == 'Yes'){
                        accountIds.add(acc.id);
                        System.debug('acc.School_s_Country__c-->'+acc.School_s_Country__c);
                        if(MapCountryListWithAccountIdProvideAccess.containskey(acc.School_s_Country__c)){
                            set<string> schoolids = MapCountryListWithAccountIdProvideAccess.get(acc.School_s_Country__c);
                            schoolids.add(acc.id);  
                            MapCountryListWithAccountIdProvideAccess.put(acc.School_s_Country__c,schoolids);
                        }
                        else{
                            set<string> schoolids = new set<string>();
                            schoolids.add(acc.id);  
                            MapCountryListWithAccountIdProvideAccess.put(acc.School_s_Country__c,schoolids);
                        } 
                    }
                    
                    else{
                        if(MapCountryListWithAccountIdDeleteAccess.containskey(acc.School_s_Country__c)){
                            set<string> schoolids = MapCountryListWithAccountIdDeleteAccess.get(acc.School_s_Country__c);
                            schoolids.add(acc.id);  
                            MapCountryListWithAccountIdDeleteAccess.put(acc.School_s_Country__c,schoolids);  
                        }
                        else{
                            set<string> schoolids = new set<string>();
                            schoolids.add(acc.id);  
                            MapCountryListWithAccountIdDeleteAccess.put(acc.School_s_Country__c,schoolids);
                        } 
                    }  
                }
            } 
            if(accountIds.size()>0){
                for (account acc : [select OwnerId,Owner.contact.accountid,Maxway_School__r.Ownerid,NIN__c,Visible_to_Agent__c,Maxway_School__c,School_s_Country__c from account where recordtypeid  in :recordtypeids and NIN__c ='Yes' and Maxway_School__c != null and Maxway_School__c in :accountIds and Maxway_School__r.Visible_to_Agent__c ='Yes']){
                    if(string.isNotBlank(acc.Maxway_School__c)){
                        //  MapUserIdWithSchoolNotToBeShared.put(acc.Maxway_School__r.Ownerid,acc.Maxway_School__c);
                        MapUserAccountIdWithSchoolNotToBeShared.put(acc.Owner.contact.accountid,acc.Maxway_School__c);
                    }  
                }
            }
            
            for(user usr : [select contact.accountId,contact.account.School_List_Purchased__c from user where contact.account.School_List_Purchased__c!=null and isactive=true]){
                MapUserIdWithCountryPurchasedList.put(usr.id,usr.contact.account.School_List_Purchased__c);
                if(MapUserAccountIdWithUserId.containskey(usr.contact.accountId)){
                    set<string> usrids = MapUserAccountIdWithUserId.get(usr.contact.accountId);
                    usrids.add(usr.id);  
                    MapUserAccountIdWithUserId.put(usr.contact.accountId,usrids);  
                }
                else{
                    set<string> usrids = new set<string>();
                    usrids.add(usr.id);  
                    MapUserAccountIdWithUserId.put(usr.contact.accountId,usrids);
                } 
            }
            
            //   system.debug('MapUserAccountIdWithUserId-->'+MapUserAccountIdWithUserId);
            for(string str : MapUserAccountIdWithSchoolNotToBeShared.keyset()){
                if(MapUserAccountIdWithUserId.containskey(str)){
                    for(string userid : MapUserAccountIdWithUserId.get(str)){
                        MapUserIdWithSchoolNotToBeShared.put(userid,MapUserAccountIdWithSchoolNotToBeShared.get(str));  
                    }
                }
                
            }
            system.debug('MapUserAccountIdWithUserId-->'+MapUserAccountIdWithUserId);
            system.debug('MapUserAccountIdWithSchoolNotToBeShared-->'+MapUserAccountIdWithSchoolNotToBeShared);
            system.debug('MapUserIdWithSchoolNotToBeShared-->'+MapUserIdWithSchoolNotToBeShared);
            
            Set<string> schoolids = new Set<string>();
            Set<string> schoolidsnottobeshared = new Set<string>();
            
            for(string str : MapUserIdWithCountryPurchasedList.keyset()){
                
                if(MapUserIdWithCountryPurchasedList.get(str).contains(';')){
                    for(string country :MapUserIdWithCountryPurchasedList.get(str).split(';')){
                        if(MapCountryListWithAccountIdProvideAccess.containskey(country)) schoolids.addall(MapCountryListWithAccountIdProvideAccess.get(country));
                        if(MapCountryListWithAccountIdDeleteAccess.containskey(country)) schoolidsnottobeshared.addall(MapCountryListWithAccountIdDeleteAccess.get(country));
                    }  
                }
                else{
                    if(MapCountryListWithAccountIdProvideAccess.containskey(MapUserIdWithCountryPurchasedList.get(str))) schoolids.addall(MapCountryListWithAccountIdProvideAccess.get(MapUserIdWithCountryPurchasedList.get(str)));
                    if(MapCountryListWithAccountIdDeleteAccess.containskey(MapUserIdWithCountryPurchasedList.get(str))) schoolidsnottobeshared.addall(MapCountryListWithAccountIdDeleteAccess.get(MapUserIdWithCountryPurchasedList.get(str)));
                }
                MapUserIdWithSchoolToBeShared.put(str,schoolids);
                MapUserIdWithSchoolToDeleteAccess.put(str,schoolidsnottobeshared);
            }
            system.debug('MapUserIdWithSchoolToBeShared-->'+MapUserIdWithSchoolToBeShared);
            system.debug('MapUserIdWithSchoolToBeShared-->'+MapUserIdWithSchoolToBeShared.size());
            system.debug('MapUserIdWithSchoolToDeleteAccess-->'+MapUserIdWithSchoolToDeleteAccess);
            
            for(string str : MapUserIdWithSchoolToBeShared.keyset()){
                if(MapUserIdWithSchoolNotToBeShared.containskey(str)){
                    system.debug('yeee-->'+MapUserIdWithSchoolToBeShared.get(str));
                    //    MapUserIdWithSchoolToBeShared.get(str).remove(MapUserIdWithSchoolNotToBeShared.get(str)); 
                    
                    for(string schoolid : MapUserIdWithSchoolToBeShared.get(str)){
                        if(!MapUserIdWithSchoolNotToBeShared.get(str).contains(schoolid))
                            ListSchoolToBeShared.add(new AccountShare ( AccountId = schoolid,UserOrGroupId = str ,AccountAccessLevel='Read',OpportunityAccessLevel='None',contactAccessLevel='None'));   
                    }
                }
                else{
                    system.debug('yeee1-->'+MapUserIdWithSchoolToBeShared.get(str));
                    for(string schoolid : MapUserIdWithSchoolToBeShared.get(str)){
                        ListSchoolToBeShared.add(new AccountShare ( AccountId = schoolid,UserOrGroupId = str ,AccountAccessLevel='Read',OpportunityAccessLevel='None',contactAccessLevel='None'));   
                    }    
                }
            }
            
            if(ListSchoolToBeShared.size()>0) insert ListSchoolToBeShared;
            if(MapUserIdWithSchoolToDeleteAccess.size()>0){
                for(AccountShare accshare :[Select AccountId,UserOrGroupId from AccountShare where UserOrGroupId in :MapUserIdWithSchoolToDeleteAccess.keyset()]){
                    if(MapUserIdWithSchoolToDeleteAccess.get(accshare.UserOrGroupId).contains(accshare.AccountId)) ListSchoolAccessToBeDeleted.add(accshare);
                }
            }
            if(ListSchoolAccessToBeDeleted.size()>0) delete ListSchoolAccessToBeDeleted;
            
            system.debug('ListSchoolAccessToBeDeleted-->'+ListSchoolAccessToBeDeleted);
            system.debug('ListSchoolToBeShared-->'+ListSchoolToBeShared); 
        }
        
    }
    
    public static void sharingchangeaccordingtoschoollistpurchased(account triggernew , string countrylistold){
        if(recursiveCheck.sharingchangeaccordingtoschoollistpurchasedCheck == false){
            recursiveCheck.sharingchangeaccordingtoschoollistpurchasedCheck = true;
            List<id> RecordtypeIds = new list<id>();
            set<id> accountidstobedeleted = new set<id>();
            set<id> accountidsnottobeshared = new set<id>();
            list<accountshare> ListSchoolToBeShared = new list<accountshare>();
            list<accountshare> listSchoolToBeDeleted = new list<accountshare>();
            
            for(string str : label.SchoolRecordtypes.split(';')){
                RecordtypeIds.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get(str).getRecordTypeId()); 
            }
            
            set<Id> userids = new set<Id>();  
            
            if(triggernew.id != null){
                
                for(user user :[select contact.accountid from user where  contact.accountid = :triggernew.id and isactive = true] ){
                    userids.add(user.id); 
                }
                
                if(userids.size()>0){
                    if(string.isNotBlank(triggernew.School_List_Purchased__c) && string.isNotBlank(countrylistold) ){
                        
                        list<string> countrylist = new list<string>();
                        
                        if(triggernew.School_List_Purchased__c.contains(';'))  countrylist = triggernew.School_List_Purchased__c.split(';');  
                        else  countrylist.add(triggernew.School_List_Purchased__c);
                        
                        
                        if(string.isNotBlank(countrylistold)){
                            
                            list<string> oldcountrylist = new list<string>();
                            
                            if(countrylistold.contains(';')) oldcountrylist = countrylistold.split(';');   
                            else  oldcountrylist.add(countrylistold);
                            
                            
                            system.debug('old-->'+oldcountrylist);
                            system.debug('new-->'+countrylist);
                            
                            for (account acc : [select OwnerId,Owner.contact.accountid,Maxway_School__r.Ownerid,NIN__c,Visible_to_Agent__c,Maxway_School__c,Maxway_School__r.School_s_Country__c from account where recordtypeid  in :recordtypeids and NIN__c ='Yes' and Maxway_School__c != null and OwnerId in :userids and Maxway_School__r.School_s_Country__c in :countrylist and Maxway_School__r.Visible_to_Agent__c ='Yes']){
                                accountidsnottobeshared.add(acc.Maxway_School__c);  
                            }  
                            
                            system.debug('accountidsnottobeshared-->'+accountidsnottobeshared.size());
                            
                            
                            for( Account acc : [select Maxway_School__c,NIN__c,Visible_to_Agent__c,School_s_Country__c from Account where RecordtypeId in :recordtypeids and School_s_Country__c in :oldcountrylist  and Owner.IsPortalEnabled = false and Visible_to_Agent__c='Yes']){
                                
                                accountidstobedeleted.add(acc.id);
                                system.debug(acc.id);
                            }
                            
                            system.debug('accountidstobedeleted-->'+accountidstobedeleted.size());
                            
                            for( Account acc : [select Maxway_School__c,NIN__c,Visible_to_Agent__c,School_s_Country__c from Account where RecordtypeId in :recordtypeids and School_s_Country__c in :countrylist  and Owner.IsPortalEnabled = false and Visible_to_Agent__c='Yes']){  
                                if( !accountidsnottobeshared.contains(acc.id)){
                                    for(string str : userids){
                                        ListSchoolToBeShared.add(new AccountShare ( AccountId = acc.id ,UserOrGroupId = str ,AccountAccessLevel='Read',OpportunityAccessLevel='None' ,contactAccessLevel='None'));
                                        
                                    }
                                }
                            }
                            
                            system.debug('ListSchoolToBeShared-->'+ListSchoolToBeShared.size());
                            
                            for(AccountShare accshare : [select Id,accountid,UserOrGroupId from AccountShare where  UserOrGroupId in :userids and  accountid in :accountidstobedeleted]){
                                listSchoolToBeDeleted.add(accshare);
                                
                                
                            }
                            system.debug('listSchoolToBeDeleted-->'+listSchoolToBeDeleted.size());
                        }
                        
                        /*      for( Account acc : [select Maxway_School__c,NIN__c,Visible_to_Agent__c,School_s_Country__c from Account where RecordtypeId in :recordtypeids and School_s_Country__c in :countrylist  and Owner.IsPortalEnabled = false]){
if(acc.Visible_to_Agent__c == 'Yes'){
for(string str : userids)
ListSchoolToBeShared.add(new AccountShare ( AccountId = acc.id ,UserOrGroupId = str ,AccountAccessLevel='Read',OpportunityAccessLevel='None' ,contactAccessLevel='None')); 
}
} */
                        if(listSchoolToBeDeleted.size()>0) database.delete(listSchoolToBeDeleted,false);
                        if(ListSchoolToBeShared.size()>0) insert ListSchoolToBeShared;
                        
                        
                    }
                    else if(!string.isNotBlank(triggernew.School_List_Purchased__c) && string.isNotBlank(countrylistold)){
                        list<string> oldcountrylist = new list<string>();
                        
                        if(countrylistold.contains(';')) oldcountrylist = countrylistold.split(';');   
                        else  oldcountrylist.add(countrylistold);
                        
                        for( Account acc : [select Maxway_School__c,NIN__c,Visible_to_Agent__c,School_s_Country__c from Account where RecordtypeId in :recordtypeids and School_s_Country__c in :oldcountrylist  and Owner.IsPortalEnabled = false and Visible_to_Agent__c='Yes']){
                            
                            accountidstobedeleted.add(acc.id);
                            system.debug(acc.id);
                        }
                        
                        for(AccountShare accshare : [select Id,accountid,UserOrGroupId from AccountShare where  UserOrGroupId in :userids and  accountid in :accountidstobedeleted]){
                            listSchoolToBeDeleted.add(accshare);  
                            
                        }
                        if(listSchoolToBeDeleted.size()>0)  database.delete(listSchoolToBeDeleted,false);
                    }
                    
                    else if(string.isNotBlank(triggernew.School_List_Purchased__c) && !string.isNotBlank(countrylistold)){
                        list<string> countrylist = new list<string>();
                        
                        if(triggernew.School_List_Purchased__c.contains(';'))  countrylist = triggernew.School_List_Purchased__c.split(';');  
                        else  countrylist.add(triggernew.School_List_Purchased__c);
                        
                        for (account acc : [select OwnerId,Owner.contact.accountid,Maxway_School__r.Ownerid,NIN__c,Visible_to_Agent__c,Maxway_School__c,Maxway_School__r.School_s_Country__c from account where recordtypeid  in :recordtypeids and NIN__c ='Yes' and Maxway_School__c != null and OwnerId in :userids and Maxway_School__r.School_s_Country__c in :countrylist and Maxway_School__r.Visible_to_Agent__c ='Yes']){
                            accountidsnottobeshared.add(acc.Maxway_School__c);  
                        }
                        
                        for( Account acc : [select Maxway_School__c,NIN__c,Visible_to_Agent__c,School_s_Country__c from Account where RecordtypeId in :recordtypeids and School_s_Country__c in :countrylist  and Owner.IsPortalEnabled = false and Visible_to_Agent__c='Yes']){  
                            if( !accountidsnottobeshared.contains(acc.id)){
                                for(string str : userids){
                                    ListSchoolToBeShared.add(new AccountShare ( AccountId = acc.id ,UserOrGroupId = str ,AccountAccessLevel='Read',OpportunityAccessLevel='None' ,contactAccessLevel='None'));  
                                }
                            }
                        }
                        if(ListSchoolToBeShared.size()>0)  insert ListSchoolToBeShared;
                        
                    }
                    else{
                        for( Account acc : [select Maxway_School__c,NIN__c,Visible_to_Agent__c,School_s_Country__c from Account where RecordtypeId in :recordtypeids   and Owner.IsPortalEnabled = false and Visible_to_Agent__c='Yes']){
                            accountidstobedeleted.add(acc.id);
                            system.debug(acc.id);
                        }
                        
                        for(AccountShare accshare : [select Id,accountid,UserOrGroupId from AccountShare where  UserOrGroupId in :userids and  accountid in :accountidstobedeleted]){
                            listSchoolToBeDeleted.add(accshare);   
                        }
                        if(listSchoolToBeDeleted.size()>0)
                            database.delete(listSchoolToBeDeleted,false);
                    }
                }
            }  
        }   
    }
    
}
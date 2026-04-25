public class WABAUpdateChatResponseLogs implements Database.Batchable<Sobject>,Database.stateful,Schedulable{
    public List<String> successLog = new List<String>();
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id,watbox_platform__Info__c FROM watbox_platform__WA_Info__c where createdDate = LAST_N_DAYS:'+System.Label.WA_Update_Response_Log_Day;
        return Database.getQueryLocator(query);  
    }
    public void execute(Database.BatchableContext BC,List<watbox_platform__WA_Info__c> responseLog){
        map<String,String> wabaIdStatusStringMap = new Map<String,String>();
        map<String,String> wabaIdStatusStringDeliveredMap = new Map<String,String>();
        map<String,String> wabaIdStatusStringReadMap = new Map<String,String>();
        map<Id,watbox_platform__WABA_Chat_Message__c> chatMsgMap = new map<Id,watbox_platform__WABA_Chat_Message__c>();
        map<String,List<RecieveWebHookWrapper.error_cls>> wabaIderrorListMap = new Map<String,List<RecieveWebHookWrapper.error_cls>>();
        List<watbox_platform__WABA_Chat_Message__c> priorMsgList = new List<watbox_platform__WABA_Chat_Message__c>();
        for(watbox_platform__WA_Info__c logData : responseLog){
            RecieveWebHookWrapper webHookResponse = (RecieveWebHookWrapper) JSON.deserialize(logData.watbox_platform__Info__c,RecieveWebHookWrapper.class);
            List<RecieveWebHookWrapper.entry_cls> entryList = webHookResponse.entry;
            List<RecieveWebHookWrapper.changes_cls> changeList;
            List<RecieveWebHookWrapper.status_cls> statusList;
            List<RecieveWebHookWrapper.error_cls> errorList;
            RecieveWebHookWrapper.cls_value values;
            String status;
            String msgId;
            if(entryList != null && !entryList.isEmpty()) {
                changeList = entryList[0].changes;
            }
            if(changeList != null && !changeList.isEmpty()) {
                values = changeList[0].value;
            }
            if(values != null ) {
                statusList = values.statuses;
            }
            if(statusList != null && !statusList.isEmpty()) {
                msgId = statusList[0].id;
                status = statusList[0].status;
                errorList = statusList[0].errors;
                if(status != null && status != 'failed'){
                    if(status == 'sent') {
                     wabaIdStatusStringMap.put(msgId,status);
                    }
                    if(status == 'delivered') {
                     wabaIdStatusStringDeliveredMap.put(msgId,status);
                    }
                    if(status == 'read') {
                     wabaIdStatusStringReadMap.put(msgId,status);
                    }
                }
                if(errorList != null && !errorList.isEmpty()) {
                    wabaIderrorListMap.put(msgId,errorList);
                }
                
            }
            
        }
        if(wabaIdStatusStringMap != null) {
            for(watbox_platform__WABA_Chat_Message__c chatMsg : [SELECT Id, Name, watbox_platform__WA_Message_Id__c, watbox_platform__Is_Read__c,watbox_platform__Error_Message__c,watbox_platform__Error_Details__c,
                                                          watbox_platform__Error_Code__c, watbox_platform__Is_Sent__c, watbox_platform__Is_Delivered__c FROM watbox_platform__WABA_Chat_Message__c 
                                                          WHERE watbox_platform__WA_Message_Id__c =:wabaIdStatusStringMap.KeySet() AND watbox_platform__Is_Sent__c = false 
                                                          AND watbox_platform__Is_Delivered__c = false AND watbox_platform__Is_Read__c = false AND watbox_platform__Error_Message__c = '']){
                                                              String status = wabaIdStatusStringMap.get(chatMsg.watbox_platform__WA_Message_Id__c);
                                                              chatMsg.watbox_platform__Is_Sent__c = (status == 'sent');
                                                              chatMsgMap.put(chatMsg.Id,chatMsg);
                                                          }
        }
        if(wabaIdStatusStringDeliveredMap != null) {
            for(watbox_platform__WABA_Chat_Message__c chatMsg : [SELECT Id, Name, watbox_platform__WA_Message_Id__c, watbox_platform__Is_Read__c,watbox_platform__Error_Message__c,watbox_platform__Error_Details__c,
                                                          watbox_platform__Error_Code__c, watbox_platform__Is_Sent__c, watbox_platform__Is_Delivered__c FROM watbox_platform__WABA_Chat_Message__c 
                                                          WHERE watbox_platform__WA_Message_Id__c =:wabaIdStatusStringDeliveredMap.KeySet() AND watbox_platform__Is_Sent__c = false 
                                                          AND watbox_platform__Is_Delivered__c = false AND watbox_platform__Is_Read__c = false AND watbox_platform__Error_Message__c = '']){
                                                              String status = wabaIdStatusStringDeliveredMap.get(chatMsg.watbox_platform__WA_Message_Id__c);
                                                              chatMsg.watbox_platform__Is_Delivered__c = (status == 'read' || status == 'delivered');
                                                              chatMsg.watbox_platform__Is_Sent__c = (status == 'read' || status == 'delivered' || status == 'sent');
                                                              chatMsgMap.put(chatMsg.Id,chatMsg);
                                                          }
        }
        if(wabaIdStatusStringReadMap != null) {
            for(watbox_platform__WABA_Chat_Message__c chatMsg : [SELECT Id, Name, watbox_platform__WA_Message_Id__c, watbox_platform__Is_Read__c,watbox_platform__Error_Message__c,watbox_platform__Error_Details__c,
                                                          watbox_platform__Error_Code__c, watbox_platform__Is_Sent__c, watbox_platform__Is_Delivered__c FROM watbox_platform__WABA_Chat_Message__c 
                                                          WHERE watbox_platform__WA_Message_Id__c =:wabaIdStatusStringReadMap.KeySet() AND watbox_platform__Is_Sent__c = false 
                                                          AND watbox_platform__Is_Delivered__c = false AND watbox_platform__Is_Read__c = false AND watbox_platform__Error_Message__c = '']){
                                                              String status = wabaIdStatusStringReadMap.get(chatMsg.watbox_platform__WA_Message_Id__c);
                                                              chatMsg.watbox_platform__Is_Read__c = (status == 'read');
                                                              chatMsg.watbox_platform__Is_Delivered__c = (status == 'read' || status == 'delivered');
                                                              chatMsg.watbox_platform__Is_Sent__c = (status == 'read' || status == 'delivered' || status == 'sent');
                                                              chatMsgMap.put(chatMsg.Id,chatMsg);
                                                          }
        }
        if(wabaIderrorListMap != null) {
            for(watbox_platform__WABA_Chat_Message__c chatMsg : [SELECT Id, Name, watbox_platform__WA_Message_Id__c, watbox_platform__Is_Read__c,watbox_platform__Error_Message__c,watbox_platform__Error_Details__c,
                                                          watbox_platform__Error_Code__c, watbox_platform__Is_Sent__c, watbox_platform__Is_Delivered__c FROM watbox_platform__WABA_Chat_Message__c 
                                                          WHERE watbox_platform__WA_Message_Id__c =:wabaIderrorListMap.KeySet() AND watbox_platform__Is_Sent__c = false 
                                                          AND watbox_platform__Is_Delivered__c = false AND watbox_platform__Is_Read__c = false AND watbox_platform__Error_Message__c = '']){
                                                              List<RecieveWebHookWrapper.error_cls> errorList = wabaIderrorListMap.get(chatMsg.watbox_platform__WA_Message_Id__c);
                                                              chatMsg.watbox_platform__Error_Message__c = errorList[0].message;
                                                              chatMsg.watbox_platform__Error_Details__c = errorList[0].title;
                                                              chatMsg.watbox_platform__Error_Code__c = errorList[0].code;
                                                              chatMsgMap.put(chatMsg.Id,chatMsg);
                                                          }
        }
        if(chatMsgMap != null){
            priorMsgList.addAll(chatMsgMap.values());
            System.debug('priorMsgList==>'+priorMsgList);
            try {
                List<Database.SaveResult>  srList =  Database.update(priorMsgList,false);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully updated ID : ' + sr.getId());
                        successLog.add('Successfully updated ID : ' + sr.getId()+','+'\n');
                    }
                }
            }
            catch(DmlException e){
                System.debug('Exception'+ + e.getMessage());
            }
        }
        
    }
    
    public void Finish(Database.BatchableContext BC){
        System.debug('WABA_TaskScheduleBatch: Finished processing all chunks');  
        
        
        
    }
    public void execute(SchedulableContext SC) {
        database.executebatch(new WABAUpdateChatResponseLogs());
    }
}
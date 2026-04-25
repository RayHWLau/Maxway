public with sharing class SearchSObjectWrapper {
	public SObject obj {get;set;}
	public boolean selected {get;set;}
	public SearchSObjectWrapper(String SObjectType) {
		this.selected = false;
		if(SObjectType == 'Program__c') {
            this.obj = new Program__c();
        } else if(SObjectType == 'Major__c') {
            this.obj = new Major__c();
        } else if(SObjectType == 'Account') {
            this.obj = new Account();
        }
	}
	public SearchSObjectWrapper(Sobject s) {
		this.selected = false;
		this.obj = s;
	}
}
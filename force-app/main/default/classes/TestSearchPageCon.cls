@isTest
private class TestSearchPageCon {
    static testMethod void testSearchUni() {
    	 
    	Major__c m1 = TestDataFactory.getMajor();
    	SearchPageCon ctrl = new SearchPageCon();
    	ctrl.selectedRecordType = 'Uni';
    	ctrl.programType = 'Bachelor';
    	ctrl.selectedProgramTypeOptions='Bachelor';
    	ctrl.sow.obj.put('Country__c','US');
    	ctrl.sow.obj.put('Major_filter__c','Test');		
		List<SelectOption> rts = ctrl.availableRecordTypes;
		ctrl.changeSearchType();
		ctrl.changeProgramType();
		List<SelectOption> pts = ctrl.refreshProgramTypeOptions();
		List<SelectOption> tufees = ctrl.getAnnualTuitionFeesOptions();
		List<SelectOption> hsos = ctrl.getHousingOptions();
		List<Schema.FieldSetMember> fs = ctrl.getSearchFieldSet();
		List<Schema.FieldSetMember> fs2 = ctrl.getResultFieldSet();
		ctrl.changeCountry();
    	PageReference pr1 = ctrl.search();
    	String s1 =ctrl.query;
    	String s2 =ctrl.queryCount;
    	Boolean b;
    	if(ctrl.sows.size() >0) {
	    	b=ctrl.hasNext;
	    	b=ctrl.hasPrevious;
	    	Integer i;
	    	i=ctrl.pageNumber;
	    	i=ctrl.totalPages;
	    	ctrl.first();
	    	ctrl.last();
	    	ctrl.previous();
	    	ctrl.next();
    	}
    	PageReference pr2= ctrl.addToOpp();
    	PageReference pr3 = ctrl.saveRS();
    }

	static testMethod void testSearchCC() {
    	 
    	Major__c m1 = TestDataFactory.getMajor();
    	SearchPageCon ctrl = new SearchPageCon();
    	ctrl.selectedRecordType = 'CC';
    	ctrl.programType = 'ESL';
    	ctrl.selectedProgramTypeOptions='ESL';
    	ctrl.sow.obj.put('Country__c','US');
    	ctrl.sow.obj.put('Est_Annual_Cost__c',100000);
		List<SelectOption> pts = ctrl.refreshProgramTypeOptions();
		List<Schema.FieldSetMember> fs2 = ctrl.getResultFieldSet();
		ctrl.changeCountry();
    	PageReference pr1 = ctrl.search();

    }

    static testMethod void testSearchHS() {
    	 
    	Major__c m1 = TestDataFactory.getMajor();
    	SearchPageCon ctrl = new SearchPageCon();
    	ctrl.selectedRecordType = 'HighSchool';
    	ctrl.programType = 'ESL';
    	ctrl.selectedProgramTypeOptions='ESL';
    	ctrl.sow.obj.put('Country__c','US');
    	ctrl.selectedHouseingOptions ='Homestay';    	
    	ctrl.sow.obj.put('Est_Annual_Cost__c',120000);
    	ctrl.selectedAnnualTuitionFeesOptions = '200000';
		List<SelectOption> pts = ctrl.refreshProgramTypeOptions();
		List<Schema.FieldSetMember> fs2 = ctrl.getResultFieldSet();
		ctrl.changeCountry();
    	PageReference pr1 = ctrl.search();

    }

    static testMethod void testSearchESL() {
    	 
    	Major__c m1 = TestDataFactory.getMajor();
    	SearchPageCon ctrl = new SearchPageCon();
    	ctrl.selectedRecordType = 'ESL';
    	ctrl.programType = 'ESL';
    	ctrl.selectedProgramTypeOptions='ESL';
    	ctrl.sow.obj.put('Country__c','US');
    	ctrl.selectedHouseingOptions ='Homestay';
		List<SelectOption> pts = ctrl.refreshProgramTypeOptions();
		List<Schema.FieldSetMember> fs2 = ctrl.getResultFieldSet();
		ctrl.changeCountry();
    	PageReference pr1 = ctrl.search();

    }
}
public class SearchPageCon {
	public SearchSObjectWrapper sow {get;set;}
	public List<SearchSObjectWrapper> sows {get;set;}
	public Recommended_Schools__c rs {get;set;}
	//public SObject filterObj {get;set;}
	//public SObject resultObj {get;set;}
	//public List<SObject> objList {get;set;}
	public boolean bShowFilterPanel {get;set;}
	public boolean bShowResultPanel {get;set;}
	public boolean bShowErrorMessage {get;set;}
	public boolean bShowNonCommission {get;set;}
    public String programType {get;set;}
	Integer pageSize;
	public SearchPageCon() {
		//system.debug('@@@ ini sow ' + sow);
    	//system.debug('@@@ ini sow obj ' + sow.obj);
    	pageSize = 5;
    	try {
    		pageSize = Integer.valueOf(Label.PageSize);
    	} catch (exception e) {
    		pageSize = 5;
    	}
    	
		if(this.sow == null) {
			this.sow = new SearchSObjectWrapper('Account');
		}
		if(sows == null) {
			sows = new List<SearchSObjectWrapper>();
		}
		bShowFilterPanel = false;
		bShowResultPanel = false;
		bShowErrorMessage = false;
		bShowNonCommission = false;
		selectedAnnualTuitionFeesOptions = '';
		selectedHouseingOptions = '';
        programType='';
		//if(filterObj == null) {
		//	filterObj = new Account();
		//}
		//if(objList == null) {
		//	objList = new List<SObject>();
		//}
		if(selectedIds == null) {
			 selectedIds = new List<Id>();
		}
		//if(selectednames == null) {
		//	 selectednames = new List<String>();
		//}
		
		if(rs == null) {
			rs = new Recommended_Schools__c();
		}
        programTypeOptions = refreshProgramTypeOptions();
	}	
    
    public String selectedRecordType {get;set;}
    //return a list of selection options for available record types
    public List<SelectOption> availableRecordTypes {        
        get {
            List<SelectOption> result = new List<SelectOption>();
	    	result.add(new SelectOption('HighSchool','High School'));	    	
			result.add(new SelectOption('ESL','ESL'));
            result.add(new SelectOption('Uni','University'));
            result.add(new SelectOption('CC','CC'));
	    	return result;
        }
        set;
    }    
    
    public void changeSearchType() {
        programTypeOptions = refreshProgramTypeOptions();
    	bShowFilterPanel = true;
        bShowResultPanel = false;
        if(selectedRecordType =='Uni') {
        	sow.obj.put('RecordTypeId', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Overseas School - University').getRecordTypeId());
        } else if(selectedRecordType =='CC') {
        	sow.obj.put('RecordTypeId', Schema.SObjectType.Account.getRecordTypeInfosByName().get('Overseas School - CC').getRecordTypeId());
        }
        system.debug('@@@ rt ' + sow);
    }

    public void changeProgramType() {
        bShowFilterPanel = true;
        bShowResultPanel = false;
        programType = selectedProgramTypeOptions;
    }
    
    public void changeCountry() {        
    	Sobject tmpSObj = sow.obj;
    	//String queryISOCode = '';
    	for(Schema.FieldSetMember f : this.getSearchFieldSet()) {
			if(f.getFieldPath() == 'Country__c') {
				if(tmpSObj.get(f.getFieldPath()) != null && tmpSObj.get(f.getFieldPath()) != '') {					
					queryISOCode = getQueryCurrencyISOCode((String)tmpSObj.get(f.getFieldPath()));
				} else {
					queryISOCode = '';
				}
			}
    	}
    }
    
	public List<Schema.FieldSetMember> getSearchFieldSet() {
		List<Schema.FieldSetMember> fieldSetMembers = new List<Schema.FieldSetMember>();
		//Different search fieldset for each search type
		if(!String.isBlank(selectedRecordType)) {
			fieldSetMembers = getFieldSet('Account', true);
		}
		System.debug('*** selectedRecordType: ' + selectedRecordType + '');
        System.debug('*** fieldSetMembers: ' + fieldSetMembers + '');
		return fieldSetMembers;
    }
    
    public List<Schema.FieldSetMember> getResultFieldSet() {
    	List<Schema.FieldSetMember> fieldSetMembers = new List<Schema.FieldSetMember>();
    	//Different result fieldset for each search type    
		if(!String.isBlank(selectedRecordType)) {
			if(selectedRecordType == 'HighSchool' || selectedRecordType == 'ESL') {
				fieldSetMembers = getFieldSet('Program__c', false);
			} else if(selectedRecordType == 'Uni' || selectedRecordType == 'CC') {
				fieldSetMembers = getFieldSet('Major__c', false);
			} else {
				fieldSetMembers = getFieldSet('Account', true);
			}
		}
		return fieldSetMembers;
    }
        
    //get all field sets from the input object name
    public List<Schema.FieldSetMember> getFieldSet(String sObjectName, Boolean bFilters) { 
            
        Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(sObjectName);
        Schema.DescribeSObjectResult sObjResult = sObjType.getDescribe();
        Schema.DescribeFieldResult fieldResult;
        List<Schema.FieldSetMember> filterFields = new List<Schema.FieldSetMember>();
        List<Schema.FieldSetMember> fieldSet = new List<Schema.FieldSetMember>();
        //ApexPages.Message msgFieldSetMissing = new ApexPages.Message(ApexPages.Severity.WARNING, Label.Library_MSG_NotConfig);
        
        if(sObjectName == 'Account') {
            //this.filterObj = new Account(); 
            if(bFilters) { //Filter Fieldset
                if(Schema.SObjectType.Account.fieldSets.getMap().get(selectedRecordType + 'Filters') != null) {
                    fieldSet = Schema.SObjectType.Account.fieldSets.getMap().get(selectedRecordType + 'Filters').getFields();                    
                }
            }
        } else if(sObjectName == 'Program__c') {
            //this.resultObj = new Program__c(); 
            if(!bFilters) { //Result Fieldset
                if(Schema.SObjectType.Program__c.fieldSets.getMap().get(selectedRecordType + 'Result') != null) {
                    fieldSet = Schema.SObjectType.Program__c.fieldSets.getMap().get(selectedRecordType + 'Result').getFields();                    
                }             	
                //else {
                    //ApexPages.addMessage(msgFieldSetMissing);
                //}
            }
        } else if(sObjectName == 'Major__c') {
            //this.resultObj = new Program__c(); 
            if(!bFilters) { //Result Fieldset
                if(Schema.SObjectType.Major__c.fieldSets.getMap().get(selectedRecordType + 'Result') != null) {
                    fieldSet = Schema.SObjectType.Major__c.fieldSets.getMap().get(selectedRecordType + 'Result').getFields();                    
                }             	
                //else {
                    //ApexPages.addMessage(msgFieldSetMissing);
                //}
            }
        }
        for(Schema.FieldSetMember fs : fieldSet) {                
            //Add field level security checking
            if(sObjResult.fields.getMap().get(fs.getFieldPath()).getDescribe().isAccessible()) {      
            	if(bFilters) {               
	                //Find out all non-formula fields
	                if(!sObjResult.fields.getMap().get(fs.getFieldPath()).getDescribe().isCalculated()) {
	                    filterFields.add(fs);
	                }
            	} else {
            		filterFields.add(fs);
            	}
            }
        }
        return filterFields;
    }
    
    public List<SelectOption> programTypeOptions {get;set;}

    public List<SelectOption> refreshProgramTypeOptions() {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('','--None-'));
        if(selectedRecordType == 'ESL') {
            result.add(new SelectOption('ESL', 'ESL'));
        } else if(selectedRecordType == 'HighSchool') {
            result.add(new SelectOption('3Y A-Level', '3Y A-Level'));
			result.add(new SelectOption('A-Level', 'A-Level'));
			result.add(new SelectOption('AP', 'AP'));
			result.add(new SelectOption('Canadian High School Diploma', 'Canadian High School Diploma'));
			result.add(new SelectOption('ESL', 'ESL'));
			result.add(new SelectOption('Fast Track GCSE', 'Fast Track GCSE'));
			result.add(new SelectOption('GCSE', 'GCSE'));
			result.add(new SelectOption('Gifted', 'Gifted'));
			result.add(new SelectOption('IB', 'IB'));
			result.add(new SelectOption('Learning Differences', 'Learning Differences'));			
			result.add(new SelectOption('Performing Arts', 'Performing Arts'));
			result.add(new SelectOption('Sports Academy', 'Sports Academy'));
			result.add(new SelectOption('Summer', 'Summer'));
			result.add(new SelectOption('US High School Diploma', 'US High School Diploma'));			
			result.add(new SelectOption('Visual Arts', 'Visual Arts'));
        } else if(selectedRecordType == 'Uni') {
            result.add(new SelectOption('Advanced Diploma', 'Advanced Diploma'));
			result.add(new SelectOption('Associate Degree', 'Associate Degree'));
			result.add(new SelectOption('Bachelor', 'Bachelor'));
			result.add(new SelectOption('Certificate', 'Certificate'));
			result.add(new SelectOption('Diploma', 'Diploma'));
			result.add(new SelectOption('Dual Admission', 'Dual Admission'));
			result.add(new SelectOption('ESL', 'ESL'));			
			result.add(new SelectOption('Foundation', 'Foundation'));
			result.add(new SelectOption('IY1', 'IY1'));			
			result.add(new SelectOption('Master', 'Master'));			
			result.add(new SelectOption('Pre-Master', 'Pre-Master'));
			result.add(new SelectOption('Top-up', 'Top-up'));
        } else if(selectedRecordType == 'CC') {        	
        	result.add(new SelectOption('1Y GCSE', '1Y GCSE'));
        	result.add(new SelectOption('3Y A-Level', '3Y A-Level'));
            result.add(new SelectOption('Advanced Diploma', 'Advanced Diploma'));
			result.add(new SelectOption('A-Level', 'A-Level'));
			result.add(new SelectOption('Associate Degree', 'Associate Degree'));
			result.add(new SelectOption('Bachelor', 'Bachelor'));			
			result.add(new SelectOption('BTEC', 'BTEC'));			
			result.add(new SelectOption('Certificate', 'Certificate'));
			result.add(new SelectOption('ESL', 'ESL'));
			result.add(new SelectOption('Foundation', 'Foundation'));
			result.add(new SelectOption('GCSE', 'GCSE'));
			result.add(new SelectOption('HNC', 'HNC'));
			result.add(new SelectOption('HND', 'HND'));
			result.add(new SelectOption('HS Completion', 'HS Completion'));
			result.add(new SelectOption('Post Graduate Diploma', 'Post Graduate Diploma'));
        }
        /* else {
            Schema.DescribeFieldResult fieldResult = Account.HS_Program_Type__c.getDescribe();
            if(selectedRecordType == 'HighSchool') {
                fieldResult = Account.HS_Program_Type__c.getDescribe();
            } else if(selectedRecordType == 'Uni') {
                fieldResult = Account.Uni_Program_Type__c.getDescribe();
            } else if(selectedRecordType == 'CC') {
                fieldResult = Account.CC_Program_Type__c.getDescribe();
            }
            
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();        
            result.add(new SelectOption('','--None-'));
            for( Schema.PicklistEntry f : ple) {
                result.add(new SelectOption(f.getLabel(), f.getValue()));
            }
        }*/
        return result;
    }
    public String selectedProgramTypeOptions {get;set;} 
	/*
    public List<SelectOption> getAnnualTuitionFeesOptions() {
    	List<SelectOption> result = new List<SelectOption>();
    	result.add(new SelectOption('','--None-'));
    	result.add(new SelectOption('99999','HKD 99,999 or less'));
    	result.add(new SelectOption('100000','HKD 100,000-199,999'));
    	result.add(new SelectOption('200000','HKD 200,000-299,999'));
		result.add(new SelectOption('300000','HKD 300,000-399,999'));        
        result.add(new SelectOption('400000','HKD 400,000-499,999'));
		result.add(new SelectOption('500000','HKD 500,000 or above'));
    	return result;
    }
    */
    public List<SelectOption> getAnnualTuitionFeesOptions() {    
    	List<SelectOption> result = new List<SelectOption>();
    	if(queryISOCode == '') {
    		result.add(new SelectOption('','--Please select country-'));
    		return result;
    	}    	
    	result.add(new SelectOption('','--None-'));
    	result.add(new SelectOption('9999',queryISOCode+' 9,999 or less'));
    	result.add(new SelectOption('10000',queryISOCode+' 10,000 - '+queryISOCode+' 19,999'));
    	result.add(new SelectOption('20000',queryISOCode+' 20,000 - '+queryISOCode+' 29,999'));
		result.add(new SelectOption('30000',queryISOCode+' 30,000 - '+queryISOCode+' 39,999'));        
        result.add(new SelectOption('40000',queryISOCode+' 40,000 - '+queryISOCode+' 49,999'));
		result.add(new SelectOption('50000',queryISOCode+' 50,000 - '+queryISOCode+' 59,999'));
		result.add(new SelectOption('60000',queryISOCode+' 60,000 - '+queryISOCode+' 69,999'));
		result.add(new SelectOption('70000',queryISOCode+' 70,000 or above'));
    	return result;
    }
    public String selectedAnnualTuitionFeesOptions {get;set;} 
    
    public List<SelectOption> getHousingOptions() {
    	List<SelectOption> result = new List<SelectOption>();    	
        result.add(new SelectOption('','--None-'));
    	result.add(new SelectOption('Homestay','Homestay'));
    	result.add(new SelectOption('Dorm','Dorm'));
		result.add(new SelectOption('F. Apt','F. Apt'));
		//result.add(new SelectOption('Self-arranged','Self-arranged'));
    	return result;
    }
    
    public String selectedHouseingOptions {get;set;} 
    public String query {get;set;}
    public String queryCount {get;set;}  
    String queryISOCode ='';
    private Boolean bFillAllMandatory() {
    	Sobject tmpObj;
    	//tmpObj = filterObj;
        tmpObj = sow.obj;
        System.debug('*** tmpObj: ' + tmpObj + '');
        Boolean bFilled = false;
        if(selectedProgramTypeOptions == '' || selectedProgramTypeOptions == null) {
            return false;
        } else {
    		for(Schema.FieldSetMember f : this.getSearchFieldSet()) {
    			if(f.getFieldPath() == 'Country__c') {
    				if(tmpObj.get(f.getFieldPath()) == null || tmpObj.get(f.getFieldPath()) == '') {
	    				return false;
	    			} else {
	    				//queryISOCode = getQueryCurrencyISOCode((String)tmpObj.get(f.getFieldPath()));
	    			}
    			//} else if(selectedRecordType == 'Uni' || selectedRecordType == 'CC') { 
    			//Not mandatory for CC as many CC programs do not have majors
    			} else if(selectedRecordType == 'Uni') {
                    System.debug('*** f.getFieldPath() 2 : ' + f.getFieldPath() + '');
                    if(f.getFieldPath() == 'Major_filter__c') {
                        System.debug('*** aaa : ');
                        if(tmpObj.get(f.getFieldPath()) == null || tmpObj.get(f.getFieldPath()) == '') {
                            System.debug('*** bbb : ');
                            return false;
                        } else {
                            System.debug('*** ccc : ');
                            bFilled = true;
                        }

                    }
                } else if(!bFilled) {
                    if(tmpObj.get(f.getFieldPath()) != null && tmpObj.get(f.getFieldPath()) != '') {
                        bFilled = true;
                    }                    
                    System.debug('*** f.getFieldPath(): ' + f.getFieldPath() + '');
                    System.debug('*** bFilled: ' + bFilled + '');
                }                
            }
            if(selectedRecordType == 'HighSchool' || selectedRecordType == 'ESL') {
                if(!bFilled) {
                    System.debug('*** selectedAnnualTuitionFeesOptions: ' + selectedAnnualTuitionFeesOptions + '');
                    System.debug('*** selectedHouseingOptions: ' + selectedHouseingOptions + '');
                    if(selectedAnnualTuitionFeesOptions != '' && selectedAnnualTuitionFeesOptions != null ) {
                        bFilled = true;
                        System.debug('*** bFilled 1.1 : ');
                    } else if(selectedHouseingOptions != '' && selectedHouseingOptions != null ) {
                        bFilled = true;
                        System.debug('*** bFilled 1.2 : ');
                    }
                }
            }
            else if(selectedRecordType == 'CC') {
                if(!bFilled) {
                    System.debug('*** selectedAnnualTuitionFeesOptions: ' + selectedAnnualTuitionFeesOptions + '');
                    if(selectedAnnualTuitionFeesOptions != '' && selectedAnnualTuitionFeesOptions != null ) {
                        bFilled = true;
                        System.debug('*** bFilled 1.3 : ');
                    }
                }
            }
            System.debug('*** bFilled 2 : ' + bFilled + '');
		}    	
    	return bFilled;
    }
    
    
    public ApexPages.StandardSetController con {get;set;}
    
    public PageReference search(){
    	this.sows.clear();
    	system.debug('@@@ sow ' + sow);
    	system.debug('@@@ sow obj ' + sow.obj);
    	bShowErrorMessage = false;
    	//this.objList.clear();
    	if(!bFillAllMandatory()) {
    		//show error message
    		//bShowErrorMessage = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please fill in at least 3 filters!'));
    		return null;
    	}
    	Sobject tmpObj;
    	tmpObj = sow.obj;//filterObj;
    	//system.debug('@@@ filterObj ' + filterObj);	
    	system.debug('@@@ tmpObj ' + tmpObj);
    	List<String> conditions = new List<String>();
    	//String 
    	query = 'SELECT ';
        for(Schema.FieldSetMember f : this.getResultFieldSet()) {
            query += f.getFieldPath() + ', ';
        }
        for(Schema.FieldSetMember f : this.getSearchFieldSet()) {
        	system.debug('@@@ tmpObj.get(f.getFieldPath()) ' + tmpObj.get(f.getFieldPath()));
    		system.debug('@@@ tmpObj sow.obj ' + sow.obj);
    		/*
    		if(f.getFieldPath() == 'Country__c') {
				if(tmpObj.get(f.getFieldPath()) != null && tmpObj.get(f.getFieldPath()) != '') {
    				queryISOCode = getQueryCurrencyISOCode((String)tmpObj.get(f.getFieldPath()));
    			}
			}
			*/
            if((tmpObj.get(f.getFieldPath()) != null && tmpObj.get(f.getFieldPath()) != '') || f.getFieldPath() == 'Est_Annual_Cost__c' || f.getFieldPath() == 'Housing_Option__c')  {
            	//Build Condition Logic Here
            	if(selectedRecordType == 'HighSchool' || selectedRecordType == 'ESL' || selectedRecordType == 'Uni' || selectedRecordType == 'CC') {
                    /*if(f.getFieldPath() == 'Est_Annual_Cost__c' && selectedRecordType != 'HighSchool') {*/
                    if(f.getFieldPath() == 'Est_Annual_Cost__c') {
            			if(selectedAnnualTuitionFeesOptions != '' && selectedAnnualTuitionFeesOptions != null) {
            				Integer selectedAmt = Integer.ValueOf(selectedAnnualTuitionFeesOptions);
            				Integer tmpAmt =  selectedAmt+10000;
            				if(selectedAmt>=10000) {
		            			conditions.add(' ' + f.getFieldPath() + ' >= ' + queryISOCode + selectedAnnualTuitionFeesOptions + '');
		            			if(selectedAmt <70000) {
		            				conditions.add(' ' + f.getFieldPath() + ' < ' + queryISOCode + tmpAmt);
		            			}
            				} else {
            					conditions.add(' ' + f.getFieldPath() + ' <= ' + queryISOCode + selectedAmt);
            				}
            			}  
            		}
            		/* else if(f.getFieldPath() == 'Est_Annual_Cost__c' && selectedRecordType == 'HighSchool') {
            			if(selectedAnnualTuitionFeesOptions != '' && selectedAnnualTuitionFeesOptions != null) {
            				Integer selectedAmt = Integer.ValueOf(selectedAnnualTuitionFeesOptions);
            				Integer tmpAmt =  selectedAmt+10000;
            				if(selectedAmt>=10000) {
		            			conditions.add(' HS_Est_Annual_Cost__c >= ' + queryISOCode + selectedAnnualTuitionFeesOptions + '');
		            			if(selectedAmt <70000) {
		            				conditions.add(' HS_Est_Annual_Cost__c < ' + queryISOCode + tmpAmt);
		            			}
            				} else {
            					conditions.add(' HS_Est_Annual_Cost__c <= ' + queryISOCode + selectedAmt);
            				}
            			} 
            		 
            		} */
            		else if(f.getFieldPath() == 'Housing_Option__c') {
            			if(selectedHouseingOptions != '' && selectedHouseingOptions != null) {
            				conditions.add(' ' + f.getFieldPath() + ' LIKE \'%' + selectedHouseingOptions + '%\'');
            			}		
            		} else if(f.getFieldPath() == 'Nearest_Big_City__c' || f.getFieldPath() == 'Tech_Nearest_City__c') {
            			/*String cityCond = ' (';
            			cityCond +=' Nearest_Big_City__c = \'' + tmpObj.get(f.getFieldPath()) + '\' OR ';
            			cityCond +=' Nearest_Big_City_2__c = \'' + tmpObj.get(f.getFieldPath()) + '\' OR ';
            			cityCond +=' Nearest_Big_City_3__c = \'' + tmpObj.get(f.getFieldPath()) + '\'';
            			cityCond += ') ';
            			conditions.add(cityCond);
            			*/
            			//String city='';
            			//String tmp = (String) tmpObj.get(f.getFieldPath());
            			//for(String str: tmp.split(';')){
            			//	city+='\'' + str + '\';';
            			//}
            			//conditions.add(' ' + f.getFieldPath() + ' IN (' + '\'' + tmp.replace(';','\';\'') + '\'' + ')');
            			conditions.add(' Tech_Nearest_City__c LIKE \'%' + tmpObj.get(f.getFieldPath()) + '%\'');
            		} else if(f.getFieldPath() == 'Major_filter__c') {
                        conditions.add(' Name LIKE \'%' + tmpObj.get(f.getFieldPath()) + '%\'');
                    } else if(f.getFieldPath() == 'Client_s_SAT__c') {
                        conditions.add(' ( Program__r.SAT_Combined_Low__c <=' + tmpObj.get(f.getFieldPath()) + ' OR ( Program__r.SAT_Combined_Low__c = null )) ');
                    } else if(f.getFieldPath() == 'Client_s_ACT__c') {
                        conditions.add(' ( Program__r.ACT_Combined_Low__c <=' + tmpObj.get(f.getFieldPath()) + ' OR ( Program__r.ACT_Combined_Low__c = null )) ');
                    } else if(f.getFieldPath() == 'Client_s_GMAT__c') {
                        conditions.add(' ( GMAT_Min__c <=' + tmpObj.get(f.getFieldPath()) + ' OR ( GMAT_Min__c = null )) ');
                    } else if(f.getFieldPath() == 'Client_s_GRE__c') {
                        conditions.add(' ( GRE_Min__c <=' + tmpObj.get(f.getFieldPath()) + ' OR ( GRE_Min__c = null )) ');
                    } 
                    else {
            			conditions.add(' ' + f.getFieldPath() + ' = \'' + tmpObj.get(f.getFieldPath()) + '\'');
            		}
            	}
            }
        }
        query += 'Id, Name ';
        queryCount = 'SELECT COUNT() ';
        if(selectedRecordType == 'HighSchool' || selectedRecordType == 'ESL') {
        	query += ' ,Tech_Id__c ';
			query += ' FROM Program__c ';            
			queryCount += ' FROM Program__c ';
			//conditions.add(' RecordType.developerName = \' '+ selectedRecordType + '\' ');
		} else {
			query += ' ,Tech_Id__c ';
            query += ' FROM Major__c';
			queryCount += ' FROM Major__c ';
		}

        if(selectedRecordType == 'HighSchool') {
            query += ' Where RecordType.DeveloperName =\'HighSchool\' ';
            queryCount += ' Where RecordType.DeveloperName =\'HighSchool\' ';
        } else if(selectedRecordType == 'ESL') {
            query += ' Where RecordType.DeveloperName =\'ESL\' ';
            queryCount += ' Where RecordType.DeveloperName =\'ESL\' ';
        } else if(selectedRecordType == 'Uni') {
            query += ' Where Program__r.RecordType.DeveloperName =\'Uni\' ';
            queryCount += ' Where Program__r.RecordType.DeveloperName =\'Uni\' ';
        } else if(selectedRecordType == 'CC') {
            query += ' Where Program__r.RecordType.DeveloperName =\'CC\' ';
            queryCount += ' Where Program__r.RecordType.DeveloperName =\'CC\' ';
        }
        if(selectedProgramTypeOptions != null) {
            query += ' AND Program_Type__c = \'' + selectedProgramTypeOptions + '\' ';
            queryCount += ' AND Program_Type__c = \'' + selectedProgramTypeOptions + '\' ';
        }

        if(!bShowNonCommission) {
            if(selectedRecordType == 'HighSchool' || selectedRecordType == 'ESL') {
                query += ' AND Campus__r.Account__r.Partner_Type__c = \'Commission\' ';
                queryCount += ' AND Campus__r.Account__r.Partner_Type__c = \'Commission\' ';
            } else if(selectedRecordType == 'Uni' || selectedRecordType == 'CC') {
                query += ' AND Program__r.Campus__r.Account__r.Partner_Type__c = \'Commission\' ';
                queryCount += ' AND Program__r.Campus__r.Account__r.Partner_Type__c = \'Commission\' ';
            }
        }

        if(!conditions.isEmpty()) {
        	query = query + ' AND' + String.format(' {0}', new List<String>{ String.join(conditions, ' AND ') });
        	queryCount = queryCount + ' AND ' + String.format(' {0}', new List<String>{ String.join(conditions, ' AND ') });
        }
        system.debug('@@@ conditions ' + conditions);
        system.debug('@@@ query ' + query);
        system.debug('@@@ con ' + con);
        //query +=  ' Where recordType.developername = \'High_School_Program\' ';
        //query +=  ' Where country__c != \'\' ';
		/*
        if(selectedRecordType == 'HighSchool' || selectedRecordType == 'ESL') {
			//this.objList = (List<Program__c>) Database.query(query);
			this.con = new ApexPages.StandardSetController(Database.getQueryLocator(query));
			this.con.setPageSize(1);
			this.sows = wrapperList((List<SObject>) con.getRecords());
			system.debug('@@@ con 1 ' + con.getrecords());
			//system.debug('@@@ con 2 ' + con.next());
			//this.sows = wrapperList((List<Program__c>) Database.query(query));
		} else {
			this.objList = (List<Major__c>) Database.query(query);
		}
		*/
		this.con = new ApexPages.StandardSetController(Database.getQueryLocator(query));
			this.con.setPageSize(pageSize);
			this.sows = wrapperList((List<SObject>) con.getRecords());
        bShowResultPanel = true;
        if(this.sows.size() == 0) {
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No results found!'));
        }
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,query));
    	return null;
    }
    
    public static List<SearchSObjectWrapper> wrapperList(List<Sobject> objs) {
    	List<SearchSObjectWrapper> sows = new List<SearchSObjectWrapper>();
    	for(SObject o: objs ){
    		SearchSObjectWrapper sow = new SearchSObjectWrapper(o);
    		sows.add(sow);
    	}
    	return sows;
    }
    
    public static String getQueryCurrencyISOCode(String country) {
    	String result='';
    	if(country=='US') {
    		result = 'USD';
    	} else if(Country=='UK') {
    		result = 'GBP';
    	} else if(Country=='CA') {
    		result = 'CAD';
    	} else if(Country=='AU') {
    		result = 'AUD';
    	}
    	return result;
    }
    
    //////////
    //Pagination
    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }

    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }

    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }
    
    // returns the total number of records
    public Integer totalPages {
        get {
            //return pageSize/con.getResultSize();
            Double dPageSize = pagesize;
			return (Integer) Math.Ceil(Database.countQuery(queryCount)/dPageSize);
        }
        set;
    }
    // returns the first page of records
     public void first() {
         con.first();
         this.sows = wrapperList((List<SObject>) con.getRecords());
     }

     // returns the last page of records
     public void last() {
         con.last();
         this.sows = wrapperList((List<SObject>) con.getRecords());
     }

     // returns the previous page of records
     public void previous() {
         con.previous();
         this.sows = wrapperList((List<SObject>) con.getRecords());
     }

     // returns the next page of records
     public void next() {
         con.next();
         this.sows = wrapperList((List<SObject>) con.getRecords());
     }
     
     //
     //Get Selected Results
     List<Id> selectedIds;
     //List<String> selectednames;
     public PageReference addToOpp() {
     	//system.debug('@@@ selectednames ' + selectednames);
     	//system.debug('@@@ size ' + selectednames.size());
     	system.debug('@@@ s ' + sows);
         for (SearchSObjectWrapper s : sows) {
             if (s.selected) {
                 //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, (String) s.obj.get('Name')));
                 selectedIds.add((Id) s.obj.get('Tech_Id__c'));
                 //selectednames.add((String) s.obj.get('Name'));
             }
         }
         //system.debug('@@@ addToOpp size ' + selectedIds.size());
         return null;
     }
     
     //////
     //Attach Selected Results to Recommended School
     public PageReference saveRS() {
     	//system.debug('@@@ savers size ' + selectedIds.size());
    	List<Recommended_Schools__c> recSchs = new List<Recommended_Schools__c>();
    	List<Program__c> progs = [Select Id, Campus__c, Campus__r.Account__c From Program__c Where Id In:selectedIds];
    	//for(Id objId: selectedIds) {
    	for(Program__c p: progs) {
    		Recommended_Schools__c r = new Recommended_Schools__c();
    		r.Overseas_School__c = p.Campus__r.Account__c;
    		r.Campus__c= p.Campus__c;
    		r.Program__c= p.Id;
    		r.Opportunity__c = rs.Opportunity__c;
    		recSchs.add(r);
    	}
    	system.debug('@@@ recSchs size  ' + recSchs);
    	insert recSchs;
    	return null;
    }
    
    //
    //Export to Excel VFPage
    public String filename {get{
    	//return Datetime.now().format('yyyy_MM_dd_HH_mm_ss') + '-SchoolLists';
    	return Datetime.now().format(Label.ExportFileDateFormat) + Label.ExportFileName;	
    }set;}
    public PageReference gotoPage2(){
		PageReference pageRef = new PageReference('/apex/RecommendedSchoolsExcelVFP');
		pageRef.setRedirect(false);
		return pageRef;  
	}
}
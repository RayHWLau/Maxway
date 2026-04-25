@isTest
public class AccountPrepaidCalculateTest {
    @isTest
    public static void testmethod1()
    {
     AccountTrigger_checkPrepaidBalence__c objTestSetting = TestUtil.createCustomSettingAccountPrepaidBaln( true );
       Account  listUniversityAcc = TestUtil.createAccount(ConstantsClass.osUniRecTypeName, true, 1)[0];
         List< Contract > listContract = TestUtil.createContract(ConstantsClass.oppAgentRecTypeName, false, 1 ); 
        listContract[0].AccountId = listUniversityAcc.Id;
       // listContract[0].Opportunity__c = objOpp.Id; 
           listContract[0].CurrencyIsoCode='USD';
        insert listContract;
        listContract[0].Status = objTestSetting.Contract_Status__c;
        listContract[0].StartDate = Date.today().addDays(-1);
        update listContract;
                list< Contract_Item__c > listContractItem = TestUtil.createContractItem( listContract[0].id, objTestSetting.Contract_Line_Item_Record_Name__c, 1, objTestSetting.Application_Tariff_Type__c, true );


			AccountPrepaidCalculate.calculatePrepaidBalence(listUniversityAcc.id,'Account');
    }
    @isTest
    public static void testmethod2()
    {
        set<ID> sid=new set<ID>();
     ApplicationTrigger_checkPrepaidBalence__c objTestSetting = TestUtil.createCustomSettingApplicationPrepaidBaln(true );
       Case cs=TestUtil.createApplication('Application(Opt-In)', true, 1)[0];
			AccountPrepaidCalculate.calculatePrepaidBalence(cs.id,'Case');
        AccountPrepaidCalculate.isUpdatedFromApprovalProcess(sid,'CommunityNINAccountApproval');
    }
   
}
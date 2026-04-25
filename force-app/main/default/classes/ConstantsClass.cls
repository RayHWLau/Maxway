public class ConstantsClass {
    
    //Account Record Types
    public Static String accAgentRecTypeName = 'Agent';
    public Static String homeCompRecTypeName = 'Homestay Company';
    public Static String osCCRecTypeName = 'Overseas School - CC';
    public Static String osESLRecTypeName = 'Overseas School - ESL';
    public Static String osHSRecTypeName = 'Overseas School - HS';
    public Static String localSclRecTypeName = 'Local School';
    public Static String osUniRecTypeName = 'Overseas School - University';
    public Static String schoolAgcyRecTypeName = 'School Agency'; 
    public Static String studntAccRecTypeName = 'Student Account';
    public Static String subAgcyRecTypeName = 'Sub-Agency';
    
    //Opportunity Record Type
    public Static String agentAcqRecTypeName = 'Agent Acquisition';
    public Static String studentRecTypeName = 'Student';
    public Static String  renAgntRecTypeName = 'Renewal -Agent Acquisition';
    
    //Contract Record Type
    public Static String schoolRecTypeName = 'School';
    public Static String oppAgentRecTypeName = 'Agent';
    public Static String marketingConRecTypeName = 'Marketing Contract';
    
    //Lead Record Type
    public Static String leadAgentAcqRecTypeName = 'Agent Acquisition';
    public Static String leadStudentRecTypeName = 'Student';
    
    //Invoice Record Type
    public static String invoiceAgentRecTypeName = 'Agent';
    public static String invoiceAppRecTypeName = 'Application';
    public static String invoiceSchoolRecTypeName = 'School';
    public static String invoiceStudentRecTypeName = 'Student';
    
    //Contact Record Type
    public static String contactAgentRecTypeName = 'Agent';
    public static String contactHomeStayRecTypeName = 'Homestay Contact';
    public static String contactSchoolRecTypeName = 'Local School Contact';
    public static String contactOtherRecTypeName = 'Other Contact (Homestay/Local School)';
    public static String contactOverSeaRecTypeName = 'Overseas School Contact';
    public static String contactPrimaryRecTypeName = 'Primary Contact';
    
    //Case Record Typ
    public static String caseOptOutRecTypeName = 'Application(Opt-Out/NIN/Maxway)';
    public static String caseOptInRecTypeName ='Application(Opt-In)'; 	
    
    //Program record Type
    public static String programCCRecTypeName = 'CC Program';
    public static String eslCRecTypeName = 'ESL Program';
    public static String programHSRecTypeName = 'High School Program';
    public static String programUniRecTypeName = 'Uni Program';
    
    //Campus Record Type
    public static String campusCCRecTypeName = 'CC - Campus';
    public static String campusESLRecTypeName = 'ESL - Campus';
    public static String campusHSRecTypeName = 'High School - Campus';
    public static String campusUniRecTypeName = 'Uni - Campus';
    
    // Major Record Type
    public static String majorMjrRecTypeName = 'Major';
    
    
    //sub-Agent status picklist
    public Static String statusSubAgentProspect = 'Prospect';
    public Static String statusSubAgentPending = 'Pending Renewal';
    public Static String statusSubAgentActive = 'Active';    
    public Static String statusSubAgentUnsubscribed = 'Unsubscribed';
    public Static String statusSubAgentCloseLost = 'Close Lost';
    
    
    //############################################################################ SALESFORCE LIMITS CHECK  ###########################################################################################
    //@KARAN SINGH SONI 1Feb2020 - to check how much a resource is utilized by a functionality
    
    public static void checkLimitsBefore( String methodName ){
        
        system.debug('Limits CPU Time Before calling ' + methodName + ' ----------------------------------------> ' + Limits.getCpuTime());
        system.debug('Limits DML Rows Before ' + methodName + ' ----------------------------------------> ' + Limits.getDmlRows());
        system.debug('Limits DML Statements Before ' + methodName + ' ----------------------------------------> ' + Limits.getDmlStatements());
        system.debug('Limits Heap Size Before ' + methodName + ' ----------------------------------------> ' + Limits.getHeapSize());
        system.debug('Limits Queries Before ' + methodName + ' ----------------------------------------> ' + Limits.getQueries());
    }
    
    public static void checkLimitsAfter( String methodName  ){
        
        system.debug('Limits CPU Time After ' + methodName + ' ----------------------------------------> ' + Limits.getCpuTime());
        system.debug('Limits DML Rows After ' + methodName + ' ----------------------------------------> ' + Limits.getDmlRows());
        system.debug('Limits DML Statements After ' + methodName + ' ----------------------------------------> ' + Limits.getDmlStatements());
        system.debug('Limits Heap Size After ' + methodName + ' ----------------------------------------> ' + Limits.getHeapSize());
        system.debug('Limits Queries After ' + methodName + ' ----------------------------------------> ' + Limits.getQueries());
        
    }
    
}
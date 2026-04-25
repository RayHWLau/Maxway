public class LeadSchoolShortlistController{
     public Id MasterId {get; set;}    
     public list<Result> results {get; set;}
     public Lead l = new Lead();
     public list<Account> ld = new list<Account>();
     public String m_msg = '';

     public List<string> m_preferredcountry = new List<string>();
     public List<string> m_preferredstate = new List<string>();
     public List<string> m_schooltype= new List<string>();
     public String m_annualbudget= '';
     public String upbudget = 'HKD999999999';
     public String downbudget = 'HKD0';
     public List<string> m_housing= new List<string>();
     public List<string> m_hsprogramtype = new List<string>();
     public List<string> m_ccprogramtype = new List<string>();     
     public List<string> m_major= new List<string>();
     public List<string> m_grade= new List<string>();
     public List<string> m_gender = new List<string>(); 
     
     public String debug {get;set;}
     
     public LeadSchoolShortlistController(ApexPages.StandardController controller)     
     {
         MasterId = ApexPages.currentPage().getParameters().get('id');    
     }
     
     
     string AppendToSOQL(string soql,String field, String option)
    {
      string value = option;
      if((value!=null)&&(value!=''))
      {
        soql += ' and ';
        soql += field + '=\'' + string.escapeSingleQuotes(value) + '\'';
      }
      return soql;
    }
    
    string AppendToSOQLR(string soql,String field, String up, String down)
    {
        soql += ' and ';
        soql += field + ' >= ' + string.escapeSingleQuotes(down);
        soql += ' and ';
        soql += field + ' <= ' + string.escapeSingleQuotes(up);
      return soql;
    }
    
    string AppendToSOQLM(string soql, String field, String[] options)
    {
      List<string> values = options;
      if((values!=null)&&(!values.isEmpty()))
      {
        soql += ' and ';
        soql += field + ' in (\'' + string.escapeSingleQuotes(values[0]) + '\'';
        for(Integer i=1; i<values.size(); i++)
          soql += ',\'' + string.escapeSingleQuotes(values[i]) + '\'';
        soql += ')';
      }
      return soql;
    }
    
    string AppendToSOQLMM(string soql, String field, String[] options)
    {
      List<string> values = options;
      if((values!=null)&&(!values.isEmpty()))
      {
        soql += ' and ';
        soql += field + ' includes (\'' + string.escapeSingleQuotes(values[0]) + '\'';
        for(Integer i=1; i<values.size(); i++)
          soql += ',\'' + string.escapeSingleQuotes(values[i]) + '\'';
        soql += ')';
      }
      return soql;
    }
    
     
     public void search(){  
         
         String soql = 'select Id, Name,RecordType.Name,Country__c,Province_State__c,School_Type__c,Partner_Type__c,School_Agency__r.Name,Est_Annual_Cost__c from Account where IsPersonAccount=false';
         system.debug('MasterId'+MasterId);
         results = new list<Result>(); 
         l = [select id,Name,Preferred_Country__c,Preferred_State__c,Preferred_School_Type__c,For_CC_or_University_Program_Type__c,Annual_Budget__c,
                 For_CC_or_University_Preferred_Major__c,Housing_Option__c, For_HS_Preferred_Program__c,Intended_Grade__c,
                 Gender__c
                 from Lead
                 where id=:MasterId];
         system.debug('l'+l);
         if(l.Preferred_Country__c!=null)
             m_preferredcountry = l.Preferred_Country__c.split(';',0);
         if(l.Preferred_State__c!=null)
             m_preferredstate = l.Preferred_State__c.split(';',0);
         if(l.Preferred_School_Type__c!=null)
         {
             m_schooltype= l.Preferred_School_Type__c.split(';',0);
             for(integer i=0;i<m_schooltype.size();i++)
                 m_schooltype[i] = 'Overseas School - '+m_schooltype[i];
         }   
         if(l.Annual_Budget__c!=null)
             m_annualbudget= l.Annual_Budget__c;
         if(m_annualbudget=='Under HK$ 100,000')
             upbudget='HKD100000';
         if(m_annualbudget=='HK$100,000 - HK$200,000')
         {
             upbudget='HKD200000'; downbudget='HKD100000';
         }
         if(m_annualbudget=='HK$200,000 - HK$300,000')
         {
             upbudget='HKD300000';downbudget='HKD200000';
         }
         if(l.Housing_Option__c!=null)
             m_housing= l.Housing_Option__c.split(';',0);
         if(l.For_CC_or_University_Preferred_Major__c!=null)
             m_major= l.For_CC_or_University_Preferred_Major__c.split(';',0);
         if(l.Intended_Grade__c!=null)
             m_grade= l.Intended_Grade__c.split(';',0);
         if(l.Gender__c!=null)
             m_gender= ((l.Gender__c=='M')?new String[]{'Boys','Co-ed'}:new String[]{'Girls','Co-ed'});
         if(l.For_HS_Preferred_Program__c!=null)
             m_hsprogramtype = l.For_HS_Preferred_Program__c.split(';',0);
         if(l.For_CC_or_University_Program_Type__c!=null)
             m_ccprogramtype = l.For_CC_or_University_Program_Type__c.split(';',0);
         
         if((m_schooltype!=null)&&(!m_schooltype.isEmpty()))
             for(integer i=0;i<m_schooltype.size();i++)
             {
                 soql = AppendToSOQL(soql,'RecordType.Name',m_schooltype[i]);
                 if((m_preferredcountry!=null)&&(!m_preferredcountry.isEmpty()))
                     soql = AppendToSOQLM(soql,'Country__c',m_preferredcountry);
                 if((m_preferredstate!=null)&&(!m_preferredstate.isEmpty()))
                     soql = AppendToSOQLM(soql,'Province_State__c',m_preferredstate);
                 if((m_housing!=null)&&(!m_housing.isEmpty()))
                     soql = AppendToSOQLMM(soql,'Housing_Option__c',m_housing);
                 if((m_annualbudget!=null)&&(m_annualbudget!='')&&(m_annualbudget!='Doesn’t Matter'))
                     soql = AppendToSOQLR(soql,'Est_Annual_Cost__c',upbudget,downbudget);
                 if(m_schooltype[i]=='Overseas School - HS')
                 {
                     if((m_gender!=null)&&(!m_gender.isEmpty()))
                         soql = AppendToSOQLM(soql,'Gender_HS__c',m_gender);
                     if((m_hsprogramtype!=null)&&(!m_hsprogramtype.isEmpty()))
                         soql = AppendToSOQLMM(soql,'HS_Program_Type__c',m_hsprogramtype);
                     if((m_grade!=null)&&(!m_grade.isEmpty()))
                         soql = AppendToSOQLMM(soql,'Admission_Grade__c',m_grade);
                 }
                 if(m_schooltype[i]=='Overseas School - CC')
                 {
                     if((m_major!=null)&&(!m_major.isEmpty()))
                         soql = AppendToSOQLMM(soql,'Major__c',m_major);
                     if((m_ccprogramtype!=null)&&(!m_ccprogramtype.isEmpty()))
                         soql = AppendToSOQLMM(soql,'CC_Program_Type__c',m_ccprogramtype);
                 }
                 if(m_schooltype[i]=='Overseas School - University')
                 {
                     if((m_major!=null)&&(!m_major.isEmpty()))
                         soql = AppendToSOQLMM(soql,'Major__c',m_major);
                     if((m_ccprogramtype!=null)&&(!m_ccprogramtype.isEmpty()))
                         soql = AppendToSOQLMM(soql,'Uni_Program_Type__c',m_ccprogramtype);
                 }
                 soql +=' order by Name';
                 //debug = soql;
                 try
                  {
                    ld = Database.Query(soql);
                  }
                  catch(System.Exception Ex)
                  {
                    soql += ' limit 1000';
                    try
                    {
                      ld = Database.Query(soql);
                      m_msg = 'Too many records found.  Only 1000 records are shown.';
                    }
                    catch(System.Exception Ex1)
                    {
                      m_msg = Ex.getTypeName() + ':' + Ex.getMessage();
                    }
                  }
             
                 for(Account d : ld)        
                 {            
                     results.add(new Result(false, d));        
                 }
                 soql = 'select Id, Name,RecordType.Name,Country__c,Province_State__c,School_Type__c,Partner_Type__c,School_Agency__r.Name,Est_Annual_Cost__c from Account where IsPersonAccount=false'; 
             }
     }
     
     public PageReference addtoshortlist()    
     {        
         list<Recommended_Schools__c> lrs = new list<Recommended_Schools__c>();
         for(Result r : results)        
         {            
             if(r.selected)            
             {                
                 Recommended_Schools__c rs = new Recommended_Schools__c();
                 rs.Lead__c = MasterId;
                 rs.Overseas_School__c = r.Record.id;     
                 lrs.add(rs);       
             }        
         }   
         if(lrs.size()>0)
             insert lrs;     
         return new PageReference('/'+masterId);    
     }
     
     public class Result    
     {        
         public boolean Selected {get; set;}        
         public Account Record {get; set;}   
         
         public Result(boolean selected, Account record)        
         {            
             this.selected = selected;            
             this.Record = record;   
         }    
     }
}
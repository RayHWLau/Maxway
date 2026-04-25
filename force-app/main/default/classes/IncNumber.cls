public class IncNumber
{
  private string m_name;
  
  public IncNumber(string name)
  {
    if(name=='') throw new MiscException('IncNumber name is empty');
    m_name = name;
  }

  public integer GetNext() { return GetNext(1); }
  public integer GetNext(integer count)
  {
    IncNumber__c[] ins = [select Id, Name, Reset__c, Current_Number__c, Last_Increment__c from IncNumber__c where Name=:m_name limit 1 for update];
    if(ins.size()<=0) throw new MiscException('IncNumber record not found for ' + m_name);
    
    IncNumber__c inc = ins[0];
    
    boolean reset = false;
    if(inc.Last_Increment__c!=null)
    {
        if(inc.Reset__c=='Daily')
          if(!System.today().isSameDay(inc.Last_Increment__c))
            reset = true;
        if(inc.Reset__c=='Monthly')
          if((System.today().month()!=inc.Last_Increment__c.month())||(System.today().year()!=inc.Last_Increment__c.year()))
            reset = true;
        if(inc.Reset__c=='Yearly')
          if(System.today().year()!=inc.Last_Increment__c.year())
            reset = true;
    }
      
    integer nstart, nend;  
    if(reset)
      nstart = 1;
    else
      nstart = inc.Current_Number__c.intValue() + 1;
    nend = nstart + count - 1;

    inc.Current_Number__c = nend;
    inc.Last_Increment__c = System.today();
    update(inc);
    
    return nstart;
  }




  static testMethod void IncNumber_Test()
  {
    IncNumber__c inc;
    IncNumber inn;
    
    try
    {
      inn = new IncNumber('');
      inn.GetNext();
    }
    catch(MiscException ex)
    {}
    
    try
    {
      inn = new IncNumber('Test0');
      inn.GetNext();
    }
    catch(MiscException ex)
    {}
    
    inc = new IncNumber__c();
    inc.Name = 'Test1';
    inc.Reset__c = 'Never';
    inc.Current_Number__c = 1;
    inc.Last_Increment__c = System.today();
    insert(inc);
    inn = new IncNumber('Test1');
    inn.GetNext();
    
    inc = new IncNumber__c();
    inc.Name = 'Test2';
    inc.Reset__c = 'Daily';
    inc.Current_Number__c = 1;
    inc.Last_Increment__c = System.today().addDays(-1);
    insert(inc);
    inn = new IncNumber('Test2');
    inn.GetNext();
    
    inc = new IncNumber__c();
    inc.Name = 'Test3';
    inc.Reset__c = ' Monthly';
    inc.Current_Number__c = 1;
    inc.Last_Increment__c = System.today().addMonths(-1);
    insert(inc);
    inn = new IncNumber('Test3');
    inn.GetNext();
    
    inc = new IncNumber__c();
    inc.Name = 'Test4';
    inc.Reset__c = ' Yearly';
    inc.Current_Number__c = 1;
    inc.Last_Increment__c = System.today().addYears(-1);
    insert(inc);
    inn = new IncNumber('Test4');
    inn.GetNext();
  }


}
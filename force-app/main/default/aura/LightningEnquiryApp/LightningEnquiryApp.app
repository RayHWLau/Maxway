<aura:application access="GLOBAL" extends="ltng:outApp" implements="ltng:allowGuestAccess"> 
    
    <aura:dependency resource="c:EnquiryFormSite"/>
    <aura:dependency resource="c:NationalityTable"/>
    <aura:dependency resource="c:AgentSignupForm"/>    
    <aura:dependency resource="c:AgentSignupUploadDocument"/> 
    <aura:dependency resource="c:ReferenceCheckComponent" />
    <aura:dependency resource="c:OpportunityCreationFromRelatedList" />
    <aura:dependency resource="c:OpporunityCreationFromRelatedListParent" />
    <aura:dependency resource="markup://force:navigateToURL" type="EVENT"/>
</aura:application>
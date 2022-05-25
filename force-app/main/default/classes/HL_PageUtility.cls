//*This class will hold all the methods related to operation on Page and Url
global with sharing class HL_PageUtility{
    global static void ShowMsg(ApexPages.Severity sev, String message)
    {
        ApexPages.addMessage(new ApexPages.Message(sev, message));
    }
    global static void ShowConfirm(Object conf)
    {
        ShowMsg(ApexPages.Severity.Confirm,String.Valueof(conf));
    }
    global static void ShowInfo(Object info)
    {
        ShowMsg(ApexPages.Severity.Info,String.Valueof(info));
    }
    
    global static void ShowWarning(Object warn)
    {
        ShowMsg(ApexPages.Severity.Warning,String.Valueof(warn));
    }
    
    global static void ShowError(Object err)
    {
        ShowMsg(ApexPages.Severity.Error,String.Valueof(err));
    }  
    
    global static String GetParameter(String param){
        return ApexPages.currentPage().getParameters().get(param);
    }
    
    global static Boolean isS1(){
       String retUrl = ApexPages.currentPage().getParameters().get('retURL');
       return String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameHost')) ||
       		  String.isNotBlank(ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin')) ||
       		  ApexPages.currentPage().getParameters().get('isdtp') == 'p1' ||
       		  (String.isNotBlank(retUrl) && retURL.contains('projectone'));
    }
 
}
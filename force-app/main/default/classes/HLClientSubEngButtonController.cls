public class HLClientSubEngButtonController {
    public String engagementId { get; set; }
    public String engName {get; set;}
    
    public HLClientSubEngButtonController(ApexPages.StandardController controller) {
        engagementId = Id.valueOf(ApexPages.currentPage().getParameters().get('engagementId'));
        engName = [SELECT Id,Name FROM Engagement__c WHERE Id =: engagementId].Name;
    }
    public PageReference redirect() {
        PageReference retURL;
        APIWrapper apiW = findCustomFieldsid('Engagement_Client_Subject__c');
        Map<string,string> fieldId = apiW.fieldApi;
        String objApi = apiW.objApi;
        String pref = '/setup/ui/recordtypeselect.jsp'/*+getObjectPrefixCode('Engagement_Client_Subject__c')+'/e'*/;
        retURL = new PageReference(pref);
        retURL.getParameters().put('ent', objApi);
        retURL.getParameters().put('save_new_url', '/'+getObjectPrefixCode('Engagement_Client_Subject__c')+'/e?retURL=/'+engagementId);
        retURL.getParameters().put('CF'+fieldId.get('Engagement__c'), engName);
        retURL.getParameters().put('CF'+fieldId.get('Engagement__c')+'_lkid', engagementId);
        retURL.getParameters().put('retURL', '/'+engagementId);
        retURL.getParameters().put('nooverride','1');
        retURL.setRedirect(false);
        return retURL;
    }
    
    public static string getObjectPrefixCode(string ObjName){
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get(ObjName);
        Schema.DescribeSObjectResult r = sobjType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        System.debug('Printing –'+keyPrefix );
        return keyPrefix;
    }
    public static APIWrapper findCustomFieldsid(string ObjName){
        Map<string,string> FieldToFieldidMap = new Map<string,string>();
        string customObjectId;
        string TableEnumOrIdValue;
        String baseURL = Url.getSalesforceBaseUrl().toExternalForm();
        APIWrapper apiW = new APIWrapper();
        if(ObjName.endswith('__c')){
            ObjName = ObjName.substring(0,Objname.length()-3);
            system.debug('*******Objname:'+Objname);
            String query = 'SELECT Id From CustomObject Where DeveloperName = \'' + ObjName+ '\'';
            string endpoint = baseURL + '/services/data/v38.0/tooling/query/?q=';
            endpoint += EncodingUtil.urlEncode(query, 'UTF-8');
            Map<string, string> httpHeaders=new Map<string, string>();
            httpHeaders.put('Authorization', 'Bearer ' + UserInfo.getSessionId());
            httpHeaders.put('Content-Type', 'application/json');
            HttpRequest request = createHTTPRequest(endpoint, 'GET', httpHeaders);
            HttpResponse response = sendHTTPRequest(request);
            
            system.debug('*****object**response:'+response);
            if(!Test.isRunningTest())
            customObjectId = response.getBody().substringAfter('"Id":"').substringBefore('"');
            system.debug('*****object**customObjectId :'+customObjectId );
            TableEnumOrIdValue = customObjectId ;
        }else{
            TableEnumOrIdValue = ObjName;
        }
        if(TableEnumOrIdValue !=null && TableEnumOrIdValue !=''){
            String query = 'SELECT Id, DeveloperName From CustomField Where TableEnumOrId = \'' + TableEnumOrIdValue+ '\'';
            string endpoint = baseURL + '/services/data/v38.0/tooling/query/?q=';
            endpoint += EncodingUtil.urlEncode(query, 'UTF-8');
            Map<string, string> httpHeaders=new Map<string, string>();
            httpHeaders.put('Authorization', 'Bearer ' + UserInfo.getSessionId());
            httpHeaders.put('Content-Type', 'application/json');
            HttpRequest request = createHTTPRequest(endpoint, 'GET', httpHeaders);
            HttpResponse res = sendHTTPRequest(request);
            if(!Test.isRunningTest()){
            String response=res.getBody();
            system.debug('*******response:'+response);
            SYSTEM.JSONParser parser = SYSTEM.JSON.createParser(response);
            while (parser.nextToken() != null) {
                string fieldName='';
                string fieldId='';
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                    //system.debug('*********parser.getText():'+parser.getText());
                    if(parser.getText()=='Id'){
                        parser.nextToken();
                        fieldId= parser.getText();
                        system.debug('*************fieldId:'+fieldId);
                        parser.nextToken();  
                    }if(parser.getText()=='DeveloperName'){
                        parser.nextToken();
                        fieldName=parser.getText();
                    }
                    if(fieldName!='' && fieldId !=''){
                        FieldToFieldidMap.put(fieldName+'__c',fieldId.substring(0,15));
                    }
                }
            }
            }
            system.debug('*********FieldToFieldidMap:'+FieldToFieldidMap);
        }
        apiW.fieldApi = FieldToFieldidMap;
        apiW.objApi = TableEnumOrIdValue;
        return apiW;
    }
    
    public class APIWrapper{
        Map<string,string> fieldApi = new Map<string,string>();
        string objApi;
    }
    public static HTTPRequest createHTTPRequest(string endPointURL, string HTTPMethod, Map<string,string> HTTPHeaders){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPointURL);
        req.setMethod(HTTPMethod);
        for(string ss : HTTPHeaders.keyset()){
            req.setHeader(ss, HTTPHeaders.get(ss));
        }
        return req;
    }
    public static HTTPResponse sendHTTPRequest(HTTPRequest req){
        HttpResponse res;
        if(!SYSTEM.Test.isRunningTest()){
            Http h = new Http();
            res = h.send(req);
        }
        return res;
    }  
}
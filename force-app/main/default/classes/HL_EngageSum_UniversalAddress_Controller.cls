/*
 * Name: HL_EngageSum_UniversalAddress_Controller
 * Created Date: 02/10/2020
 * Created By: Nara
 * Functionality : controller class for hlUniversalAddress lwc
 */
public class HL_EngageSum_UniversalAddress_Controller {
    
    @auraEnabled(cacheable = true)
    public static String getCountryStateMap(){
        Map<String,List<HL_EngageSum_PickListUtil.dependentPicklistWrapper>> countryStateMap = new Map<String,List<HL_EngageSum_PickListUtil.dependentPicklistWrapper>>();
        String jsonMap;
        
        Schema.DescribeFieldResult controllingFieldDescribe = Schema.Account.BillingCountryCode.getDescribe();
        Schema.sObjectField countryField = controllingFieldDescribe.getSObjectField();
        Schema.DescribeFieldResult dependentFieldDescribe = Schema.Account.BillingStateCode.getDescribe();
        Schema.sObjectField stateField = dependentFieldDescribe.getSObjectField();        
        countryStateMap = HL_EngageSum_PickListUtil.getDependentOptionsImpl(stateField, countryField);
        jsonMap=JSON.serialize(countryStateMap);
        return jsonMap;
    }
    
}
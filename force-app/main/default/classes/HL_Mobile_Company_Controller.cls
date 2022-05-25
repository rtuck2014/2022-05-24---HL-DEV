/*
 * Name: HL_PickListUtil 
 * Created Date: 09/20/2019
 * Created By: Kishan J
 * Functionality : controller class for hlMobileCompanyNewComponent and hlMobileContactNewComponent lwc
 */
public class HL_Mobile_Company_Controller {
    
    @auraEnabled(cacheable = true)
    public static String getCountryStateMap(){
        Map<String,List<HL_PickListUtil.dependentPicklistWrapper>> countryStateMap = new Map<String,List<HL_PickListUtil.dependentPicklistWrapper>>();
        String jsonMap;
        
        Schema.DescribeFieldResult controllingFieldDescribe = Schema.Account.BillingCountryCode.getDescribe();
        Schema.sObjectField countryField = controllingFieldDescribe.getSObjectField();
        Schema.DescribeFieldResult dependentFieldDescribe = Schema.Account.BillingStateCode.getDescribe();
        Schema.sObjectField stateField = dependentFieldDescribe.getSObjectField();        
        countryStateMap = HL_PicklistUtil.getDependentOptionsImpl(stateField, countryField);
        jsonMap=JSON.serialize(countryStateMap);
        return jsonMap;
    }
    
    @auraEnabled(cacheable = true)
     public static List<Postal_Code__c> getAddressByPostalCode(String postalCode){
        try{
        if(!String.isBlank(postalCode) && postalCode.length() > 5){
            postalCode = postalCode.substring(0,5);
        }
        List<Postal_Code__c> postalCodeList = [SELECT City__c, County__c, State__c FROM Postal_Code__c WHERE ZIPCODE__c =: postalCode];
            if(postalCodeList.size() > 0){
                return postalCodeList;
            }
            else{
                return null;
            }
        }catch(exception ex){
            system.debug('error>>>'+ex.getMessage());
            return null;
        }
     }
}
@istest
public class Test_TAS_DNDController {

    testmethod static void main(){
        Opportunity__c opp = SL_TestSetupUtils.CreateOpp('',1)[0];
        opp.Beneficial_Owner_Control_Person_form__c = 'No';
        insert opp;
        TAS_DNDController.DnDOnOff(opp.Id);
    }
    
    testmethod static void main1(){
        Opportunity__c opp = SL_TestSetupUtils.CreateOpp('',1)[0];
        opp.Beneficial_Owner_Control_Person_form__c = 'No';
        opp.DND_Status__c = 'Approved';
        insert opp;
        TAS_DNDController.DnDOnOff(opp.Id);
    }
}
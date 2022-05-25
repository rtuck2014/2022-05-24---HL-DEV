/*
* Name: HL_OpportunityExternalTeamHandler
* Created Date: 4/6/2015
* Description: Handler class for OpportunityExternalTeam records
* Modified Date: 12/10/2019
* Description:  Added the following methods for ERP Integration. The new methods are invoked from OnBeforeInsert and OnBeforeUpdate methods.
*   a) checkForBillToBillingCountry()
*/

public class HL_OpportunityExternalTeamHandler {
    private List<Opportunity_External_Team__c> OpportunityExternalTeam {get; set;}

    public HL_OpportunityExternalTeamHandler(List<Opportunity_External_Team__c> opportunityExternalTeam){
        this.OpportunityExternalTeam = opportunityExternalTeam;
    }

    //Populate The OET_UNIQUE__c Field
    public List<Opportunity_External_Team__c> UpdateOETUnique(){
        for(Opportunity_External_Team__c oet : OpportunityExternalTeam)
                oet.OET_UNIQUE__c = oet.Opportunity__c + '|' + oet.Contact__c;

        return OpportunityExternalTeam;
    }
    
    //Updates the Primary Opportunity Contact Lookup field on the Opportunities
    //Also updates the Primary Checkbox on other OIT fields to make sure only one is marked as primary per Opportunity
    public List<Opportunity_External_Team__c> UpdatePrimaryOpportunityContact(){
        Map<Id,Id> oppsToPrimaryOIT = new Map<Id,Id>(); //Map of Opportunities to Primary
        List<Opportunity__c> oppsToUpdate = new List<Opportunity__c>();
        List<Opportunity_External_Team__c> oetsToUpdate = new List<Opportunity_External_Team__c>();
        Set<Id> oets = new Set<Id>();
        Id primaryContact;
        for(Opportunity_External_Team__c oet: OpportunityExternalTeam){
            if(oet.Primary__c){
                oets.add(oet.Id);
                oppsToPrimaryOIT.put(oet.Opportunity__c, oet.Contact__c);
            }
        }
        //Update the Primary External Contact Lookup Field on the Opportunity
        if(oppsToPrimaryOIT.size() > 0){
            for(Opportunity__c o : [SELECT Primary_External_Contact__c FROM Opportunity__c WHERE Id IN:oppsToPrimaryOIT.keySet()]){
                primaryContact = oppsToPrimaryOIT.get(o.Id);
                if(o.Primary_External_Contact__c <> primaryContact){
                    o.Primary_External_Contact__c = primaryContact;
                    oppsToUpdate.add(o);
                }
            }
        }
        //Update the Opportunities that might have Changed
        if(oppsToUpdate.size() > 0){
            update oppsToUpdate;
            for(Opportunity_External_Team__c oet : [SELECT Primary__c FROM Opportunity_External_Team__c WHERE Id NOT IN:oets AND Opportunity__c IN:oppsToPrimaryOIT.keySet() AND Primary__c = true]){
                oet.Primary__c = false;
                oetsToUpdate.add(oet);
            }
            if(oetsToUpdate.size() > 0)
                update oetsToUpdate;
        }

        return OpportunityExternalTeam;
    }
    
    //Handle the Before Delete to Remove the Primary Reference if the Contact is Deleted
    public List<Opportunity_External_Team__c> RemovePrimaryOET(){
        Set<Id> oppIds = new Set<Id>(); //Store the Opportunities to Update
        List<Opportunity__c> oppsToUpdate = new List<Opportunity__c>();
        for(Opportunity_External_Team__c oet: OpportunityExternalTeam){
            if(oet.Primary__c)
                oppIds.add(oet.Opportunity__c);
        }
        for(Opportunity__c o : [SELECT Primary_External_Contact__c FROM Opportunity__c WHERE Id IN:oppIds]){
            o.Primary_External_Contact__c = null;
            oppsToUpdate.add(o);
        }
        if(oppsToUpdate.size() > 0)
            update oppsToUpdate; 

        return OpportunityExternalTeam;
    }
    
    public List<Opportunity_External_Team__c> UpdateSortFields(){
        Set<Id> oppIds = new Set<Id>();
        Set<String> roles = new Set<String>();
        Set<Id> contacts = new Set<Id>();
        Id oppId, acctId;
        String companySort, role, roleSort;
        
        for(Opportunity_External_Team__c oet : OpportunityExternalTeam){
            oppIds.add(oet.Opportunity__c);
            roles.add(oet.Role__c);
            contacts.add(oet.Contact__c);
        }
        
        //Get a contact map for the account Ids
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT AccountId FROM Contact WHERE Id IN:contacts]);
        
        for(AggregateResult ar : [SELECT Opportunity__c, Role__c, Contact__r.AccountId accountId, MAX(Sort_Role_Order__c) sortRole, MAX(Sort_Company_Order__c) sortCompany FROM Opportunity_External_Team__c WHERE Opportunity__c IN: oppIds AND Role__c IN: roles GROUP BY Opportunity__c, Role__c, Contact__r.AccountId]){
            oppId = (Id)ar.get('Opportunity__c');
            acctId = (Id)ar.get('accountId');
            role = (String)ar.get('Role__c');
            roleSort = (String)ar.get('sortRole');
            companySort = (String)ar.get('sortCompany');
            for(Opportunity_External_Team__c oet : OpportunityExternalTeam){
                if(oet.Opportunity__c == oppId && oet.Role__c == role){
                    oet.Sort_Role_Order__c = roleSort;
                    if(contactMap.get(oet.Contact__c).AccountId == acctId)
                        oet.Sort_Company_Order__c = companySort;
                }
            }
        }
        
        return OpportunityExternalTeam;
    }
    
    //Check if Bill To Company has a 'Billing Country'
    public List<Opportunity_External_Team__c> checkForBillToBillingCountry(){
        Set<Id> oppExtContactIds = new Set<Id>();
        Map<Id, Opportunity_External_Team__c> opptyExtTeamMap = new Map<Id, Opportunity_External_Team__c>();
        
        for(Opportunity_External_Team__c oet : OpportunityExternalTeam){
            system.debug('*** oet: ' + oet);
            if(oet.Billing_Contact__c == true 
               && (oet.Bill_To_Billing_Country__c == null || oet.Bill_To_Billing_Country__c == '')){
                   String errorMsg = 'Bill To company \'' +  oet.Bill_To_Company__c + '\' should have a Billing Country.';
                   oet.addError(errorMsg);
            }
        }       
        return OpportunityExternalTeam;
    }
}
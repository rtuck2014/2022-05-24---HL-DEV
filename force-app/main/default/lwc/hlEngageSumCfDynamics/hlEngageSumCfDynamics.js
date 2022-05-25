import { LightningElement, api } from 'lwc';
import ENGAGESUM_RETAINER_FEE_FIELD from '@salesforce/schema/Engagement_Summary__c.Retainer_Fees__c';
import ENGAGESUM_RETAINER_FEE_CREDIT_FIELD from '@salesforce/schema/Engagement_Summary__c.Is_Retainer_Fee_Creditable__c';
import ENGAGESUM_CIM_FIELD from '@salesforce/schema/Engagement_Summary__c.Completion_Of_CIM__c';
import ENGAGESUM_CIM_CREDIT_FIELD from '@salesforce/schema/Engagement_Summary__c.Is_Completion_of_CIM_Creditable__c';
import ENGAGESUM_FIRSTROUND_FIELD from '@salesforce/schema/Engagement_Summary__c.First_Round_Bid__c';
import ENGAGESUM_FIRSTROUND_CREDIT_FIELD from '@salesforce/schema/Engagement_Summary__c.Is_First_Round_Bid_Creditable__c';
import ENGAGESUM_SECROUND_FIELD from '@salesforce/schema/Engagement_Summary__c.Second_Round_Bid__c';
import ENGAGESUM_SECROUND_CREDIT_FIELD from '@salesforce/schema/Engagement_Summary__c.Is_Second_Round_Bid_Creditable__c';
import ENGAGESUM_LOI_FIELD from '@salesforce/schema/Engagement_Summary__c.LOI__c';
import ENGAGESUM_LOI_CREDIT_FIELD from '@salesforce/schema/Engagement_Summary__c.Is_LOI_Creditable__c';
import ENGAGESUM_AGREEMENT_FIELD from '@salesforce/schema/Engagement_Summary__c.Signed_Agreement__c';
import ENGAGESUM_AGREEMENT_CREDIT_FIELD from '@salesforce/schema/Engagement_Summary__c.Is_Signed_Agreement_Creditable__c';
import ENGAGESUM_OTHERFEE1TYPE_FIELD from '@salesforce/schema/Engagement_Summary__c.Other_Fee_Type_01__c';
import ENGAGESUM_OTHERFEE1_FIELD from '@salesforce/schema/Engagement_Summary__c.Other_Fee_01__c';
import ENGAGESUM_OTHERFEE1_CREDIT_FIELD from '@salesforce/schema/Engagement_Summary__c.Is_Other_Fee_01_Creditable__c';
import ENGAGESUM_OTHERFEE2TYPE_FIELD from '@salesforce/schema/Engagement_Summary__c.Other_Fee_Type_02__c';
import ENGAGESUM_OTHERFEE2_FIELD from '@salesforce/schema/Engagement_Summary__c.Other_Fee_02__c';
import ENGAGESUM_OTHERFEE2_CREDIT_FIELD from '@salesforce/schema/Engagement_Summary__c.Is_Other_Fee_02_Creditable__c';
import ENGAGESUM_TRXFEE_TYPE_FIELD from '@salesforce/schema/Engagement_Summary__c.Transaction_Fee_Type__c';
import ENGAGESUM_TRXFEE_AMOUNT_FIELD from '@salesforce/schema/Engagement_Summary__c.Transaction_Fee__c';
import ENGAGESUM_TRXVAL_FEECALC_FIELD from '@salesforce/schema/Engagement_Summary__c.Transaction_Value_for_Fee_Calc__c';
import ENGAGESUM_FIRST_RACHET_FIELD from '@salesforce/schema/Engagement_Summary__c.First_Ratchet_Percent__c';
import ENGAGESUM_FIRST_FROM_RACHET_FIELD from '@salesforce/schema/Engagement_Summary__c.First_Ratchet_From_Amount__c';
import ENGAGESUM_FIRST_TO_RACHET_FIELD from '@salesforce/schema/Engagement_Summary__c.First_Ratchet_To_Amount__c';
import ENGAGESUM_SECOND_RACHET_FIELD from '@salesforce/schema/Engagement_Summary__c.Second_Ratchet_Percent__c';
import ENGAGESUM_SECOND_FROM_RACHET_FIELD from '@salesforce/schema/Engagement_Summary__c.Second_Ratchet_From_Amount__c';
import ENGAGESUM_SECOND_TO_RACHET_FIELD from '@salesforce/schema/Engagement_Summary__c.Second_Ratchet_To_Amount__c';
import ENGAGESUM_THIRD_RACHET_FIELD from '@salesforce/schema/Engagement_Summary__c.Third_Ratchet_Percent__c';
import ENGAGESUM_THIRD_FROM_RACHET_FIELD from '@salesforce/schema/Engagement_Summary__c.Third_Ratchet_From_Amount__c';
import ENGAGESUM_THIRD_TO_RACHET_FIELD from '@salesforce/schema/Engagement_Summary__c.Third_Ratchet_To_Amount__c';
import ENGAGESUM_FOURTH_RACHET_FIELD from '@salesforce/schema/Engagement_Summary__c.Fourth_Ratchet_Percent__c';
import ENGAGESUM_FOURTH_FROM_RACHET_FIELD from '@salesforce/schema/Engagement_Summary__c.Fourth_Ratchet_From_Amount__c';
import ENGAGESUM_FOURTH_TO_RACHET_FIELD from '@salesforce/schema/Engagement_Summary__c.Fourth_Ratchet_To_Amount__c';
import ENGAGESUM_FINAL_RACHET_FIELD from '@salesforce/schema/Engagement_Summary__c.Final_Ratchet_Percent__c';
import ENGAGESUM_FINAL_RACHET_AMOUNT_FIELD from '@salesforce/schema/Engagement_Summary__c.Final_Ratchet_Amount__c';
import ENGAGESUM_TOTAL_FEE_FIELD from '@salesforce/schema/Engagement_Summary__c.Total_Fee__c';
import ENGAGESUM_TOTAL_CREDITS_FIELD from '@salesforce/schema/Engagement_Summary__c.Total_Credits__c';
import ENGAGESUM_PAYMENT_CLOSE_FIELD from '@salesforce/schema/Engagement_Summary__c.Payment_On_Closing__c';
import ENGAGESUM_CONTINGENT_FEES_FIELD from '@salesforce/schema/Engagement_Summary__c.Fee_Subject_To_Contingent_Fees__c';


export default class HlEngageSumCfDynamics extends LightningElement {
    @api engagementId;
    @api engageSumId;
    @api recTypeBuyside;
    @api recTypeSellside;
    @api recTypeOtherside;

    dynamicsFeeEngageSumFieldsEdit = 
    [   ENGAGESUM_RETAINER_FEE_FIELD,ENGAGESUM_RETAINER_FEE_CREDIT_FIELD,
        ENGAGESUM_CIM_FIELD,ENGAGESUM_CIM_CREDIT_FIELD,
        ENGAGESUM_FIRSTROUND_FIELD,ENGAGESUM_FIRSTROUND_CREDIT_FIELD,
        ENGAGESUM_SECROUND_FIELD,ENGAGESUM_SECROUND_CREDIT_FIELD,
        ENGAGESUM_LOI_FIELD,ENGAGESUM_LOI_CREDIT_FIELD,
        ENGAGESUM_AGREEMENT_FIELD,ENGAGESUM_AGREEMENT_CREDIT_FIELD,
    ];
    dynamicsFeeEngageSumFieldsEdit2 = [
        ENGAGESUM_OTHERFEE1TYPE_FIELD,ENGAGESUM_OTHERFEE1_FIELD,ENGAGESUM_OTHERFEE1_CREDIT_FIELD,
        ENGAGESUM_OTHERFEE2TYPE_FIELD,ENGAGESUM_OTHERFEE2_FIELD,ENGAGESUM_OTHERFEE2_CREDIT_FIELD
    ]
    dynamicsTransactionEngageSumFieldsEdit = [
        ENGAGESUM_TRXFEE_TYPE_FIELD,ENGAGESUM_TRXFEE_AMOUNT_FIELD,
        
    ]
    dynamicsFeeCalcEngageSumFieldsEdit = [
        ENGAGESUM_TRXVAL_FEECALC_FIELD
    ];
    dynamicsIncentEngageSumFieldsEdit = [
        ENGAGESUM_FIRST_RACHET_FIELD,ENGAGESUM_FIRST_FROM_RACHET_FIELD,ENGAGESUM_FIRST_TO_RACHET_FIELD,
        ENGAGESUM_SECOND_RACHET_FIELD,ENGAGESUM_SECOND_FROM_RACHET_FIELD,ENGAGESUM_SECOND_TO_RACHET_FIELD,
        ENGAGESUM_THIRD_RACHET_FIELD,ENGAGESUM_THIRD_FROM_RACHET_FIELD,ENGAGESUM_THIRD_TO_RACHET_FIELD,
        ENGAGESUM_FOURTH_RACHET_FIELD,ENGAGESUM_FOURTH_FROM_RACHET_FIELD,ENGAGESUM_FOURTH_TO_RACHET_FIELD,
        ENGAGESUM_FINAL_RACHET_FIELD,ENGAGESUM_FINAL_RACHET_AMOUNT_FIELD
    ];
    dynamicsTotalFieldsRead = 
    [   ENGAGESUM_TOTAL_FEE_FIELD,
        ENGAGESUM_TOTAL_CREDITS_FIELD,
        ENGAGESUM_PAYMENT_CLOSE_FIELD,
        ENGAGESUM_CONTINGENT_FEES_FIELD
    ];
}
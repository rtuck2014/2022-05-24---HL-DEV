import { LightningElement, api } from 'lwc';
import ENGAGESUM_REVOLVCRED_FIELD from '@salesforce/schema/Engagement_Summary__c.Source_Revolving_Credit_Facility__c';
import ENGAGESUM_REVOLVCRED_PCT_FIELD from '@salesforce/schema/Engagement_Summary__c.Source_Revolving_Credit_Facility_Percent__c';
import ENGAGESUM_TERMA_FIELD from '@salesforce/schema/Engagement_Summary__c.Source_Term_Loan_A__c';
import ENGAGESUM_TERMA_PCT_FIELD from '@salesforce/schema/Engagement_Summary__c.Source_Term_Loan_A_Percent__c';
import ENGAGESUM_TERMB_FIELD from '@salesforce/schema/Engagement_Summary__c.Source_Term_Loan_B__c';
import ENGAGESUM_TERMB_PCT_FIELD from '@salesforce/schema/Engagement_Summary__c.Source_Term_Loan_B_Percent__c';
import ENGAGESUM_TERMC_FIELD from '@salesforce/schema/Engagement_Summary__c.Source_Term_Loan_C__c';
import ENGAGESUM_TERMC_PCT_FIELD from '@salesforce/schema/Engagement_Summary__c.Source_Term_Loan_C_Percent__c';
import ENGAGESUM_DELAYDRAW_FIELD from '@salesforce/schema/Engagement_Summary__c.Source_Delayed_Draw_Term_Loan__c';
import ENGAGESUM_DELAYDRAW_PCT_FIELD from '@salesforce/schema/Engagement_Summary__c.Source_Delayed_Draw_Term_Loan_Percent__c';
import ENGAGESUM_SENIORSUB_FIELD from '@salesforce/schema/Engagement_Summary__c.Source_Senior_Subordinated_Debt__c';
import ENGAGESUM_SENIORSUB_PCT_FIELD from '@salesforce/schema/Engagement_Summary__c.Source_Senior_Subordinated_Debt_Percent__c';
import ENGAGESUM_JUNIORSUB_FIELD from '@salesforce/schema/Engagement_Summary__c.Source_Junior_Subordinated_Debt__c';
import ENGAGESUM_JUNIORSUB_PCT_FIELD from '@salesforce/schema/Engagement_Summary__c.Source_Junior_Subordinated_Debt_Percent__c';
import ENGAGESUM_UNITRANCH_FIELD from '@salesforce/schema/Engagement_Summary__c.Source_Unitranche_Debt__c';
import ENGAGESUM_UNITRANCH_PCT_FIELD from '@salesforce/schema/Engagement_Summary__c.Source_Unitranche_Debt_Percent__c';
import ENGAGESUM_PREFEQUITY_FIELD from '@salesforce/schema/Engagement_Summary__c.Source_Preferred_Equity__c';
import ENGAGESUM_PREFEQUITY_PCT_FIELD from '@salesforce/schema/Engagement_Summary__c.Source_Preferred_Equity_Percent__c';
import ENGAGESUM_COMMEQUITY_FIELD from '@salesforce/schema/Engagement_Summary__c.Source_Common_Equity__c';
import ENGAGESUM_COMMEQUITY_PCT_FIELD from '@salesforce/schema/Engagement_Summary__c.Source_Common_Equity_Percent__c';
import ENGAGESUM_SELLNOTES_FIELD from '@salesforce/schema/Engagement_Summary__c.Source_Seller_Notes__c';
import ENGAGESUM_SELLNOTES_PCT_FIELD from '@salesforce/schema/Engagement_Summary__c.Source_Seller_Notes_Percent__c';
import ENGAGESUM_COMPANYCASHAR_FIELD from '@salesforce/schema/Engagement_Summary__c.Source_Company_Cash_AR__c';
import ENGAGESUM_COMPANYCASHAR_PCT_FIELD from '@salesforce/schema/Engagement_Summary__c.Source_Company_Cash_AR_Percent__c';
import ENGAGESUM_SOURCETOTAL_FIELD from '@salesforce/schema/Engagement_Summary__c.Source_Of_Funds_Total__c';

import ENGAGESUM_PURCHPRICE_FIELD from '@salesforce/schema/Engagement_Summary__c.Use_Purchase_Price__c';
import ENGAGESUM_PURCHPRICE_PCT_FIELD from '@salesforce/schema/Engagement_Summary__c.Use_Purchase_Price_Percent__c';
import ENGAGESUM_FEESEXPENSE_FIELD from '@salesforce/schema/Engagement_Summary__c.Use_Fees_And_Expenses__c';
import ENGAGESUM_FEESEXPENSE_PCT_FIELD from '@salesforce/schema/Engagement_Summary__c.Use_Fees_Expenses_Percent__c';
import ENGAGESUM_CLOSINGCASH_FIELD from '@salesforce/schema/Engagement_Summary__c.Use_Closing_Cash_Balance__c';
import ENGAGESUM_CLOSINGCASH_PCT_FIELD from '@salesforce/schema/Engagement_Summary__c.Use_Closing_Cash_Balance_Percent__c';
import ENGAGESUM_PROCSHAREHOLDER_FIELD from '@salesforce/schema/Engagement_Summary__c.Use_Proceeds_To_Shareholders__c';
import ENGAGESUM_PROCSHAREHOLDER_PCT_FIELD from '@salesforce/schema/Engagement_Summary__c.Use_Proceeds_To_Shareholders_Percent__c';
import ENGAGESUM_PAIDCLOSE_FIELD from '@salesforce/schema/Engagement_Summary__c.Use_Debt_Paid_At_Closing__c';
import ENGAGESUM_PAIDCLOSE_PCT_FIELD from '@salesforce/schema/Engagement_Summary__c.Use_Debt_Paid_at_Closing_Percent__c';
import ENGAGESUM_ASSUMPTIONDEBT_FIELD from '@salesforce/schema/Engagement_Summary__c.Use_Assumption_Of_Debt__c';
import ENGAGESUM_ASSUMPTIONDEBT_PCT_FIELD from '@salesforce/schema/Engagement_Summary__c.Use_Assumption_of_Debt_Percent__c';
import ENGAGESUM_DEALBONUS_FIELD from '@salesforce/schema/Engagement_Summary__c.Use_Deal_Bonuses__c';
import ENGAGESUM_DEALBONUS_PCT_FIELD from '@salesforce/schema/Engagement_Summary__c.Use_Deal_Bonuses_Percent__c';
import ENGAGESUM_USEOTHER_FIELD from '@salesforce/schema/Engagement_Summary__c.Use_Other__c';
import ENGAGESUM_USEOTHER_PCT_FIELD from '@salesforce/schema/Engagement_Summary__c.Use_Other_Percent__c';
import ENGAGESUM_USETOTAL_FIELD from '@salesforce/schema/Engagement_Summary__c.Use_Of_Funds_Total__c';

export default class HlEngageSumCfCapDetails extends LightningElement {
    @api engagementId;
    @api engageSumId;
    @api recTypeBuyside;
    @api recTypeSellside;
    @api recTypeOtherside;
    capDetailsEngageSumUseFieldsEdit = [
        ENGAGESUM_PURCHPRICE_FIELD,ENGAGESUM_PURCHPRICE_PCT_FIELD,
        ENGAGESUM_FEESEXPENSE_FIELD,ENGAGESUM_FEESEXPENSE_PCT_FIELD,
        ENGAGESUM_CLOSINGCASH_FIELD,ENGAGESUM_CLOSINGCASH_PCT_FIELD,
        ENGAGESUM_PROCSHAREHOLDER_FIELD,ENGAGESUM_PROCSHAREHOLDER_PCT_FIELD,
        ENGAGESUM_PAIDCLOSE_FIELD,ENGAGESUM_PAIDCLOSE_PCT_FIELD,
        ENGAGESUM_ASSUMPTIONDEBT_FIELD,ENGAGESUM_ASSUMPTIONDEBT_PCT_FIELD,
        ENGAGESUM_DEALBONUS_FIELD,ENGAGESUM_DEALBONUS_PCT_FIELD,
        ENGAGESUM_USEOTHER_FIELD,ENGAGESUM_USEOTHER_PCT_FIELD,
        ENGAGESUM_USETOTAL_FIELD
    ]
    capDetailsEngageSumSourceFieldsEdit = [ 
        ENGAGESUM_REVOLVCRED_FIELD,ENGAGESUM_REVOLVCRED_PCT_FIELD,
        ENGAGESUM_TERMA_FIELD,ENGAGESUM_TERMA_PCT_FIELD,
        ENGAGESUM_TERMB_FIELD,ENGAGESUM_TERMB_PCT_FIELD,
        ENGAGESUM_TERMC_FIELD,ENGAGESUM_TERMC_PCT_FIELD,
        ENGAGESUM_DELAYDRAW_FIELD,ENGAGESUM_DELAYDRAW_PCT_FIELD,
        ENGAGESUM_SENIORSUB_FIELD,ENGAGESUM_SENIORSUB_PCT_FIELD,
        ENGAGESUM_JUNIORSUB_FIELD,ENGAGESUM_JUNIORSUB_PCT_FIELD,
        ENGAGESUM_UNITRANCH_FIELD,ENGAGESUM_UNITRANCH_PCT_FIELD,
        ENGAGESUM_PREFEQUITY_FIELD,ENGAGESUM_PREFEQUITY_PCT_FIELD,
        ENGAGESUM_COMMEQUITY_FIELD,ENGAGESUM_COMMEQUITY_PCT_FIELD,
        ENGAGESUM_SELLNOTES_FIELD,ENGAGESUM_SELLNOTES_PCT_FIELD,
        ENGAGESUM_COMPANYCASHAR_FIELD,ENGAGESUM_COMPANYCASHAR_PCT_FIELD,
        ENGAGESUM_SOURCETOTAL_FIELD
    ]

}
import { LightningElement, api } from 'lwc';
import ENGAGESUM_PURCHASETYPE_FIELD from '@salesforce/schema/Engagement_Summary__c.Purchase_Type__c';
import ENGAGESUM_338ELECTION_FIELD from '@salesforce/schema/Engagement_Summary__c.Took_338_Selection__c';
import ENGAGESUM_PURCHASEBASE_FIELD from '@salesforce/schema/Engagement_Summary__c.Purchase_Price_Base__c';
import ENGAGESUM_WORKCAPITAL_FIELD from '@salesforce/schema/Engagement_Summary__c.Working_Capital_Adjustment__c';
import ENGAGESUM_POSTCLOSING_FIELD from '@salesforce/schema/Engagement_Summary__c.Post_Closing_Adjustment__c';
import ENGAGESUM_POSTCLOSING_NOTE_FIELD from '@salesforce/schema/Engagement_Summary__c.Post_Closing_Adjustment_Note__c';
import ENGAGESUM_TOTALPURCHASE_FIELD from '@salesforce/schema/Engagement_Summary__c.Total_Purchase_Price__c';
import ENGAGESUM_CONCASH_FIELD from '@salesforce/schema/Engagement_Summary__c.Consideration_Cash__c';
import ENGAGESUM_CONCASH_PCT_FIELD from '@salesforce/schema/Engagement_Summary__c.Consideration_Cash_Percent__c';
import ENGAGESUM_CONSTOCK_FIELD from '@salesforce/schema/Engagement_Summary__c.Consideration_Stock__c';
import ENGAGESUM_CONSTOCK_PCT_FIELD from '@salesforce/schema/Engagement_Summary__c.Consideration_Stock_Percent__c';
import ENGAGESUM_CONSTOCK_NOTE_FIELD from '@salesforce/schema/Engagement_Summary__c.Consideration_Stock_Note__c';
import ENGAGESUM_EARNOUTPAY_FIELD from '@salesforce/schema/Engagement_Summary__c.Consideration_Earnout_Payments__c';
import ENGAGESUM_EARNOUTPAY_PCT_FIELD from '@salesforce/schema/Engagement_Summary__c.Consideration_Earnout_Payments_Percent__c';
import ENGAGESUM_OTHERPAY_FIELD from '@salesforce/schema/Engagement_Summary__c.Consideration_Other_Payments__c';
import ENGAGESUM_OTHERPAY_PCT_FIELD from '@salesforce/schema/Engagement_Summary__c.Consideration_Other_Percent__c';
import ENGAGESUM_OTHERPAY_NOTE_FIELD from '@salesforce/schema/Engagement_Summary__c.Consideration_Other_Payments_Note__c';
import ENGAGESUM_TOTALCON_FIELD from '@salesforce/schema/Engagement_Summary__c.Total_Consideration__c';
import ENGAGESUM_METRICSUSED_FIELD from '@salesforce/schema/Engagement_Summary__c.Metrics_Used__c';
import ENGAGESUM_FIRSTMETRIC_FIELD from '@salesforce/schema/Engagement_Summary__c.First_Metric__c';
import ENGAGESUM_SECONDMETRIC_FIELD from '@salesforce/schema/Engagement_Summary__c.Second_Metric__c';
import ENGAGESUM_PREPARTY_FIELD from '@salesforce/schema/Engagement_Summary__c.Preparing_Party__c';
import ENGAGESUM_SEPESCROW_FIELD from '@salesforce/schema/Engagement_Summary__c.Had_Separate_Escrow__c';
import ENGAGESUM_EARNINCLD_FIELD from '@salesforce/schema/Engagement_Summary__c.Was_Earnout_Included__c';
import ENGAGESUM_EARNMETRIC_FIELD from '@salesforce/schema/Engagement_Summary__c.Earnout_Metric__c';
import ENGAGESUM_EARNPERIOD_FIELD from '@salesforce/schema/Engagement_Summary__c.Earnout_Period__c';
import ENGAGESUM_EARNACCEL_FIELD from '@salesforce/schema/Engagement_Summary__c.Does_Earnout_Accelerate__c';
import ENGAGESUM_EARNOFFSET_FIELD from '@salesforce/schema/Engagement_Summary__c.Is_Buyer_Able_To_Offset_Earnout__c';
import ENGAGESUM_SELLNOTE_FIELD from '@salesforce/schema/Engagement_Summary__c.Consideration_Seller_Notes__c';
import ENGAGESUM_SELLNOTE_PCT_FIELD from '@salesforce/schema/Engagement_Summary__c.Consideration_Seller_Notes_Percent__c';
import ENGAGESUM_SELLNOTETERM_FIELD from '@salesforce/schema/Engagement_Summary__c.Seller_Notes_Term__c';
import ENGAGESUM_SELLNOTEINTEREST_FIELD from '@salesforce/schema/Engagement_Summary__c.Seller_Notes_Interest_Percent__c';
import ENGAGESUM_SELLNOTECONVERT_FIELD from '@salesforce/schema/Engagement_Summary__c.Has_Seller_Note_Conversion_Rights__c';


export default class HlEngageSumCfPrice extends LightningElement {
    @api engagementId;
    @api engageSumId;
    @api recTypeBuyside;
    @api recTypeSellside;
    @api recTypeOtherside;
    @api requiredFieldsPurchase;
    @api requiredFieldsDetail;
    @api requiredFieldsClosing;
    @api requiredFieldsEarnout;
    @api requiredFieldsSellerNotes;
    priceEngageSumPurchaseTypeFieldsEdit = [
        ENGAGESUM_PURCHASETYPE_FIELD,
        ENGAGESUM_338ELECTION_FIELD
    ];
    priceEngageSumPurchasePriceFieldsEdit = [
        ENGAGESUM_PURCHASEBASE_FIELD,
        ENGAGESUM_WORKCAPITAL_FIELD,
        ENGAGESUM_POSTCLOSING_FIELD,
        ENGAGESUM_POSTCLOSING_NOTE_FIELD,
        ENGAGESUM_TOTALPURCHASE_FIELD
    ];
    priceEngageSumConsidFieldsEdit = [
        ENGAGESUM_CONCASH_FIELD,ENGAGESUM_CONCASH_PCT_FIELD,
        ENGAGESUM_CONSTOCK_FIELD,ENGAGESUM_CONSTOCK_PCT_FIELD,
        ENGAGESUM_EARNOUTPAY_FIELD,ENGAGESUM_EARNOUTPAY_PCT_FIELD,
        ENGAGESUM_OTHERPAY_FIELD,ENGAGESUM_OTHERPAY_PCT_FIELD,
        ENGAGESUM_CONSTOCK_NOTE_FIELD,ENGAGESUM_OTHERPAY_NOTE_FIELD,
        ENGAGESUM_TOTALCON_FIELD
    ];
    priceEngageSumClosingFieldsEdit = [
        ENGAGESUM_METRICSUSED_FIELD,
        ENGAGESUM_FIRSTMETRIC_FIELD,
        ENGAGESUM_SECONDMETRIC_FIELD,
        ENGAGESUM_PREPARTY_FIELD,
        ENGAGESUM_SEPESCROW_FIELD
    ];
    priceEngageSumEarnoutFieldsEdit = [
        ENGAGESUM_EARNINCLD_FIELD,
        ENGAGESUM_EARNMETRIC_FIELD,
        ENGAGESUM_EARNPERIOD_FIELD,
        ENGAGESUM_EARNACCEL_FIELD,
        ENGAGESUM_EARNOFFSET_FIELD
    ];
    priceEngageSumSellNoteFieldsEdit = [
        ENGAGESUM_SELLNOTE_FIELD,ENGAGESUM_SELLNOTE_PCT_FIELD,
        ENGAGESUM_SELLNOTETERM_FIELD,ENGAGESUM_SELLNOTEINTEREST_FIELD,
        ENGAGESUM_SELLNOTECONVERT_FIELD
    ];
}
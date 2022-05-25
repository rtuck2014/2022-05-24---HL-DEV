import { LightningElement, api } from 'lwc';
import ENGAGESUM_OFFER_PRIC__C_FIELD from '@salesforce/schema/Engagement_Summary__c.Offer_Price__c';
import ENGAGESUM_HIGH_52_W_WEEK_FIELD from '@salesforce/schema/Engagement_Summary__c.High_52_Week__c';
import ENGAGESUM_HIGH_52_P_WEEK_FIELD from '@salesforce/schema/Engagement_Summary__c.High_52_Week_Percent__c';
import ENGAGESUM_LOW_52_W_WEEK_FIELD from '@salesforce/schema/Engagement_Summary__c.Low_52_Week__c';
import ENGAGESUM_LOW_52_P_WEEK_FIELD from '@salesforce/schema/Engagement_Summary__c.Low_52_Week_Percent__c';
import ENGAGESUM_PRIOR_CLOS__C_FIELD from '@salesforce/schema/Engagement_Summary__c.Prior_Close__c';
import ENGAGESUM_PRIOR_CLOS_PERC_FIELD from '@salesforce/schema/Engagement_Summary__c.Prior_Close_Percent__c';
import ENGAGESUM_WEIGHTED_AVG__30_D_FIELD from '@salesforce/schema/Engagement_Summary__c.Weighted_Avg_30_Day__c';
import ENGAGESUM_WEIGHTED_AVG__30_DP_FIELD from '@salesforce/schema/Engagement_Summary__c.Weighted_Avg_30_Day_Percent__c';
import ENGAGESUM_WEIGHTED_AVG__60_D_FIELD from '@salesforce/schema/Engagement_Summary__c.Weighted_Avg_60_Day__c';
import ENGAGESUM_WEIGHTED_AVG__60_DP_FIELD from '@salesforce/schema/Engagement_Summary__c.Weighted_Avg_60_Day_Percent__c';
import ENGAGESUM_WEIGHTED_AVG__90_D_FIELD from '@salesforce/schema/Engagement_Summary__c.Weighted_Avg_90_Day__c';
import ENGAGESUM_WEIGHTED_AVG__90_DP_FIELD from '@salesforce/schema/Engagement_Summary__c.Weighted_Avg_90_Day_Percent__c';
import ENGAGESUM_TRANSACTION_STRU__C_FIELD from '@salesforce/schema/Engagement_Summary__c.Transaction_Structure__c';
import ENGAGESUM_PRO_FORM_OWNE_FIELD from '@salesforce/schema/Engagement_Summary__c.Pro_Forma_Ownership__c';
import ENGAGESUM_TACTICAL_APPR__C_FIELD from '@salesforce/schema/Engagement_Summary__c.Tactical_Approach__c';
import ENGAGESUM_HAD_SPEC_COMM_FIELD from '@salesforce/schema/Engagement_Summary__c.Had_Special_Committee_Review__c';
import ENGAGESUM_MEMBERS_ON_S_SPEC_FIELD from '@salesforce/schema/Engagement_Summary__c.Members_On_Special_Committee__c';
import ENGAGESUM_WAS_BOAR_VOTE_FIELD from '@salesforce/schema/Engagement_Summary__c.Was_Board_Vote_Unanimous__c';
import ENGAGESUM_DID_COMM_HAVE_FIELD from '@salesforce/schema/Engagement_Summary__c.Did_Committee_Have_Separate_Advisor__c';
import ENGAGESUM_HAD_SECO_FAIR_FIELD from '@salesforce/schema/Engagement_Summary__c.Had_Second_Fairness_Opinion__c';
import ENGAGESUM_HAD_LOCK_PROV_FIELD from '@salesforce/schema/Engagement_Summary__c.Had_Lockup_Provision__c';
import ENGAGESUM_OUTSTANDING_LOCK_PERC_FIELD from '@salesforce/schema/Engagement_Summary__c.Outstanding_Lockup_Percent__c';
import ENGAGESUM_HAD_GO_S_SHOP_FIELD from '@salesforce/schema/Engagement_Summary__c.Had_Go_Shop_Provision__c';
import ENGAGESUM_GO_SHOP_PROV_FIELD from '@salesforce/schema/Engagement_Summary__c.Go_Shop_Provision_Months__c';
import ENGAGESUM_ORIGINAL_BIDD_HAD__FIELD from '@salesforce/schema/Engagement_Summary__c.Original_Bidder_Had_Matching_Right__c';
import ENGAGESUM_WAS_FIDU_OUT__FIELD from '@salesforce/schema/Engagement_Summary__c.Was_Fiduciary_Out__c';
import ENGAGESUM_WAS_FINA_OUT__FIELD from '@salesforce/schema/Engagement_Summary__c.Was_Financing_Out__c';
import ENGAGESUM_WAS_COMM_LETT_FIELD from '@salesforce/schema/Engagement_Summary__c.Was_Commitment_Letter_Delivered__c';
import ENGAGESUM_TERMINATION_FEE___C_FIELD from '@salesforce/schema/Engagement_Summary__c.Termination_Fee__c';
import ENGAGESUM_MANAGEMENT_OWNE_PERC_FIELD from '@salesforce/schema/Engagement_Summary__c.Management_Ownership_Percent__c';
import ENGAGESUM_TOTAL_INSI_OWNE_FIELD from '@salesforce/schema/Engagement_Summary__c.Total_Insider_Ownership_Percent__c';
import ENGAGESUM_CONTROLLING_SHAR_OWNE_FIELD from '@salesforce/schema/Engagement_Summary__c.Controlling_Shareholder_Ownership__c';
import ENGAGESUM_LOCKUP_CONT_SHAR_FIELD from '@salesforce/schema/Engagement_Summary__c.Lockup_Controlling_Shareholders__c';
import ENGAGESUM_LOCKUP_INSI__C_FIELD from '@salesforce/schema/Engagement_Summary__c.Lockup_Insiders__c';
import ENGAGESUM_LOCKUP_MANA__C_FIELD from '@salesforce/schema/Engagement_Summary__c.Lockup_Management__c';
import ENGAGESUM_SHAREHOLDERS_VOTE_FAVO_FIELD from '@salesforce/schema/Engagement_Summary__c.Shareholders_Voted_Favorably__c';
import ENGAGESUM_STAGGERED_CLAS_BOAR_FIELD from '@salesforce/schema/Engagement_Summary__c.Staggered_Classified_Board__c';
import ENGAGESUM_RIGHTS_OFFE_PLAN_FIELD from '@salesforce/schema/Engagement_Summary__c.Rights_Offering_Plan__c';
import ENGAGESUM_VOTE_REQU_FOR__FIELD from '@salesforce/schema/Engagement_Summary__c.Vote_Required_For_Ammendments__c';
import ENGAGESUM_FAIR_PRIC_PROV_FIELD from '@salesforce/schema/Engagement_Summary__c.Fair_Price_Provisions__c';
import ENGAGESUM_ADVANCE_NOTI_REQU_FIELD from '@salesforce/schema/Engagement_Summary__c.Advance_Notice_Requirement__c';

export default class HlEngageSumCfPublic extends LightningElement {
    @api engagementId;
    @api engageSumId;
    @api jobTypeBuyside;
    @api jobTypeSellside;
    @api jobTypeNoside;
    @api requiredFieldsDisabled;
    @api requiredFieldsTransaction;
    @api requiredFieldsDefense;
    @api requiredFieldsFiduciary;
    @api requiredFieldsShareholders;
    engageSumPurchPrem1Fields = [
        ENGAGESUM_OFFER_PRIC__C_FIELD
    ];
    engageSumPurchPrem2Fields = [
        ENGAGESUM_HIGH_52_W_WEEK_FIELD, ENGAGESUM_HIGH_52_P_WEEK_FIELD,
        ENGAGESUM_LOW_52_W_WEEK_FIELD, ENGAGESUM_LOW_52_P_WEEK_FIELD,
        ENGAGESUM_PRIOR_CLOS__C_FIELD,ENGAGESUM_PRIOR_CLOS_PERC_FIELD,
        ENGAGESUM_WEIGHTED_AVG__30_D_FIELD, ENGAGESUM_WEIGHTED_AVG__30_DP_FIELD,
        ENGAGESUM_WEIGHTED_AVG__60_D_FIELD, ENGAGESUM_WEIGHTED_AVG__60_DP_FIELD,
        ENGAGESUM_WEIGHTED_AVG__90_D_FIELD,ENGAGESUM_WEIGHTED_AVG__90_DP_FIELD
    ];
    engageSumTrxStructFields = [
        ENGAGESUM_TRANSACTION_STRU__C_FIELD,
        ENGAGESUM_PRO_FORM_OWNE_FIELD,
        ENGAGESUM_TACTICAL_APPR__C_FIELD
    ];
    engageSumFiduciaryDealFields = [
        ENGAGESUM_HAD_SPEC_COMM_FIELD,ENGAGESUM_MEMBERS_ON_S_SPEC_FIELD,
        ENGAGESUM_WAS_BOAR_VOTE_FIELD,ENGAGESUM_DID_COMM_HAVE_FIELD,
        ENGAGESUM_HAD_SECO_FAIR_FIELD,ENGAGESUM_HAD_LOCK_PROV_FIELD,
        ENGAGESUM_OUTSTANDING_LOCK_PERC_FIELD,ENGAGESUM_HAD_GO_S_SHOP_FIELD,
        ENGAGESUM_GO_SHOP_PROV_FIELD,ENGAGESUM_ORIGINAL_BIDD_HAD__FIELD,
        ENGAGESUM_WAS_FIDU_OUT__FIELD,ENGAGESUM_WAS_FINA_OUT__FIELD,
        ENGAGESUM_WAS_COMM_LETT_FIELD,ENGAGESUM_TERMINATION_FEE___C_FIELD
    ];
    engageSumShareholdersFields = [
        ENGAGESUM_MANAGEMENT_OWNE_PERC_FIELD, ENGAGESUM_TOTAL_INSI_OWNE_FIELD,
        ENGAGESUM_CONTROLLING_SHAR_OWNE_FIELD,ENGAGESUM_LOCKUP_CONT_SHAR_FIELD,
        ENGAGESUM_LOCKUP_INSI__C_FIELD,ENGAGESUM_LOCKUP_MANA__C_FIELD,
        ENGAGESUM_SHAREHOLDERS_VOTE_FAVO_FIELD
    ];
    engageSumCompanyDefenseFields = [
        ENGAGESUM_STAGGERED_CLAS_BOAR_FIELD,ENGAGESUM_RIGHTS_OFFE_PLAN_FIELD,
        ENGAGESUM_VOTE_REQU_FOR__FIELD,ENGAGESUM_FAIR_PRIC_PROV_FIELD,
        ENGAGESUM_ADVANCE_NOTI_REQU_FIELD
    ];
}
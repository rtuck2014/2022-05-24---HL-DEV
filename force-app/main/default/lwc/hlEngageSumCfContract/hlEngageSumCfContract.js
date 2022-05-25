import { LightningElement, api } from 'lwc';

import ENGAGESUM_REPWARRANTIES_INS_FIELD from '@salesforce/schema/Engagement_Summary__c.Representations_and_Warranties_Insurance__c';
import ENGAGESUM_REPWARRANTIES_LIMIT_FIELD from '@salesforce/schema/Engagement_Summary__c.Reps_and_Warranties_Insurance_Limit__c';
import ENGAGESUM_REPWARRANTIES_COST_FIELD from '@salesforce/schema/Engagement_Summary__c.Reps_and_Warranties_Insurance_Cost__c';
import ENGAGESUM_REPWARRANTIES_RETEN_FIELD from '@salesforce/schema/Engagement_Summary__c.Reps_and_Warranties_Insurance_Retention__c';
import ENGAGE_SUM_CARVEOUT_MARKALLNO_FIELD from '@salesforce/schema/Engagement_Summary__c.Mark_All_Carveouts_as_No__c';

import ENGAGESUM_INDEMNITY_BASK_TYPE_FIELD from '@salesforce/schema/Engagement_Summary__c.Indemnity_Basket_Type__c';
import ENGAGESUM_INDEMNITY_BASK_SIZE_FIELD from '@salesforce/schema/Engagement_Summary__c.Indemnity_Basket_Size__c';
import ENGAGESUM_INDEMNITY_BASK_SIZEPER_FIELD from '@salesforce/schema/Engagement_Summary__c.Indemnity_Basket_Size_Percent__c';
import ENGAGESUM_INDEMNITY_BASK_THRE_FIELD from '@salesforce/schema/Engagement_Summary__c.Indemnity_Basket_Threshold_Remedy__c';

import ENGAGESUM_INDEMNITY_CAPS_TYPE_FIELD from '@salesforce/schema/Engagement_Summary__c.Indemnity_Caps_Type__c';
import ENGAGESUM_INDEMNITY_CAPS_SIZE_FIELD from '@salesforce/schema/Engagement_Summary__c.Indemnity_Caps_Size__c';
import ENGAGESUM_INDEMNITY_CAPS_SIZEPER_FIELD from '@salesforce/schema/Engagement_Summary__c.Indemnity_Caps_Size_Percent__c';
import ENGAGESUM_INDEMNITY_CAPS_TERM_FIELD from '@salesforce/schema/Engagement_Summary__c.Indemnity_Caps_Term__c';
import ENGAGESUM_INDEMNITY_CAPS_THRE_FIELD from '@salesforce/schema/Engagement_Summary__c.Indemnity_Caps_Threshold_Remedy__c';

import ENGAGESUM_INDEMNITY_ESCR_TYPE_FIELD from '@salesforce/schema/Engagement_Summary__c.Indemnity_Escrow_Type__c';
import ENGAGESUM_INDEMNITY_ESCR_SIZE_FIELD from '@salesforce/schema/Engagement_Summary__c.Indemnity_Escrow_Size__c';
import ENGAGESUM_INDEMNITY_ESCR_SIZEPER_FIELD from '@salesforce/schema/Engagement_Summary__c.Indemnity_Escrow_Size_Percent__c';
import ENGAGESUM_INDEMNITY_ESCR_TERM_FIELD from '@salesforce/schema/Engagement_Summary__c.Indemnity_Escrow_Term__c';

import ENGAGESUM_CARVEOUT_ENVI_TYPE_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Environmental_Type__c';
import ENGAGESUM_CARVEOUT_ENVI_CAPS_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Environmental_CapSize__c';
import ENGAGESUM_CARVEOUT_ENVI_BASK_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Environmental_BasketSize__c';
import ENGAGESUM_CARVEOUT_ENVI_SURV_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Environmental_SurvivalPeriod__c';

import ENGAGESUM_CARVEOUT_CAPI_SURV_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Capitalization_Survival__c';
import ENGAGESUM_CARVEOUT_CAPI_BASK_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Capitalization_Basket__c';
import ENGAGESUM_CARVEOUT_CAPI_CAPS_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Capitalization_Caps__c';
import ENGAGESUM_CARVEOUT_CAPI_TYPE_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Capitalization_Type__c';
import ENGAGESUM_CARVEOUT_CAPI_CAPSSZ_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Capitalization_CapSize__c';
import ENGAGESUM_CARVEOUT_CAPI_BASKSZ_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Capitalization_BasketSize__c';
import ENGAGESUM_CARVEOUT_CAPI_SURVPD_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Capitalization_SurvivalPeriod__c';

import ENGAGESUM_CARVEOUT_OWNE_SURV_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Ownership_Survival__c';
import ENGAGESUM_CARVEOUT_OWNE_BASK_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Ownership_Basket__c';
import ENGAGESUM_CARVEOUT_OWNE_CAPS_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Ownership_Caps__c';
import ENGAGESUM_CARVEOUT_OWNE_TYPE_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Ownership_Type__c';
import ENGAGESUM_CARVEOUT_OWNE_CAPSSZ_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Ownership_CapSize__c';
import ENGAGESUM_CARVEOUT_OWNE_BASKSZ_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Ownership_BasketSize__c';
import ENGAGESUM_CARVEOUT_OWNE_SURVPD_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Ownership_SurvivalPeriod__c';

import ENGAGESUM_CARVEOUT_DUEA_SURV_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_DueAuthority_Survival__c';
import ENGAGESUM_CARVEOUT_DUEA_BASK_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_DueAuthority_Basket__c';
import ENGAGESUM_CARVEOUT_DUEA_CAPS_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_DueAuthority_Caps__c';
import ENGAGESUM_CARVEOUT_DUEA_TYPE_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_DueAuthority_Type__c';
import ENGAGESUM_CARVEOUT_DUEA_CAPSSZ_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_DueAuthority_CapSize__c';
import ENGAGESUM_CARVEOUT_DUEA_BASKSZ_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_DueAuthority_BasketSize__c';
import ENGAGESUM_CARVEOUT_DUEA_SURVPD_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_DueAuthority_SurvivalPeriod__c';

import ENGAGESUM_CARVEOUT_TAXE_SURV_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Taxes_Survival__c';
import ENGAGESUM_CARVEOUT_TAXE_BASK_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Taxes_Basket__c';
import ENGAGESUM_CARVEOUT_TAXE_CAPS_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Taxes_Caps__c';
import ENGAGESUM_CARVEOUT_TAXE_TYPE_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Taxes_Type__c';
import ENGAGESUM_CARVEOUT_TAXE_CAPSSZ_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Taxes_CapSize__c';
import ENGAGESUM_CARVEOUT_TAXE_BASKSZ_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Taxes_BasketSize__c';
import ENGAGESUM_CARVEOUT_TAXE_SURVPD_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Taxes_SurvivalPeriod__c';

import ENGAGESUM_CARVEOUT_DUEO_SURV_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_DueOrganization_Survival__c';
import ENGAGESUM_CARVEOUT_DUEO_BASK_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_DueOrganization_Basket__c';
import ENGAGESUM_CARVEOUT_DUEO_CAPS_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_DueOrganization_Caps__c';
import ENGAGESUM_CARVEOUT_DUEO_TYPE_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_DueOrganization_Type__c';
import ENGAGESUM_CARVEOUT_DUEO_CAPSSZ_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_DueOrganization_CapSize__c';
import ENGAGESUM_CARVEOUT_DUEO_BASKSZ_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_DueOrganization_BasketSize__c';
import ENGAGESUM_CARVEOUT_DUEO_SURVPD_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_DueOrganization_SurvivalPeriod__c';

import ENGAGESUM_CARVEOUT_BROK_SURV_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_BrokerFinderFee_Survival__c';
import ENGAGESUM_CARVEOUT_BROK_BASK_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_BrokerFinderFee_Basket__c';
import ENGAGESUM_CARVEOUT_BROK_CAPS_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_BrokerFinderFee_Caps__c';
import ENGAGESUM_CARVEOUT_BROK_TYPE_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_BrokerFinderFee_Type__c';
import ENGAGESUM_CARVEOUT_BROK_CAPSSZ_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_BrokerFinderFee_CapSize__c';
import ENGAGESUM_CARVEOUT_BROK_BASKSZ_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_BrokerFinderFee_BasketSize__c';
import ENGAGESUM_CARVEOUT_BROK_SURVPD_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_BrokerFinderFee_SurvivalPeriod__c';

import ENGAGESUM_CARVEOUT_FRAU_SURV_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Fraud_Survival__c';
import ENGAGESUM_CARVEOUT_FRAU_BASK_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Fraud_Basket__c';
import ENGAGESUM_CARVEOUT_FRAU_CAPS_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Fraud_Caps__c';
import ENGAGESUM_CARVEOUT_FRAU_TYPE_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Fraud_Type__c';
import ENGAGESUM_CARVEOUT_FRAU_CAPSSZ_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Fraud_CapSize__c';
import ENGAGESUM_CARVEOUT_FRAU_BASKSZ_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Fraud_BasketSize__c';
import ENGAGESUM_CARVEOUT_FRAU_SURVPD_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_Fraud_SurvivalPeriod__c';

import ENGAGESUM_CARVEOUT_INTE_SU_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_IntentionalBreach_Survival__c';
import ENGAGESUM_CARVEOUT_INTE_BA_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_IntentionalBreach_Basket__c';
import ENGAGESUM_CARVEOUT_INTE_CA_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_IntentionalBreach_Caps__c';
import ENGAGESUM_CARVEOUT_INTE_TY_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_IntentionalBreach_Type__c';
import ENGAGESUM_CARVEOUT_INTE_CASZ_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_IntentionalBreach_CapSize__c';
import ENGAGESUM_CARVEOUT_INTE_BASZ_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_IntentionalBreach_BasketSize__c';
import ENGAGESUM_CARVEOUT_INTE_SUPD_FIELD from '@salesforce/schema/Engagement_Summary__c.Carveout_IntentionalBreach_SurvivalPer__c';

import ENGAGESUM_KEY_CONT_COMM_FIELD from '@salesforce/schema/Engagement_Summary__c.Key_Contract_Comments__c';

export default class HlEngageSumCfContract extends LightningElement {
    @api requiredFieldsRepWarranty;
    @api requiredFieldsBasket;
    @api requiredFieldsCaps;
    @api requiredFieldsEscrow;
    @api requiredFieldsCarveOut1;
    @api requiredFieldsCarveOut2;
    engageSumRepWarrantyFields = [
        ENGAGESUM_REPWARRANTIES_INS_FIELD,ENGAGESUM_REPWARRANTIES_LIMIT_FIELD,
        ENGAGESUM_REPWARRANTIES_COST_FIELD,ENGAGESUM_REPWARRANTIES_RETEN_FIELD
    ];
    engageSumIndemnityBasketFields = [
        ENGAGESUM_INDEMNITY_BASK_TYPE_FIELD,
        ENGAGESUM_INDEMNITY_BASK_SIZE_FIELD,
        ENGAGESUM_INDEMNITY_BASK_SIZEPER_FIELD,
        ENGAGESUM_INDEMNITY_BASK_THRE_FIELD
    ]; 
    engageSumIndemnityCapsFields = [
        ENGAGESUM_INDEMNITY_CAPS_TYPE_FIELD,
        ENGAGESUM_INDEMNITY_CAPS_SIZE_FIELD,
        ENGAGESUM_INDEMNITY_CAPS_SIZEPER_FIELD,
        ENGAGESUM_INDEMNITY_CAPS_TERM_FIELD,
        ENGAGESUM_INDEMNITY_CAPS_THRE_FIELD
    ];
    engageSumIndemnityEscrowFields = [
        ENGAGESUM_INDEMNITY_ESCR_TYPE_FIELD,
        ENGAGESUM_INDEMNITY_ESCR_SIZE_FIELD,
        ENGAGESUM_INDEMNITY_ESCR_SIZEPER_FIELD,
        ENGAGESUM_INDEMNITY_ESCR_TERM_FIELD
    ]; 
    engageSumCarveOut1Fields = [
        ENGAGESUM_CARVEOUT_ENVI_TYPE_FIELD,ENGAGESUM_CARVEOUT_ENVI_CAPS_FIELD,
        ENGAGESUM_CARVEOUT_ENVI_BASK_FIELD,ENGAGESUM_CARVEOUT_ENVI_SURV_FIELD,
        ENGAGE_SUM_CARVEOUT_MARKALLNO_FIELD
    ];
    engageSumCarveOut2Fields = [
        ENGAGESUM_CARVEOUT_CAPI_SURV_FIELD,ENGAGESUM_CARVEOUT_CAPI_BASK_FIELD,ENGAGESUM_CARVEOUT_CAPI_CAPS_FIELD,
        ENGAGESUM_CARVEOUT_OWNE_SURV_FIELD,ENGAGESUM_CARVEOUT_OWNE_BASK_FIELD,ENGAGESUM_CARVEOUT_OWNE_CAPS_FIELD,
        ENGAGESUM_CARVEOUT_DUEA_SURV_FIELD,ENGAGESUM_CARVEOUT_DUEA_BASK_FIELD,ENGAGESUM_CARVEOUT_DUEA_CAPS_FIELD,
        ENGAGESUM_CARVEOUT_TAXE_SURV_FIELD,ENGAGESUM_CARVEOUT_TAXE_BASK_FIELD,ENGAGESUM_CARVEOUT_TAXE_CAPS_FIELD,
        ENGAGESUM_CARVEOUT_DUEO_SURV_FIELD,ENGAGESUM_CARVEOUT_DUEO_BASK_FIELD,ENGAGESUM_CARVEOUT_DUEO_CAPS_FIELD,
        ENGAGESUM_CARVEOUT_BROK_SURV_FIELD,ENGAGESUM_CARVEOUT_BROK_BASK_FIELD,ENGAGESUM_CARVEOUT_BROK_CAPS_FIELD,
        ENGAGESUM_CARVEOUT_FRAU_SURV_FIELD,ENGAGESUM_CARVEOUT_FRAU_BASK_FIELD,ENGAGESUM_CARVEOUT_FRAU_CAPS_FIELD,
        ENGAGESUM_CARVEOUT_INTE_SU_FIELD,ENGAGESUM_CARVEOUT_INTE_BA_FIELD,ENGAGESUM_CARVEOUT_INTE_CA_FIELD
    ];
    engageSumCarveOut3Fields = [
        ENGAGESUM_CARVEOUT_CAPI_TYPE_FIELD,ENGAGESUM_CARVEOUT_CAPI_CAPSSZ_FIELD,ENGAGESUM_CARVEOUT_CAPI_BASKSZ_FIELD,ENGAGESUM_CARVEOUT_CAPI_SURVPD_FIELD,
        ENGAGESUM_CARVEOUT_OWNE_TYPE_FIELD,ENGAGESUM_CARVEOUT_OWNE_CAPSSZ_FIELD,ENGAGESUM_CARVEOUT_OWNE_BASKSZ_FIELD,ENGAGESUM_CARVEOUT_OWNE_SURVPD_FIELD,
        ENGAGESUM_CARVEOUT_DUEA_TYPE_FIELD,ENGAGESUM_CARVEOUT_DUEA_CAPSSZ_FIELD,ENGAGESUM_CARVEOUT_DUEA_BASKSZ_FIELD,ENGAGESUM_CARVEOUT_DUEA_SURVPD_FIELD,
        ENGAGESUM_CARVEOUT_TAXE_TYPE_FIELD,ENGAGESUM_CARVEOUT_TAXE_CAPSSZ_FIELD,ENGAGESUM_CARVEOUT_TAXE_BASKSZ_FIELD,ENGAGESUM_CARVEOUT_TAXE_SURVPD_FIELD,
        ENGAGESUM_CARVEOUT_DUEO_TYPE_FIELD,ENGAGESUM_CARVEOUT_DUEO_CAPSSZ_FIELD,ENGAGESUM_CARVEOUT_DUEO_BASKSZ_FIELD,ENGAGESUM_CARVEOUT_DUEO_SURVPD_FIELD,
        ENGAGESUM_CARVEOUT_BROK_TYPE_FIELD,ENGAGESUM_CARVEOUT_BROK_CAPSSZ_FIELD,ENGAGESUM_CARVEOUT_BROK_BASKSZ_FIELD,ENGAGESUM_CARVEOUT_BROK_SURVPD_FIELD,
        ENGAGESUM_CARVEOUT_FRAU_TYPE_FIELD,ENGAGESUM_CARVEOUT_FRAU_CAPSSZ_FIELD,ENGAGESUM_CARVEOUT_FRAU_BASKSZ_FIELD,ENGAGESUM_CARVEOUT_FRAU_SURVPD_FIELD,
        ENGAGESUM_CARVEOUT_INTE_TY_FIELD,ENGAGESUM_CARVEOUT_INTE_CASZ_FIELD,ENGAGESUM_CARVEOUT_INTE_BASZ_FIELD,ENGAGESUM_CARVEOUT_INTE_SUPD_FIELD
    ];
    engaegSumKeyCommFields = [
        ENGAGESUM_KEY_CONT_COMM_FIELD
    ];
    @api engagementId;
    @api engageSumId;
    @api jobTypeBuyside;
    @api jobTypeSellside;
    @api jobTypeNoside;
}
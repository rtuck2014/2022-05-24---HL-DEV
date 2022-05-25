import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import ENGAGESUM_STAGE_FIELD from '@salesforce/schema/Engagement_Summary__c.Summary_Status__c';
import ENGAGE_PITCH_DATE_FIELD from '@salesforce/schema/Engagement__c.Pitch_Book_Date__c';
import ENGAGE_ENG_DATE_FIELD from '@salesforce/schema/Engagement__c.Date_Engaged__c';
import ENGAGE_MARKET_DATE_FIELD from '@salesforce/schema/Engagement__c.Expected_In_Market_Date__c';
import ENGAGE_FIRSTBID_DATE_FIELD from '@salesforce/schema/Engagement__c.First_Bid_Due_Date__c';
import ENGAGE_SECONDBID_DATE_FIELD from '@salesforce/schema/Engagement__c.Second_Bid_Due_Date__c';
import ENGAGE_FINALBID_DATE_FIELD from '@salesforce/schema/Engagement__c.Final_Bid_Due_Date__c';
import ENGAGE_CLOSINGBID_DATE_FIELD from '@salesforce/schema/Engagement__c.Closing_Bid_Due_Date__c';
import ENGAGE_CLOSINGBID_WEEKS_FIELD from '@salesforce/schema/Engagement__c.Closing_Bid_Weeks_From_Date_Engaged__c';
import ENGAGE_CONCLU_DATE_FIELD from '@salesforce/schema/Engagement__c.Conclusion_Date__c';
import ENGAGE_CONCLUSION_WEEKS_FIELD from '@salesforce/schema/Engagement__c.Conclusion_Weeks_From_Date_Engaged__c';
export default class HlEngageSumCfContent extends LightningElement {
    @api engagementId;
    @api engageSumId;
    @api engagementRecTypeId;
    @api engageSumRecTypeId;
    @api engageSumFields;
    @api engageRecord;
    @api engageLob;
    @api engageJobTypeNorm;
    @track spinner = true;
    engageTimelineSellsideFields1 = [
        ENGAGE_PITCH_DATE_FIELD,ENGAGE_MARKET_DATE_FIELD,ENGAGE_ENG_DATE_FIELD,
        ENGAGE_FIRSTBID_DATE_FIELD,ENGAGE_SECONDBID_DATE_FIELD,ENGAGE_FINALBID_DATE_FIELD
    ];
    engageTimelineBuysideFields1 = [
        ENGAGE_PITCH_DATE_FIELD,ENGAGE_ENG_DATE_FIELD,
        ENGAGE_FIRSTBID_DATE_FIELD,ENGAGE_SECONDBID_DATE_FIELD,ENGAGE_FINALBID_DATE_FIELD,
    ];
    engageTimelineFields2 = [
        ENGAGE_CLOSINGBID_DATE_FIELD,
        ENGAGE_CLOSINGBID_WEEKS_FIELD
    ];
    engageTimelineFields3 = [
        ENGAGE_CONCLU_DATE_FIELD,
        ENGAGE_CONCLUSION_WEEKS_FIELD
    ];
    @track sectionsValidChecker = [];
    @track sectionParties = false;
    @track sectionPartiesRequiredIcon = 'utility:check';
    @track sectionPartiesRequiredVariant = 'base';
    @track sectionPartiesRequiredSubject = 'Validating...';
    @track sectionPartiesRequiredFieldsStatus;
    @track sectionMarket = false;
    @track sectionMarketRequiredIcon = 'utility:check';
    @track sectionMarketRequiredVariant = 'base';
    @track sectionMarketRequiredSubject = 'Validating...';
    @track sectionMarketRequiredFieldsStatus;
    @track sectionPublic = false;
    @track sectionPublicRequiredDisabled = true;
    @track sectionPublicRequiredIcon = 'utility:check';
    @track sectionPublicRequiredVariant = 'base';
    @track sectionPublicRequiredSubject = 'Validating...';
    @track sectionPublicRequiredFieldsStatus;
    sectionPublicTransactionRequiredFields = [
        {Object: 'Engagement_Summary__c', fieldApiName:'Transaction_Structure__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Tactical_Approach__c'}
    ];
    sectionPublicFiduciaryRequiredFields = [
        {Object: 'Engagement_Summary__c', fieldApiName:'Had_Special_Committee_Review__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Was_Board_Vote_Unanimous__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Did_Committee_Have_Separate_Advisor__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Had_Second_Fairness_Opinion__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Had_Lockup_Provision__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Had_Go_Shop_Provision__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Original_Bidder_Had_Matching_Right__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Was_Fiduciary_Out__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Was_Financing_Out__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Was_Commitment_Letter_Delivered__c'},
    ];
    sectionPublicShareholdersRequiredFields = [
        {Object: 'Engagement_Summary__c', fieldApiName:'Lockup_Controlling_Shareholders__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Lockup_Insiders__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Lockup_Management__c'}
    ];
    sectionPublicDefenseRequiredFields = [
        {Object: 'Engagement_Summary__c', fieldApiName:'Staggered_Classified_Board__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Rights_Offering_Plan__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Fair_Price_Provisions__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Advance_Notice_Requirement__c'}
    ];
    @track sectionPrice = false;
    @track sectionPriceRequiredIcon = 'utility:check';
    @track sectionPriceRequiredVariant = 'base';
    @track sectionPriceRequiredSubject = 'Validating...';
    @track sectionPriceRequiredFieldsStatus;
    sectionPricePurchaseRequiredFields = [
        {Object: 'Engagement_Summary__c', fieldApiName:'Purchase_Type__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Took_338_Selection__c'}
    ];
    sectionPriceDetailRequiredFields = [
        {Object: 'Engagement_Summary__c', fieldApiName:'Purchase_Price_Base__c'},
    ];
    sectionPriceClosingRequiredFields = [
        {Object: 'Engagement_Summary__c', fieldApiName:'Metrics_Used__c',
            dependantFields: [
                {Object: 'Engagement_Summary__c', fieldApiName:'First_Metric__c'},
                {Object: 'Engagement_Summary__c', fieldApiName:'Second_Metric__c'},
                {Object: 'Engagement_Summary__c', fieldApiName:'Preparing_Party__c'},
                {Object: 'Engagement_Summary__c', fieldApiName:'Had_Separate_Escrow__c'}
            ]
        }
    ];
    sectionPriceEarnoutRequiredFields = [
        {   Object: 'Engagement_Summary__c', fieldApiName:'Was_Earnout_Included__c',
            dependantFields: [
                {Object: 'Engagement_Summary__c', fieldApiName:'Earnout_Metric__c'},
                {Object: 'Engagement_Summary__c', fieldApiName:'Earnout_Period__c'},
                {Object: 'Engagement_Summary__c', fieldApiName:'Does_Earnout_Accelerate__c'},
                {Object: 'Engagement_Summary__c', fieldApiName:'Is_Buyer_Able_To_Offset_Earnout__c'}
            ]
        }
    ];
    sectionPriceSellerNotesRequiredFields = [
        {   Object: 'Engagement_Summary__c', fieldApiName:'Consideration_Seller_Notes__c', passive: true,
            dependantFields: [
                {Object: 'Engagement_Summary__c', fieldApiName:'Seller_Notes_Term__c'},
                {Object: 'Engagement_Summary__c', fieldApiName:'Seller_Notes_Interest_Percent__c'},
                {Object: 'Engagement_Summary__c', fieldApiName:'Has_Seller_Note_Conversion_Rights__c'}
            ]
        }
    ];
    @track sectionKeyContract = false;
    @track sectionKeyContractRequiredIcon = 'utility:check';
    @track sectionKeyContractRequiredVariant = 'base';
    @track sectionKeyContractRequiredSubject = 'Validating...';
    @track sectionKeyContractRequiredFieldsStatus;
    sectionKeyContractRepWarrantyRequiredFields = [
        {Object: 'Engagement_Summary__c', fieldApiName:'Representations_and_Warranties_Insurance__c'},
    ];
    sectionKeyContractBasketRequiredFields = [
        {Object: 'Engagement_Summary__c', fieldApiName:'Indemnity_Basket_Type__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Indemnity_Basket_Threshold_Remedy__c'}
    ];
    sectionKeyContractCapsRequiredFields = [
        {Object: 'Engagement_Summary__c', fieldApiName:'Indemnity_Caps_Type__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Indemnity_Caps_Term__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Indemnity_Caps_Threshold_Remedy__c'}
    ];
    sectionKeyContractEscrowRequiredFields = [
        {Object: 'Engagement_Summary__c', fieldApiName:'Indemnity_Escrow_Type__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Indemnity_Escrow_Term__c'}
    ];
    sectionKeyContractCarveout1RequiredFields = [
        {Object: 'Engagement_Summary__c', fieldApiName:'Carveout_Environmental_Type__c'},
    ];
    sectionKeyContractCarveout2RequiredFields = [
        {Object: 'Engagement_Summary__c', fieldApiName:'Carveout_Capitalization_Survival__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Carveout_Capitalization_Basket__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Carveout_Capitalization_Caps__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Carveout_Ownership_Survival__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Carveout_Ownership_Basket__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Carveout_Ownership_Caps__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Carveout_DueAuthority_Survival__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Carveout_DueAuthority_Basket__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Carveout_DueAuthority_Caps__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Carveout_Taxes_Survival__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Carveout_Taxes_Basket__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Carveout_Taxes_Caps__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Carveout_DueOrganization_Survival__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Carveout_DueOrganization_Basket__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Carveout_DueOrganization_Caps__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Carveout_BrokerFinderFee_Survival__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Carveout_BrokerFinderFee_Basket__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Carveout_BrokerFinderFee_Caps__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Carveout_Fraud_Survival__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Carveout_Fraud_Basket__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Carveout_Fraud_Caps__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Carveout_IntentionalBreach_Survival__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Carveout_IntentionalBreach_Basket__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Carveout_IntentionalBreach_Caps__c'}
    ];
    @track sectionEmployee = false;
    @track sectionEmployeeRequiredIcon = 'utility:check';
    @track sectionEmployeeRequiredVariant = 'base';
    @track sectionEmployeeRequiredSubject = 'Validating...';
    @track sectionEmployeeRequiredFieldsStatus;
    sectionEmployeePreTrxRequiredFields = [
        {   Object: 'Engagement_Summary__c', 
            fieldApiName:'Seller_Had_Incentive_Plan__c',
            dependantFields: [
                {Object: 'Engagement_Summary__c', fieldApiName:'Incentive_Plan__c'}
            ]
        }
    ];
    sectionEmployeePostTrxRequiredFields = [
        {Object: 'Engagement_Summary__c', fieldApiName:'Required_New_Employment_Agreements__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Required_Rollover_Equity__c'},
        {Object: 'Engagement_Summary__c', fieldApiName:'Implemented_New_Option_Pool_Equity_Plan__c'}
    ];
    @track sectionCapDetails = false;
    @track sectionCapDetailsRequiredIcon = 'utility:check';
    @track sectionCapDetailsRequiredVariant = 'base';
    @track sectionCapDetailsRequiredSubject = 'Validating...';
    @track sectionCapDetailsRequiredFieldsStatus;
    @track sectionCredit = false;
    @track sectionCreditRequiredIcon = 'utility:check';
    @track sectionCreditRequiredVariant = 'base';
    @track sectionCreditRequiredSubject = 'Validating...';
    @track sectionCreditRequiredFieldsStatus;
    @track sectionDynamics = false;
    @track sectionDynamicsRequiredIcon = 'utility:check';
    @track sectionDynamicsRequiredVariant = 'base';
    @track sectionDynamicsRequiredSubject = 'Validating...';
    @track sectionDynamicRequiredFieldsStatus;
    @track sectionTimeline = false;
    @track sectionTimelineRequiredIcon = 'utility:check';
    @track sectionTimelineRequiredVariant = 'base';
    @track sectionTimelineRequiredSubject = 'Validating...';
    @track sectionTimelineRequiredFieldsStatus;
    @track engageSumRecordResult;
    @track engageSumStageData;
    @track engageSumStageError;
    engageSumStageField = ENGAGESUM_STAGE_FIELD;
    engageSumStageMessages = [
        'Review Sections below and ensure all Engagement details are present and accurate. Once complete set Status to "IN REVIEW" to submit this Engagement Summary for Approval.',
        'This Engagement Summary is being reviewed by a Prinicpal or Manager. The Approval History section above contains more details regarding Approvers and Status.',
        'This Engagement Summary is approved and will be locked. See Approval History section for more details on Approvers and history.'
    ];
    //LL20190604 - User progressive loading - on user request, improves performance
    sectionRender(event){
        //console.log('tabSection','==>',JSON.stringify(event.detail));
        let openSections = event.detail.openSections;
        if(openSections.length > 0){
            let allSections = [ 
                'sectionParties','sectionMarket','sectionPublic',
                'sectionPrice','sectionKeyContract','sectionEmployee',
                'sectionCapDetails','sectionCredit','sectionDynamics',
                'sectionTimeline'
            ];
            for(let i = 0; openSections.length > i; i++){
                let section = openSections[i];
                //console.log('sectionRender-prop:','==>',section);
                //console.log('sectionRender-propVal:','==>',this[section]);
                this[section] = true;
                allSections.splice(allSections.indexOf(section),1);
            }
            for(let i = 0; allSections.length > i; i++){
                this[allSections[i]] = false;
            }
        }
    }
    sectionCollapseAll(){
        //console.log('sectionCollapseAll');
        let button = this.template.querySelectorAll('lightning-accordion-section .slds-button')[0];
        //console.log('sectionCollapseAll-button','==>',button.length);
        button.click();
    }
    @api get jobTypeBuyside(){
        let jobType = false;
        if(this.engageJobTypeNorm === 'buyside') jobType = true;
        else jobType = false;
        return jobType;
    }
    @api get jobTypeSellside(){
        let jobType = false;
        if(this.engageJobTypeNorm === 'sellside') jobType = true;
        else jobType = false;
        return jobType;
    }
    @api get jobTypeNoside(){
        let jobType = false;
        if(this.engageJobTypeNorm === 'noside') jobType = true;
        else jobType = false;
        return jobType;
    }
    @wire(getRecord, { recordId: '$engageSumId', layoutTypes: ['Full'], modes: ['View']})
    engageSumRecord(result) {
        this.engageSumRecordResult = result;
       // console.log('engageSumRecord-result','==>',result);
        if(result){
            if(result.data){
               // console.log('engageSumRecord-Summary_Status__c','==>',result.data.fields.Summary_Status__c.value);
                let fieldsStatus = result.data.fields;
                this.dispatchEvent(new CustomEvent('engagesumload', { detail: fieldsStatus}));
                this.engageSumStageData = fieldsStatus['Summary_Status__c'].value;
                this.engageSumStageError = undefined;
                if(!this.initRender){
                    this.initRender = true;
                    this.sectionParties = false;
                    this.sectionParties = true; //LL20190705 - sectionParties validation complex, requires child component event propagation to track results
                    this.sectionCredit = false;
                    this.sectionCredit = true; //LL20190705 - sectionCredit validation complex, requires child component event propagation to track results
                }
                this.sectionMarketRequiredSubject = 'Please review';
                // //console.log('engageSumRecord-engageRecord.fields','==>',this.engageRecord.fields);
                let sectionPublicRenderField = this.engageRecord.fields.Subject_Company_Ownership__c;
                if(sectionPublicRenderField && sectionPublicRenderField.value){
                    if(sectionPublicRenderField.value.toLowerCase().indexOf('public') !== -1){
                        this.sectionPublicRequiredDisabled = false;
                        this.sectionPublicTransactionRequiredFields = this.requiredLabelSet(this.sectionPublicTransactionRequiredFields);
                        this.sectionPublicFiduciaryRequiredFields = this.requiredLabelSet(this.sectionPublicFiduciaryRequiredFields);
                        this.sectionPublicShareholdersRequiredFields = this.requiredLabelSet(this.sectionPublicShareholdersRequiredFields);
                        this.sectionPublicDefenseRequiredFields = this.requiredLabelSet(this.sectionPublicDefenseRequiredFields);
                        let sectionPublicRequiredFields = this.sectionPublicTransactionRequiredFields
                            .concat(this.sectionPublicFiduciaryRequiredFields)
                            .concat(this.sectionPublicShareholdersRequiredFields)
                            .concat(this.sectionPublicDefenseRequiredFields);
                        this.requiredSectionsCheck('public',sectionPublicRequiredFields,fieldsStatus);
                    }
                    else {
                        this.sectionPublicRequiredDisabled = true;
                        this.sectionPublicRequiredSubject = 'Please review';
                    }
                } 
                else {
                    this.sectionPublicRequiredSubject = 'Please review';
                }
                this.sectionPriceDetailRequiredFields = this.requiredLabelSet(this.sectionPriceDetailRequiredFields);
                this.sectionPriceEarnoutRequiredFields = this.requiredLabelSet(this.sectionPriceEarnoutRequiredFields);
                this.sectionPricePurchaseRequiredFields = this.requiredLabelSet(this.sectionPricePurchaseRequiredFields);
                this.sectionPriceClosingRequiredFields = this.requiredLabelSet(this.sectionPriceClosingRequiredFields);
                this.sectionPriceSellerNotesRequiredFields = this.requiredLabelSet(this.sectionPriceSellerNotesRequiredFields);
                let sectionPriceRequiredFields = this.sectionPriceDetailRequiredFields
                    .concat(this.sectionPriceEarnoutRequiredFields)
                    .concat(this.sectionPricePurchaseRequiredFields)
                    .concat(this.sectionPriceClosingRequiredFields)
                    .concat(this.sectionPriceSellerNotesRequiredFields);
                this.requiredSectionsCheck('price',sectionPriceRequiredFields,fieldsStatus);
                this.sectionKeyContractCarveout2RequiredFields = this.requiredLabelSet(this.sectionKeyContractCarveout2RequiredFields);
                this.sectionKeyContractCarveout1RequiredFields = this.requiredLabelSet(this.sectionKeyContractCarveout1RequiredFields);
                this.sectionKeyContractEscrowRequiredFields = this.requiredLabelSet(this.sectionKeyContractEscrowRequiredFields);
                this.sectionKeyContractCapsRequiredFields = this.requiredLabelSet(this.sectionKeyContractCapsRequiredFields);
                this.sectionKeyContractBasketRequiredFields = this.requiredLabelSet(this.sectionKeyContractBasketRequiredFields);
                this.sectionKeyContractRepWarrantyRequiredFields  = this.requiredLabelSet(this.sectionKeyContractRepWarrantyRequiredFields);
                let sectionKeyContractRequiredFields = this.sectionKeyContractRepWarrantyRequiredFields
                    .concat(this.sectionKeyContractBasketRequiredFields)
                    .concat(this.sectionKeyContractCapsRequiredFields)
                    .concat(this.sectionKeyContractEscrowRequiredFields)
                    .concat(this.sectionKeyContractCarveout1RequiredFields)
                    .concat(this.sectionKeyContractCarveout2RequiredFields);
                this.requiredSectionsCheck('keyContract',sectionKeyContractRequiredFields,fieldsStatus);
                this.sectionEmployeePreTrxRequiredFields = this.requiredLabelSet(this.sectionEmployeePreTrxRequiredFields);
                this.sectionEmployeePostTrxRequiredFields = this.requiredLabelSet(this.sectionEmployeePostTrxRequiredFields);
                let sectionEmployeeRequiredFields = this.sectionEmployeePreTrxRequiredFields
                    .concat(this.sectionEmployeePostTrxRequiredFields);
                this.requiredSectionsCheck('employee',sectionEmployeeRequiredFields,fieldsStatus);
                this.sectionCapDetailsRequiredSubject = 'Please review';
                this.sectionDynamicsRequiredSubject = 'Please review';
                this.sectionTimelineRequiredSubject = 'Please review';
            }
            else if(result.error) {
                console.log('engageSumRecord-result.error','==>',result.error);
                this.engageSumStageData = undefined;
                this.engageSumStageError = 'There was a problem: ' + JSON.stringify(result.error) + ' (hlEngageSumCfContent.engageSumStage)';
            }
            this.spinner = false;
        }
    }
    requiredLabelSet(requiredFields){
        let requiredFieldsLabels = requiredFields;
        for (let i = 0; i < requiredFieldsLabels.length; i++) {
            requiredFieldsLabels[i].label = this.engageSumFields[requiredFieldsLabels[i].fieldApiName].label;
            if(requiredFieldsLabels[i].dependantFields){
                for (let j = 0; j < requiredFieldsLabels[i].dependantFields.length; j++) {
                    requiredFieldsLabels[i].dependantFields[j].label = this.engageSumFields[requiredFieldsLabels[i].dependantFields[j].fieldApiName].label;
                }

            }
        }
        // //console.log('requiredFields-requiredFieldsLabels','==>',requiredFieldsLabels);
        return requiredFieldsLabels;
    }
    requiredSectionsCheck(section,requiredFields,fieldsStatus){
        // console.log('requiredSectionsCheck-section','==>',section);
        let fieldsCheck = [];
        let validChecked = true; 
        for (let i = 0; i < requiredFields.length; i++) {
            // console.log('requiredFieldsCheck-requiredFields[i]','==>',requiredFields[i].apiName);
            let requiredField = requiredFields[i];
            let fieldPassive = requiredFields[i].passive;
            let fieldStatus = fieldsStatus[requiredField.fieldApiName];
            if(fieldStatus){
                let fieldStatusValue = fieldStatus.value;
                let fieldStatusTruthy = false;
                if(typeof fieldStatusValue === 'string') fieldStatusTruthy = fieldStatusValue;
                else if(typeof fieldStatusValue === 'number'){
                    if(fieldStatusValue >= 0) fieldStatusTruthy = true;
                }
                else if(typeof fieldStatusValue === 'boolean') fieldStatusTruthy = fieldStatusValue;
                // console.log('requiredFieldsCheck-fieldStatusValue','==>',fieldStatusValue);
                if(fieldStatusTruthy || fieldPassive){
                    let fieldCheck = {
                        icon: 'utility:check', 
                        iconVariant: 'success', 
                        label: requiredField.label,
                        fieldApiName: requiredField.fieldApiName,
                        value: fieldStatusValue
                    }
                    if(requiredField.dependantFields){
                        // console.log('requiredFieldsCheck-requiredField.dependantFields','==>',requiredField.dependantFields);
                        let dependantFieldsCheck = [];
                        for (let j= 0; j < requiredField.dependantFields.length; j++) {
                            let dependantField = requiredField.dependantFields[j];
                            let dependantFieldStatus = fieldsStatus[dependantField.fieldApiName];
                            if(dependantFieldStatus){
                                let parentFieldStatusTruthy = false;
                                if(typeof fieldStatusValue === 'string'){
                                    if(fieldStatusValue.toLowerCase() === 'yes') parentFieldStatusTruthy = true;
                                } 
                                else if(typeof fieldStatusValue === 'number'){
                                    if(fieldStatusValue > 0) parentFieldStatusTruthy = true;
                                }
                                else if(typeof fieldStatusValue === 'boolean') {
                                    if(fieldStatusValue === true) parentFieldStatusTruthy = true;
                                }
                                // console.log('requiredFieldsCheck-dependantFieldStatus','==>',dependantFieldStatus);
                                let dependantFieldStatusValue = dependantFieldStatus.value;
                                if(parentFieldStatusTruthy  && dependantFieldStatusValue){
                                    dependantFieldsCheck
                                        .push({ 
                                            icon: 'utility:check', 
                                            iconVariant: 'success', 
                                            label: dependantField.label,
                                            fieldApiName: dependantField.fieldApiName,
                                            value: dependantFieldStatusValue
                                        });
                                }
                                else if(parentFieldStatusTruthy && !dependantFieldStatusValue){
                                    dependantFieldsCheck
                                        .push({ 
                                            icon: 'utility:topic', 
                                            iconVariant: 'error', 
                                            label: dependantField.label,
                                            fieldApiName: dependantField.fieldApiName,
                                            value: dependantFieldStatusValue
                                        });
                                    validChecked = false;
                                }
                                else if(!parentFieldStatusTruthy){
                                    dependantFieldsCheck
                                        .push({ 
                                            icon: 'utility:dash', 
                                            iconVariant: 'base', 
                                            label: dependantField.label + ' - Not required',
                                            fieldApiName: dependantField.fieldApiName,
                                            value: dependantFieldStatusValue
                                        });
                                }
                            }
                            else {
                                dependantFieldsCheck
                                    .push({ 
                                        icon: 'utility:question_mark', 
                                        iconVariant: 'error', 
                                        label: dependantField.label + ' - Not found',
                                        fieldApiName: dependantField.fieldApiName,
                                        value: ''
                                    });
                                validChecked = false;
                            }
                        }
                        fieldCheck.dependantChecks = dependantFieldsCheck;
                        // //console.log('requiredFieldsCheck-dependantFieldsCheck','==>',dependantFieldsCheck);
                    }
                    fieldsCheck.push(fieldCheck);
                }
                else {
                    validChecked = false;
                    fieldsCheck 
                        .push({ 
                            icon: 'utility:topic', 
                            iconVariant: 'error', 
                            label: requiredField.label,
                            fieldApiName: requiredField.fieldApiName,
                            value: null
                        });
                }
            }
            else {
                validChecked = false;
                fieldsCheck
                    .push({ 
                        icon: 'utility:question_mark', 
                        iconVariant: 'error', 
                        label: requiredField.label + '- not found',
                        fieldApiName: requiredField.fieldApiName,
                        value: null
                    });
            }
        }
        // //console.log('requiredFieldsCheck-fieldsCheck','==>',fieldsCheck);
        let checkedStatus = {section: section, valid: validChecked, data: fieldsCheck};
        this.requiredSectionResult({ detail: checkedStatus });
    }
    requiredSectionResult(event){
        // console.log('requiredSectionResult','==>',JSON.stringify(event.detail));
        let checkedStatus = event.detail;
        let section = checkedStatus.section;
        let sectionProp = 'section' + section.substring(0,1).toUpperCase() + section.substring(1,section.length);
        if(checkedStatus.valid){
            this[sectionProp+'RequiredIcon'] = 'utility:success';
            this[sectionProp+'RequiredVariant'] = 'success';
            this[sectionProp+'RequiredSubject'] = 'All required information present';
        }
        else{
            this[sectionProp+'RequiredIcon'] = 'utility:topic';
            this[sectionProp+'RequiredVariant'] = 'error';
            this[sectionProp+'RequiredSubject'] = 'Missing information';
        }
        this[sectionProp+'RequiredFieldsStatus'] = checkedStatus.data;
        // //console.log('requiredSectionResult-section','==>',section);
        // //console.log('requiredSectionResult-valid','==>',checkedStatus.valid);
        let index = this.sectionsValidChecker.findIndex(s => s.prop === sectionProp);
        // //console.log('requiredSectionResult-sectionsValidChecker','==>',this.sectionsValidChecker);
        // //console.log('requiredSectionResult-index','==>',index);
        if(index !== -1) this.sectionsValidChecker[index].valid = checkedStatus.valid;
        else this.sectionsValidChecker.push({prop: sectionProp, valid: checkedStatus.valid});
    }
    engageSumStageChange(event){
        console.log('engageSumStageChange','==>',JSON.stringify(event.detail));
        //console.log('engageSumStageChange','==>',JSON.stringify(this.sectionsValidChecker));
        let sectionsAllValid = true;
        if(this.sectionsValidChecker.find(section => section.valid === false)) sectionsAllValid = false;
        let changeDetail = {
            action: event.detail.action,
            value: event.detail.value,
            valid: sectionsAllValid
        }
        this.dispatchEvent(new CustomEvent('stagechange', { detail: changeDetail}));
    }
    @api
    engageSumStageRefresh(stage){
        //console.log('engageSumStageRefresh','==>',stage);
        this.template.querySelector('c-hl-universal-path').stageRefresh(stage);
    }
    sectionPartyRefresh(){
        console.log('sectionpartyrefresh');
        return refreshApex(this.engageSumRecordResult);
    }
    engageSumGenUpdate(){
        console.log('engageSumGenUpdate');
        this.dispatchEvent(new CustomEvent('engagesumgenupdate'));
    }
}
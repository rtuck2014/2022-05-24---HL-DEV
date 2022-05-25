import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getDebtStructures from '@salesforce/apex/hlEngageSumAppController.getDebtStructures';
import ENGAGESUM_NOFACILITY_FIELD from '@salesforce/schema/Engagement_Summary__c.No_Credit_Facility_Data__c';

export default class HlEngageSumCfCredit extends LightningElement {
    @api engagementId;
    @api engageSumId;
    @api recTypeBuyside;
    @api recTypeSellside;
    @api recTypeOtherside;
    @api debtStructureResult;
    engageSumNoFacilityField = [
        ENGAGESUM_NOFACILITY_FIELD
    ];
    engageSumNoFacilityFieldRequired = [
        {objectApiName: 'Engagement_Summary__c', label: 'No Credit Facility Data', fieldApiName:'No_Credit_Facility_Data__c'}
    ];
    @track debtStructures;
    @track debtStructuresError;
    @track debtStructuresSortField = 'CreatedDate';
    @track debtStructuresSortDirection = 'asc';
    @track debtStructureNewFlag;
    @track debtStructureLenderNewFlag;
    requiredFieldsChecker = [];
    @wire(getDebtStructures, { engagementId: '$engagementId', sortField: '$debtStructuresSortField', sortDirection: '$debtStructuresSortDirection'})
    engageDebt(result){
        // console.log('engageDebt-engagementId','==>',this.engagementId);
        // console.log('engageDebt-result','==>',result);
        this.debtStructureResult = result;
        if(result){
            if(result.data){
                if(result.data.length > 0){
                    this.debtStructures = result.data;
                    this.debtStructuresError = undefined;
                    this.requiredSectionResult({detail: {valid: true}});
                } else if (result.data.length === 0){
                    this.debtStructures = undefined;
                    this.debtStructuresError = 'Credit Facilities not found. If accurate, check "No Credit Faciilty Data" below.';
                }
            } 
            else if(result.error) {
                this.debtStructures = undefined;
                this.debtStructuresError = 'There was a problem: ' + JSON.stringify(result.error) + ' (hlEngageSumCfCredit.engageDebt)';
            }
        }
    }
    engageDebtSort(event) {
        this.debtStructuresSortField = event.detail.fieldName; 
        this.debtStructuresSortDirection = event.detail.sortDirection; 
    }
    refreshDebtStructures(){
        return refreshApex(this.debtStructureResult);
    }

    requiredSectionResult(event){
        console.log('credit-requiredSectionResult','==>',JSON.stringify(event.detail));
        let checkedStatus = event.detail;
        // console.log('credit-requiredSectionResult-checkedStatus','==>',JSON.stringify(checkedStatus.data));
        checkedStatus.section = 'credit';
        let checked;
        let allRequiredFields = this.engageSumNoFacilityFieldRequired;
        if(checkedStatus.valid && this.debtStructures) {
            checked = {
                section: 'credit',
                valid: checkedStatus.valid, 
                data: { "Credit Facilities" : this.debtStructures.length}
            }
        }
        else {
            for(let i = 0; checkedStatus.data.length > i; i++){
                let checkedField = checkedStatus.data[i];
                let fieldIndex =  this.requiredFieldsChecker.findIndex(field => field.fieldApiName === checkedField.fieldApiName);
                console.log('credit-requiredSectionResult-checkedField.label','==>',checkedField.label);
                console.log('credit-requiredSectionResult-fieldIndex','==>',fieldIndex);
                if(fieldIndex === -1) this.requiredFieldsChecker.push(checkedField);
                else this.requiredFieldsChecker[fieldIndex] = checkedField;
            }
            console.log('credit-requiredSectionResult-requiredFieldsChecker.length','==>',this.requiredFieldsChecker.length);
            if(this.requiredFieldsChecker.length === allRequiredFields.length){
                let valid;
                if(this.requiredFieldsChecker.find(field => field.iconVariant === 'error')) valid = false;
                else valid = true;
                checked = {
                    section: 'credit',
                    valid: valid, 
                    data: this.requiredFieldsChecker
                }
            }
            else {
                checked = {
                    section: 'credit',
                    valid: false, 
                    data: this.requiredFieldsChecker
                }
            }
        }
        this.dispatchEvent(new CustomEvent('requiredsectionresult', {detail: checked}));
    }

}
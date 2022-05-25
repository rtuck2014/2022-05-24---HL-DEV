import { LightningElement, api, track, wire } from 'lwc';
import getCounterpartyBidList from '@salesforce/apex/hlEngageSumAppController.getCounterpartyBidList';

export default class HlEngageSumCfMarket extends LightningElement {
    @api engagementId;
    @api engageSumId;
    @api jobTypeBuyside;
    @api jobTypeSellside;
    @api jobTypeNoside;
    @track engaegSumMarketSpinner = true;
    @track counterpartyBidListResult;
    @track counterpartyBidListData;
    @track counterpartyBidListError;
    @track Pitch_Low_LTM__c;
    @track Pitch_Low_FYE__c;
    @track Pitch_High_LTM__c;
    @track Pitch_High_FYE__c;
    @track Pitch_MP_LTM__c;
    @track Pitch_MP_FYE__c;
    @track Engagement_Letter_Base_LTM__c;
    @track Engagement_Letter_Base_FYE__c;
    engageMarketFormLoad(event){
        console.log('engageMarketFormLoad.detail.records[firstkey]',event.detail.records[this.engageSumId].fields);
        if(event) this.engaegSumMarketSpinner = false;
        let engageSumRecord = event.detail.records[this.engageSumId];
        this.requiredFieldsCheck(event);
        //LL20190906 - STRY0059454 - Disabled per UAT session with BA and business teams, should be re-enabled in follow up effort to fill out more data into Pitch Metrics section
        // this.Pitch_Low_LTM__c = engageSumRecord.fields.Pitch_Low_LTM__c.value ? engageSumRecord.fields.Pitch_Low_LTM__c.value + 'x' : '';
        // this.Pitch_Low_FYE__c = engageSumRecord.fields.Pitch_Low_FYE__c.value ? engageSumRecord.fields.Pitch_Low_FYE__c.value + 'x' : '';
        // this.Pitch_High_LTM__c = engageSumRecord.fields.Pitch_High_LTM__c.value ? engageSumRecord.fields.Pitch_High_LTM__c.value + 'x' : '';
        // this.Pitch_High_FYE__c = engageSumRecord.fields.Pitch_High_FYE__c.value ? engageSumRecord.fields.Pitch_High_FYE__c.value + 'x' : '';
        // this.Pitch_MP_LTM__c = engageSumRecord.fields.Pitch_MP_LTM__c.value ? engageSumRecord.fields.Pitch_MP_LTM__c.value + 'x' : '';
        // this.Pitch_MP_FYE__c = engageSumRecord.fields.Pitch_MP_FYE__c.value ? engageSumRecord.fields.Pitch_MP_FYE__c.value + 'x' : '';
        // this.Engagement_Letter_Base_LTM__c = engageSumRecord.fields.Engagement_Letter_Base_LTM__c.value ? engageSumRecord.fields.Engagement_Letter_Base_LTM__c.value + 'x' : '';
        // this.Engagement_Letter_Base_FYE__c = engageSumRecord.fields.Engagement_Letter_Base_FYE__c.value ? engageSumRecord.fields.Engagement_Letter_Base_FYE__c.value + 'x' : '';
    }
    @wire(getCounterpartyBidList, { engagementId: '$engagementId' })
    counterpartyBidList(result){
        console.log('getCounterpartyBidList','==>',JSON.stringify(result));
        this.counterpartyBidListResult = result;
        this.engaegSumMarketSpinner = false;
        if(result.data){
            if(result.data.length > 0){
                this.counterpartyBidListData = result.data;
                this.counterpartyBidListError = undefined;
            } 
            else if (result.data.length === 0){
                this.counterpartyBidListData = undefined;
                this.counterpartyBidListError = 'Counterparties not found';
            }
        }
        else {
            this.counterpartyBidListData = undefined;
            this.counterpartyBidListError = 'There was a problem: ' + JSON.stringify(result.error) + ' (hlEngageSumCfMarket.counterpartyBidList)';
        }
    }
    requiredFieldsCheck(event){
        console.log('market-requiredFieldsCheck');//,'==>',JSON.stringify(event.detail));
        let checkedStatus = {valid: true, section: 'market'};
        //LL20190813 - Required fields check not needed for Market Section
        //this.dispatchEvent(new CustomEvent('requiredfieldscheck', {detail: checkedStatus}));
    }
    engageSumGenUpdate(){
        this.dispatchEvent(new CustomEvent('engagesumgenupdate'));
    }
}
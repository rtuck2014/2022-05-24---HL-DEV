import { LightningElement, api, track, wire } from 'lwc';
import getApprovalHistory from '@salesforce/apex/hlUniversalApprovalController.getApprovalHistory';
import LOCALE from '@salesforce/i18n/locale';
import TIMEZONE from '@salesforce/i18n/timeZone';
import { refreshApex } from '@salesforce/apex';

const approvalHistoryCols = [
    { label: 'Submission', fieldName: 'Submission', type: 'text', fixedWidth: '50'},
    { label: 'Status', fieldName: 'Status', type: 'text', fixedWidth: '50'},
    { label: 'Date', fieldName: 'StepDate', type: 'date', typeAttributes:{ month: "2-digit", day: "2-digit", year: "2-digit", hour: "2-digit", minute: "2-digit", hour12: "true", timeZone: TIMEZONE, timeZoneName: "short" } },
    { label: 'Assigned To', fieldName: 'OriginalActorName', type: 'text', typeAttributes: { label: { fieldName: 'OriginalActorName' } }},
    { label: 'Actual Approver', fieldName: 'ActorName', type: 'text', typeAttributes: { label: { fieldName: 'ActorName' } } },
    { label: 'Comments', fieldName: 'Comments', type: 'text' }
];

export default class HlUniversalApprovalHistory extends LightningElement {
    @api recordId;
    @track approvalHistoryColumns = approvalHistoryCols;
    @track approvalHistoryResult;
    @track approvalHistoryData;
    @track approvalHistoryError;
    @wire(getApprovalHistory, { objectId: '$recordId'})
    approvalHistory(result){
        // console.log('approvalHistory','==>',JSON.stringify(result));
        this.approvalHistoryResult = result;
        if(result){
            if(result.data){
                // console.log('approvalHistory-result.data:','==>',result.data);
                if(result.data.length >= 1){
                    let treeData = JSON.parse(JSON.stringify(result.data).split('items').join('_children'));
                    // console.log('getEngageSumApprovals-treeData:','==>',treeData);
                    // console.log('getEngageSumApprovals-treeData:','==>',treeData);
                    this.approvalHistoryData = treeData;
                    this.approvalHistoryError = undefined;
                } 
                else if(result.data.length === 0) {
                    this.engageSumApprovalData = undefined;
                    this.approvalHistoryError = 'Approval history not found, set Stage to "In Review" to submit for approval.';
                }
            }
            else if(result.error) {
                this.approvalHistoryData = undefined;
                this.approvalHistoryError = 'There was a problem: (hlEngageSumCfParties.getEngagementSummary): ' + JSON.stringify(result.error);
            }
        }
    }
    @api
    approvalHistoryRefresh(){
        refreshApex(this.approvalHistoryResult);
    }
}
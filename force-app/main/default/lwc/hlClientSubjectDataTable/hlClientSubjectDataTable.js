import {
	LightningElement,
	track,
	api
} from 'lwc';
import {
	ShowToastEvent
} from 'lightning/platformShowToastEvent';
import getRecordsToDisplayInTable from '@salesforce/apex/hlDataTableController.getRecordsToDisplayInTable';
import updateRecordsToDisplayInTable from '@salesforce/apex/hlDataTableController.updateRecordsToDisplayInTable';
import saveRecordsToDisplayInTable from '@salesforce/apex/hlDataTableController.saveRecordsToDisplayInTable';
import getTotalAllocationValue from '@salesforce/apex/hlDataTableController.getTotalAllocationValue';
import updatelookupToDisplayInTable from '@salesforce/apex/hlDataTableController.updatelookupToDisplayInTable';
import pickListValueDynamically from '@salesforce/apex/hlDataTableController.pickListValueDynamically';

export default class HlClientSubjectDataTable extends LightningElement {
	@track isEdited = false;
	@track toggleSaveLabel = 'Save';
	@track recordList;
	@track columnsForTable = [];
	@track err
	@api parentRecordId;
	@api objName;
	@api jobType;
	errorMsg;
	@api fieldetName;
	@api whereClause;
	@track selectedRecords;
	@track recIds = new Set();
	@track recordDetail;
	@track isSpinner = false;
	@track recordDetailTotal;
	@track picklistVal;
	selectTargetValues;
	isErr;
	isuccess = false;
	successMsg;
	isAllSelected=true;
	@track helpTextCheckBox = 'Please check this box only if you need to delete multiple records';
	@track recordDetailNull = true;
	selectOptionChangeValue(event) {
		this.pickValue = event.detail.value;
		console.log(JSON.stringify(event.detail));
		if (objName === 'Engagement_Client_Subject__c')
			this.whereClause = 'Engagement__c = \'' + this.parentRecordId + '\' AND Type__c = \'' + pickValue + '\' ORDER BY Client_Subject__r.Name LIMIT 1000';
		else
			this.whereClause = 'Opportunity__c = \'' + this.parentRecordId + '\' AND Type__c = \'' + pickValue + '\' ORDER BY Client_Subject__r.Name LIMIT 1000';
		this.getRecords();
		//this.getTotalAllocationVal();
		//console.log('handlePicklistChangesort-- '+pickValue);
	}
	handleSelection(event) {
		let eventData = event.detail;
		let id = event.detail.selectedId;
		let uniqueKey = event.detail.key;
		let objN = event.detail.objN;
		console.log('eventData-- ' + JSON.stringify(eventData));
		let element = this.recordDetail.find(ele => ele.RecordId === uniqueKey);
		console.log('Recorddetail:' + JSON.stringify(this.recordDetail));
		updatelookupToDisplayInTable({
				recordDetail: this.recordDetail,
				recordId: event.detail.key,
				objN: event.detail.objN,
				newVal: event.detail.selectedId
			})
			.then(result => {
				console.log('updatelookupToDisplayInTable-- ' + JSON.stringify(result));
				this.recordDetail = result;
				this.error = undefined;
			})
			.catch(error => {
				this.error = error;
			});
	}
	handlePicklistChange(event) {
		let eventData = event.detail;
		let pickValue = event.detail.selectedValue;
		let uniqueKey = event.detail.key;
		console.log('pickValue-- ' + uniqueKey);
		updateRecordsToDisplayInTable({
				recordDetail: this.recordDetail,
				recordId: uniqueKey,
				fieldApiName: event.detail.fieldApiName,
				newVal: pickValue
			})
			.then(result => {
				console.log('result-- ' + JSON.stringify(result));
				this.recordDetail = result;
				this.error = undefined;
			})
			.catch(error => {
				this.error = error;
			});

	}
	handlePicklistChangesort(event) {
		let eventData = event.detail;
		let pickValue = event.detail.value;
		let pickValueQuery;
		this.isAllSelected=false;
		if(pickValue==='All'){
			this.isAllSelected=true;
			this.isEdited=false;
		}
		if (pickValue === 'Key Creditor' && this.jobType === 'Creditor Advisors') {
			if (this.objName === 'Engagement_Client_Subject__c')
				pickValueQuery = ' Type__c =\'Key Creditor\' AND Engagement__r.Job_Type__c = \'Creditor Advisors\' ';
			else
				pickValueQuery = ' Type__c = \'Key Creditor\' AND Opportunity__r.Job_Type__c = \'Creditor Advisors\' ';
		} 
		/*else if (pickValue === 'Fee Attribution Party') {
			if (this.objName === 'Engagement_Client_Subject__c')
				pickValueQuery = ' Type__c = \'Fee Attribution Party\'  ';
			else
				pickValueQuery = ' Type__c =\'Fee Attribution Party\'  ';
		}*/
		 else {
			pickValueQuery = ' Type__c = \'' + pickValue + '\' ';
		}

		let uniqueKey = event.detail.key;
		console.log('this.parentRecordId::' + this.parentRecordId);
		if (this.objName === 'Engagement_Client_Subject__c') {
			this.whereClause = 'Engagement__c = \'' + this.parentRecordId + '\' AND ' + pickValueQuery + ' ORDER BY Client_Subject__r.Name LIMIT 1000';
			if (pickValue === 'Subject') {
				this.fieldetName = 'EngagementClientFiedsetSubject';
			} else if (pickValue === 'Other') {
				this.fieldetName = 'EngagementClientFiedsetOther';
			} else if (pickValue === 'Contra') {
				this.fieldetName = 'EngagementClientFiedsetContra';
			} else if (pickValue === 'Counterparty') {
				this.fieldetName = 'EngagementClientFiedsetCounterparty';
			} else if (pickValue === 'Client') {
				this.fieldetName = 'EngagementClientFiedsetClient';
			} else if (pickValue === 'Key Creditor') {
				this.fieldetName = 'EngagementClientFiedsetKeyCreditor';
			} else if (pickValue === 'Equity Holder') {
				this.fieldetName = 'EngagementClientFiedsetEquityHolder';
			} else if (pickValue === 'PE Firm') {
				this.fieldetName = 'EngagementClientFiedsetPEFirm';
			} else if (pickValue === 'All') {
				this.whereClause = 'Engagement__c = \'' + this.parentRecordId + '\' ORDER BY Client_Subject__r.Name LIMIT 1000';
				this.fieldetName = 'EngagementClientFiedset';
			}
		} else {
			this.whereClause = 'Opportunity__c = \'' + this.parentRecordId + '\' AND ' + pickValueQuery + ' ORDER BY Client_Subject__r.Name LIMIT 1000';
			if (pickValue === 'Client') {
				this.fieldetName = 'OpportunityClientSubjectFieldSetClient';
			} else if (pickValue === 'Contra') {
				this.fieldetName = 'OpportunityClientSubjectFieldSetContra';
			} else if (pickValue === 'Key Creditor') {
				this.fieldetName = 'OpportunityClientSubjectFieldSetKeyCredi';
			} else if (pickValue === 'PE Firm') {
				this.fieldetName = 'OpportunityClientSubjectFieldSetPEFirm';
			} else if (pickValue === 'Subject') {
				this.fieldetName = 'OpportunityClientSubjectFieldSetSubject';
			} else if (pickValue === 'Other') {
				this.fieldetName = 'OpportunityClientSubjectFieldSetOther';
			} else if (pickValue === 'All') {
				this.whereClause = 'Opportunity__c = \'' + this.parentRecordId + '\' ORDER BY Client_Subject__r.Name LIMIT 1000';
				this.fieldetName = 'OpportunityClientSubjectFieldSet';
			}
		}
		getRecordsToDisplayInTable({
				sobject_name: this.objName,
				field_set_name: this.fieldetName,
				where_clause: this.whereClause,
				engId: this.parentRecordId
			})
			.then(result => {
				console.log('result pick chnge-- ' + JSON.stringify(result));
				this.recordList = [];
				this.recordDetail = [];
				this.columnsForTable = result.FieldLabels;
				if (result.tableRows.length > 0) {
					this.recordList = result.tableRows;
					this.recordDetail = result.tableRows;
					this.recordDetailNull = false;
				} else {
					this.recordDetailNull = true;
					this.recordList = undefined;
					this.recordDetail = undefined;
				}
				this.error = undefined;
				this.isSpinner = false;
			})
			.catch(error => {
				this.error = error;
				this.isSpinner = false;
			});
		getTotalAllocationValue({
				sobject_name: this.objName,
				field_set_name: this.fieldetName,
				where_clause: this.whereClause,
				engId: this.parentRecordId
			})
			.then(result => {
				console.log('getTotalAllocationValue-- ' + this.objName);
				console.log('getTotalAllocationValue-- ' + this.fieldetName);
				console.log('getTotalAllocationValue-- ' + this.whereClause);
				this.recordDetailTotal = [];
				console.log('getTotalAllocationValue-- ' + JSON.stringify(result));
				this.recordDetailTotal = result;
				this.error = undefined;
				this.isSpinner = false;
			})
			.catch(error => {
				this.error = error;
			});
		console.log('handlePicklistChangesort-- ' + pickValue);

	}
	connectedCallback() {
		this.getPicklistForFilter();		
		this.getRecords();
		this.getTotalAllocationVal();

	}
	getPicklistForFilter() {
		pickListValueDynamically({
				customObjInfo: {
					'sobjectType': this.objName
				},
				selectPicklistApi: 'Type__c'
			})
			.then(result => {
				console.log('pickListValueDynamically-- ' + JSON.stringify(result));
				this.selectTargetValues = result;
			})
			.catch(error => {
				this.error = error;
			});
	}
	getTotalAllocationVal() {
		getTotalAllocationValue({
				sobject_name: this.objName,
				field_set_name: this.fieldetName,
				where_clause: this.whereClause,
				engId: this.parentRecordId
			})
			.then(result => {
				console.log('getTotalAllocationValue objName-- ' + this.objName);
				console.log('getTotalAllocationValue fieldetName-- ' + this.fieldetName);
				console.log('getTotalAllocationValue whereClause -- ' + this.whereClause);
				this.recordDetailTotal = null;
				console.log('getTotalAllocationValue result-- ' + JSON.stringify(result));
				this.recordDetailTotal = result;
				this.error = undefined;
				this.isSpinner = false;
			})
			.catch(error => {
				this.error = error;
			});
	}
	getRecords() {
		this.isSpinner = true;
		getRecordsToDisplayInTable({
				sobject_name: this.objName,
				field_set_name: this.fieldetName,
				where_clause: this.whereClause,
				engId: this.parentRecordId
			})
			.then(result => {
				console.log('getRecordsToDisplayInTable result-- ' + JSON.stringify(result));
				this.recordList = null;
				this.recordDetail = null;
				this.columnsForTable = result.FieldLabels;
				this.recordList = result.tableRows;
				this.recordDetail = result.tableRows;
				if (this.recordDetail.length > 0) {
					this.recordDetailNull = false;
				}
				this.error = undefined;
				this.isSpinner = false;
			})
			.catch(error => {
				this.error = error;
				this.isSpinner = false;
			});
	}
	onDoubleClickEdit() {
		this.isEdited = true;
		console.log('recordtype--'+this.re);
	}

	handleCancel() {
		this.isEdited = false;
		this.isErr = false;
	}
	handleSave() {
		this.isSpinner = false;
		this.isSpinner = true;
		this.selectedRecords = Array.from(this.recIds);
		console.log('selectedRecords-- ' + JSON.stringify(this.selectedRecords));
		console.log('recordDetail-- ' + JSON.stringify(this.recordDetail));
		saveRecordsToDisplayInTable({
				recordDetail: this.recordDetail,
				sobject_name: this.objName
			})
			.then(result => {
				console.log('result1-- ' + JSON.stringify(result.status));
				console.log('result-- ' + JSON.stringify(result));
				this.recordList = result;
				this.recordDetail = result;
				this.isuccess = true;
				this.successMsg = 'Records updated successful';
				getRecordsToDisplayInTable({
						sobject_name: this.objName,
						field_set_name: this.fieldetName,
						where_clause: this.whereClause,
						engId: this.parentRecordId
					})
					.then(result => {
						console.log('result pick chnge-- ' + JSON.stringify(result));
						this.recordList = [];
						this.recordDetail = [];
						this.columnsForTable = result.FieldLabels;
						if (result.tableRows.length > 0) {
							this.recordList = result.tableRows;
							this.recordDetail = result.tableRows;
							this.recordDetailNull = false;
						} else {
							this.recordDetailNull = true;
							this.recordList = undefined;
							this.recordDetail = undefined;
						}
						this.error = undefined;
						this.isSpinner = false;
					})
					.catch(error => {
						this.error = error;
						this.isSpinner = false;
					});
				getTotalAllocationValue({
						sobject_name: this.objName,
						field_set_name: this.fieldetName,
						where_clause: this.whereClause,
						engId: this.parentRecordId
					})
					.then(result => {
						console.log('getTotalAllocationValue-- ' + this.objName);
						console.log('getTotalAllocationValue-- ' + this.fieldetName);
						console.log('getTotalAllocationValue-- ' + this.whereClause);
						this.recordDetailTotal = [];
						console.log('getTotalAllocationValue-- ' + JSON.stringify(result));
						this.recordDetailTotal = result;
						this.error = undefined;
						this.isSpinner = false;
					})
					.catch(error => {
						this.error = error;
					});


				this.error = undefined;
				this.isEdited = false;
				this.isSpinner = false;
			})
			.catch(error => {
				console.log('result-- ' + JSON.stringify(error));
				console.log('result1-- ' + JSON.stringify(error.status));
				console.log('result2-- ' + JSON.stringify(error.body.message));
				this.error = error;
				this.status = JSON.stringify(error.status);
				let err = error.body.message;
				if (err.includes('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
					err = err.split(',');
					let msg = err[1].split(':');
					this.errorMsg = msg[0];
				} else {
					this.errorMsg = err;
				}
				this.isErr = true;

				this.isSpinner = false;
			});
	}
	refresh() {
		window.location.reload();
	}
	handleErrClose() {
		this.isErr = false;
	}
	handleSuccessClose() {
		this.isuccess = false;
	}
	handleNameChange(event) {
		let element = this.recordDetail.find(ele => ele.RecordId === event.target.dataset.id);
		console.log('event.detail.key;-- ' + event.detail.key);
		console.log('event.detail;-- ' + JSON.stringify(event.detail));
		console.log('element-- ' + JSON.stringify(element));
		console.log('event.target.value- ' + event.target.value);
		console.log('event.target.dataset.id-- ' + event.target.dataset.id);
		console.log('event.target.dataset-- ' + JSON.stringify(event.target.dataset));
		console.log('event.target.key-- ' + JSON.stringify(event.target.dataset.key));
		console.log('element length-- ' + element.length);
		console.log('element.field length-- ' + element.fields.length);
		updateRecordsToDisplayInTable({
				recordDetail: this.recordDetail,
				recordId: event.target.dataset.id,
				fieldApiName: event.target.dataset.key,
				newVal: event.target.value,
				boolVal: event.target.checked
			})
			.then(result => {
				console.log('result-- ' + JSON.stringify(result));
				this.recordDetail = result;
				this.error = undefined;
			})
			.catch(error => {
				this.error = error;
			});

	}
	dataChekChange(event) {
		console.log('check id-- ' + event.target.value);
		console.log('event.target.checked-- ' + event.target.checked);
		this.recIds.add(event.target.value);
		let selectedId = event.target.value;
		let checked = event.target.checked;
		const valueSelectedEventP = new CustomEvent('valueselectparent', {
			detail: {
				selectedId,
				checked
			}
		});
		this.dispatchEvent(valueSelectedEventP);
		//console.log('recordList-- '+JSON.stringify(this.recordList));
	}
	
	@api handleValueChange() {
		//this.isSpinner = true;
		this.isuccess = true;
		this.successMsg = 'Records Deleted successful';
		setTimeout(function(){ window.location.reload();
        },2000)
	}
}
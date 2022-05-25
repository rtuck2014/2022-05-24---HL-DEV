import { LightningElement, api, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getEngageContacts from '@salesforce/apex/hlEngageSumAppController.getEngageContacts';
import ENGAGESUM_PRE_HADINCENT_FIELD from '@salesforce/schema/Engagement_Summary__c.Seller_Had_Incentive_Plan__c';
import ENGAGESUM_PRE_INCENTPLAN_FIELD from '@salesforce/schema/Engagement_Summary__c.Incentive_Plan__c';
import ENGAGESUM_PRE_EMPINCENTCOUNT_FIELD from '@salesforce/schema/Engagement_Summary__c.Employees_In_Incentive_Plan__c';
import ENGAGECON_CONTACT_FIELD from '@salesforce/schema/Engagement_External_Team__c.Contact__c';
import ENGAGECON_CONTACTCOMPANY_FIELD from '@salesforce/schema/Engagement_External_Team__c.Contact_Company__c';
import ENGAGECON_PRE_TITLE_FIELD from '@salesforce/schema/Engagement_External_Team__c.Pre_Transaction_Title__c';
import ENGAGECON_PRE_SALARY_FIELD from '@salesforce/schema/Engagement_External_Team__c.Pre_Transaction_Salary__c';
import ENGAGECON_PRE_BONUS_FIELD from '@salesforce/schema/Engagement_External_Team__c.Pre_Transaction_Bonus__c';
import ENGAGECON_PRE_COMP_FIELD from '@salesforce/schema/Engagement_External_Team__c.Pre_Transaction_Total_Comp__c';
import ENGAGECON_PRE_LENGTH_FIELD from '@salesforce/schema/Engagement_External_Team__c.Pre_Transaction_Employment_Length__c';
import ENGAGECON_PRE_OWNERSHIP_FIELD from '@salesforce/schema/Engagement_External_Team__c.Pre_Transaction_Equity_Ownership__c';
import ENGAGECON_PRE_EQUITY_FIELD from '@salesforce/schema/Engagement_External_Team__c.Equity_From_Transaction__c';
import ENGAGECON_PRE_INCENT_FIELD from '@salesforce/schema/Engagement_External_Team__c.Transaction_Incentives_At_Close__c';
import ENGAGECON_PRE_PROCEEDS_FIELD from '@salesforce/schema/Engagement_External_Team__c.Total_Proceeds_At_Close__c';
import ENGAGESUM_POST_EMPAGREE_FIELD from '@salesforce/schema/Engagement_Summary__c.Required_New_Employment_Agreements__c';
import ENGAGESUM_POST_ROLLEQ_FIELD from '@salesforce/schema/Engagement_Summary__c.Required_Rollover_Equity__c';
import ENGAGESUM_POST_OPTPOOL_FIELD from '@salesforce/schema/Engagement_Summary__c.Implemented_New_Option_Pool_Equity_Plan__c';
import ENGAGESUM_POST_POOLPERC_FIELD from '@salesforce/schema/Engagement_Summary__c.Total_Pool_Percent_Of_Equity__c';
import ENGAGESUM_POST_PREFEQ_FIELD from '@salesforce/schema/Engagement_Summary__c.Is_Preferred_Equity__c';
import ENGAGESUM_POST_EMPOPTPLAN_FIELD from '@salesforce/schema/Engagement_Summary__c.Employees_In_Option_Plan__c';
import ENGAGECON_POST_TITLE_FIELD from '@salesforce/schema/Engagement_External_Team__c.Post_Transaction_Title__c';
import ENGAGECON_POST_SALARY_FIELD from '@salesforce/schema/Engagement_External_Team__c.Post_Transaction_Salary__c';
import ENGAGECON_POST_BONUS_FIELD from '@salesforce/schema/Engagement_External_Team__c.Post_Transaction_Bonus__c';
import ENGAGECON_POST_COMP_FIELD from '@salesforce/schema/Engagement_External_Team__c.Post_Transaction_Total_Comp__c';
import ENGAGECON_POST_AGREEM_FIELD from '@salesforce/schema/Engagement_External_Team__c.Post_Transaction_Employment_Agreement__c';
import ENGAGECON_POST_ROLL_FIELD from '@salesforce/schema/Engagement_External_Team__c.Post_Transaction_Rollover_Required__c';
import ENGAGECON_POST_EQUITY_FIELD from '@salesforce/schema/Engagement_External_Team__c.Post_Transaction_New_Equity_Ownership__c';
import ENGAGECON_POST_OPTIONS_FIELD from '@salesforce/schema/Engagement_External_Team__c.Post_Transaction_Options_Percent__c';
import ENGAGECON_POST_VESTED_FIELD from '@salesforce/schema/Engagement_External_Team__c.Post_Transaction_Options_Vested_On__c';
const viewDelRowActions = [
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' }
];
const engageContactsSellerPreCols = [
    { label: 'Name', fieldName: 'Contact_URL__c', type: 'url', typeAttributes: { label: { fieldName: 'Contact_Name__c' } }, sortable: true},
    { label: 'Role', fieldName: 'Role__c', type: 'text', sortable: true, editable: false },
    { label: 'Company', fieldName: 'Contact_Company__c', type: 'text', sortable: true },
    { label: 'Pre-Title', fieldName: 'Pre_Transaction_Title__c', type: 'text', sortable: true, editable: true },
    { type: 'action', typeAttributes: { rowActions: viewDelRowActions }}
];
const engageContactsSellerPostCols = [
    { label: 'Name', fieldName: 'Contact_URL__c', type: 'url', typeAttributes: { label: { fieldName: 'Contact_Name__c' } }, sortable: true},
    { label: 'Role', fieldName: 'Role__c', type: 'text', sortable: true, editable: false },
    { label: 'Company', fieldName: 'Contact_Company__c', type: 'text', sortable: true },
    { label: 'Post-Title', fieldName: 'Post_Transaction_Title__c', type: 'text', sortable: true, editable: true },
    { type: 'action', typeAttributes: { rowActions: viewDelRowActions }}
];
export default class HlEngageSumCfEmployee extends LightningElement {
    @api engagementId;
    @api engageSumId;
    @api jobTypeBuyside;
    @api jobTypeSellside;
    @api jobTypeNoside;
    @api requiredFieldsEmployeePreTrx;
    @api requiredFieldsEmployeePostTrx;
    engageSumPreFields = [
        ENGAGESUM_PRE_HADINCENT_FIELD,
        ENGAGESUM_PRE_INCENTPLAN_FIELD,
        ENGAGESUM_PRE_EMPINCENTCOUNT_FIELD
    ];
    engageSumPostFields = [
        ENGAGESUM_POST_EMPAGREE_FIELD,
        ENGAGESUM_POST_ROLLEQ_FIELD,
        ENGAGESUM_POST_OPTPOOL_FIELD,
        ENGAGESUM_POST_POOLPERC_FIELD,
        ENGAGESUM_POST_PREFEQ_FIELD,
        ENGAGESUM_POST_EMPOPTPLAN_FIELD
    ];
    engageContactsSellerPreTableFormFields = [
        ENGAGECON_CONTACT_FIELD,ENGAGECON_CONTACTCOMPANY_FIELD,
        ENGAGECON_PRE_TITLE_FIELD,ENGAGECON_PRE_LENGTH_FIELD,
        ENGAGECON_PRE_INCENT_FIELD,ENGAGECON_PRE_SALARY_FIELD,
        ENGAGECON_PRE_OWNERSHIP_FIELD,ENGAGECON_PRE_BONUS_FIELD,
        ENGAGECON_PRE_EQUITY_FIELD,ENGAGECON_PRE_COMP_FIELD,
        ENGAGECON_PRE_PROCEEDS_FIELD
    ];
    engageContactsSellerPostTableFormFields = [
        ENGAGECON_CONTACT_FIELD,ENGAGECON_CONTACTCOMPANY_FIELD,
        ENGAGECON_POST_TITLE_FIELD,ENGAGECON_POST_AGREEM_FIELD,
        ENGAGECON_POST_ROLL_FIELD,ENGAGECON_POST_SALARY_FIELD,
        ENGAGECON_POST_OPTIONS_FIELD,ENGAGECON_POST_BONUS_FIELD,
        ENGAGECON_POST_EQUITY_FIELD,ENGAGECON_POST_COMP_FIELD,
        ENGAGECON_POST_OPTIONS_FIELD,ENGAGECON_POST_EQUITY_FIELD,
        ENGAGECON_POST_VESTED_FIELD
    ];
    @track engageContactsSellerPreColumns = engageContactsSellerPreCols;
    @track engageContactsSellerPostColumns = engageContactsSellerPostCols;
    @api engageContactsSellerPreResult;
    @track engageContactsSellerPreData;
    @track engageContactsSellerPreError;
    @api engageContactsSellerPostResult;
    @track engageContactsSellerPostData;
    @track engageContactsSellerPostError;
    @track engageContactsSellerSortField = 'Name_Link__c';
    @track engageContactsSellerSortDirection = 'asc';
    @track engageContactRecTypeId;
    @track engageContactRecTypeError;
    @wire(getEngageContacts, { engagementId: '$engagementId', partyFilter: 'Seller', roleExcludeFilters: [], roleFilters: ['Company Contact'], sortField: '$engageContactsSellerSortField', sortDirection: '$engageContactsSellerSortDirection' })
    engageContactsSellerPre(result){
        // console.log('engageContactsSeller','==>',JSON.stringify(result));
        this.engageContactsSellerPreResult = result;
        if(result.data){
            if(result.data.length > 0){
                this.engageContactsSellerPreData = result.data;
                this.engageContactsSellerPreError = undefined;
            } 
            else if (result.data.length === 0){
                this.engageContactsSellerPreData = undefined;
                this.engageContactsSellerPreError = 'Engagement Seller Contacts not found';
            }
        } 
        else {
            this.engageContactsSellerPreData = undefined;
            this.engageContactsSellerPreError = 'There was a problem: ' + JSON.stringify(result.error) + ' (hlEngageSumCfEmployee.engageContactsSellerPre)';
        }
    }
    @wire(getEngageContacts, { engagementId: '$engagementId', partyFilter: 'Seller', roleExcludeFilters: [], roleFilters: ['Company Contact'], sortField: '$engageContactsSellerSortField', sortDirection: '$engageContactsSellerSortDirection' })
    engageContactsSellerPost(result){
        // console.log('engageContactsSeller','==>',JSON.stringify(result));
        this.engageContactsSellerPostResult = result;
        if(result.data){
            if(result.data.length > 0){
                this.engageContactsSellerPostData = result.data;
                this.engageContactsSellerPostError = undefined;
            } 
            else if (result.data.length === 0){
                this.engageContactsSellerPostData = undefined;
                this.engageContactsSellerPostError = 'Engagement Seller Contacts not found';
            }
        } 
        else {
            this.engageContactsSellerPostData = undefined;
            this.engageContactsSellerPostError = 'There was a problem: ' + JSON.stringify(result.error) + ' (hlEngageSumCfEmployee.engageContactsSellerPost)';
        }
    }
    engageContactsSellerSort(event){
        // console.log('engageContactsBuyerSort-detail','==>',JSON.stringify(event.detail));
        this.engageContactsSellerSortField = event.detail.fieldName; 
        this.engageContactsSellerSortDirection = event.detail.sortDirection; 
    }
    engageContactsSellerPreRefresh(){
        return refreshApex(this.engageContactsSellerPreResult);
    }
    engageContactsSellerPostRefresh(){
        return refreshApex(this.engageContactsSellerPostResult);
    }

}
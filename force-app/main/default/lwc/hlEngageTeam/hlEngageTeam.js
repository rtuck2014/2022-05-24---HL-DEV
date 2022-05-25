import { LightningElement, api, wire, track } from 'lwc';
import getEngageTeam from '@salesforce/apex/hlEngageSumAppController.getEngageTeam';
const engageTeamColsDefault = [
    { label: 'Roles', fieldName: 'Role__c'},
    { label: 'Name', fieldName: 'Contact_Name__c'},
    { label: 'Title', fieldName: 'Contact_Title__c'},
    { label: 'LOB', fieldName: 'Contact_LOB__c'},
];
export default class HlEngageTeam extends LightningElement {
    @api engagementId;
    @api engageRecord;
    @api engageRecTypeInfo;
    @api typeTable;
    @api typeGrid;
    engageTeamCols = engageTeamColsDefault;
    @track engageTeamResult;
    @track engageTeamData;
    @track engageTeamError;
    @track engageTeamColumns;
    @track engageTeamSortField = 'Role__c';
    @track engageTeamSortDirection = 'desc';
    @wire(getEngageTeam, { engagementId: '$engagementId', sortField: '$engageTeamSortField', sortDirection: '$engageTeamSortDirection', roleFilters: ['Principal','Manager','Associate','Analyst']})
    engageTeam(result){
        // console.log('engageTeam');
        this.engageTeamResult = result;
        if(result){
            if(result.data){
                if(result.data.length > 0){
                    let team = result.data;
                    this.dispatchEvent(new CustomEvent('loadteam', {detail: team}));
                    if(this.typeTable) this.engageTeamData = team;
                    else if(this.typeGrid){
                        let grid = [];
                        for(let i = 0; team.length > i; i++){
                            let item = team[i];
                            // console.log('engageTeam-i-item','==>', item);
                            let index = grid.findIndex(member => member.Contact__c === item.Contact__c);
                            // console.log('engageTeam-i-grid','==>', grid);
                            // console.log('engageTeam-i-index','==>', index);
                            if(index !== -1){
                                let roleCount = 1 + parseInt(grid[index].Role__c); 
                                grid[index].Role__c = String(roleCount);
                                grid[index]._children.push({
                                    Role__c: item.Role__c,
                                    Office__c: item.Office__c
                                });
                            }
                            else {
                                grid.push({
                                    Id: item.Id,
                                    Contact__c: item.Contact__c,
                                    Contact_Name__c: item.Contact_Name__c,
                                    Contact_Title__c: item.Contact_Title__c,
                                    Contact_LOB__c: item.Contact_LOB__c,
                                    Role__c: '1',
                                    _children: [{
                                        Role__c: item.Role__c,
                                        Office__c: item.Office__c
                                    }]
                                });
                            }
                        }
                        // console.log('engageTeam-grid','==>', grid);
                        this.engageTeamData = team;
                    }
                    this.dispatchEvent(new CustomEvent('load', {detail: this.engageTeamData}));
                    this.engageTeamError = undefined;
                }
                else if (result.data.length === 0){
                    this.engageTeamData= undefined;
                    this.engageTeamError = 'No Engagement Team members found.';
                }
            } 
            else if (result.error){
                this.engageTeamError = 'There was a problem: (hlEngageSumCfParties.engageTeam): ' + JSON.stringify(result.error);
                this.engageTeamData= undefined;
            }    
        }
        else {
            this.engageTeamData= undefined;
            this.engageTeamError = 'There was a problem: (hlEngageSumCfParties.engageTeam)';
        }
    }
    engageTeamSort(event) {
        this.engageTeamSortField = event.detail.fieldName; 
        this.engageTeamSortDirection = event.detail.sortDirection; 
    }
}
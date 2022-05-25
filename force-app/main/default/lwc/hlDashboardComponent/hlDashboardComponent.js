import { LightningElement, api } from 'lwc';

export default class HlDashboardComponent extends LightningElement {
    @api dashboard;
    
    renderedCallback(){
     console.log('dashboard>>>'+this.dashboard);
    }

    get backgroundStyle() {
        return `background-image:url(${this.dashboard.imageUrl})`;
    }

    onDivClick(event){
        window.open('/apex/TableauDashboardPage?displayName='+this.dashboard.name+'&sfdc.tabName='+this.dashboard.tabId);
    }
}
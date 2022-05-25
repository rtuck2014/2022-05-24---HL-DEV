import { LightningElement, wire, track } from 'lwc';
import getMyDashboardList from '@salesforce/apex/TableauHomePageDashboardController.getMyDashboardList';

export default class HlHomePageMyDashbooards extends LightningElement {
    displayDashboard;
    @track dashboardlist;
    error;
    
    @wire(getMyDashboardList)
    wiredDashboards({ error, data }) {
        if (data) {
            this.dashboardlist = data;
            if(data.length > 0){
            this.displayDashboard = true;
            }
            this.error = undefined;
        } else if (error) {
            this.error = error;
            console.log('error>>>'+error);
            this.dashboardlist = undefined;
        }
    }
}
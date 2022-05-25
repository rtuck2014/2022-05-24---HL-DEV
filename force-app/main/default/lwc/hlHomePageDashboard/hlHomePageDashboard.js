import { LightningElement, wire } from 'lwc';
import getDashboardList from '@salesforce/apex/TableauHomePageDashboardController.getDashboardList';

export default class HlHomePageDashbooard extends LightningElement {
    displayDashboard;
    dashboardlist;
    error;
    
    @wire(getDashboardList)
    wiredDashboards({ error, data }) {
        if (data) {
            this.dashboardlist = data;
            console.log('data>>>'+JSON.stringify(this.dashboardlist));
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
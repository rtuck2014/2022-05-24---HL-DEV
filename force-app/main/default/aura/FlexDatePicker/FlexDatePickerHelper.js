({
	setWeek : function(component, startDate) {
	  //Get Sunday
	  var d = startDate;
      var day = startDate.getDay();
      var diff = d.getDate() - day;
      var sunday = new Date(d.setDate(diff));
      var monday = new Date(sunday);
      var tuesday = new Date(sunday);
      var wednesday = new Date(sunday);
      var thursday = new Date(sunday);
      var friday = new Date(sunday);
      var saturday = new Date(sunday);  
      monday.setDate(sunday.getDate()+1);
      tuesday.setDate(sunday.getDate()+2);
      wednesday.setDate(sunday.getDate()+3);
      thursday.setDate(sunday.getDate()+4);
      friday.setDate(sunday.getDate()+5);
      saturday.setDate(sunday.getDate()+6);
   	  component.set('v.sunday', sunday.getFullYear() + "-" + (sunday.getMonth() + 1) + "-" + sunday.getDate());
      component.set('v.monday', monday.getFullYear() + "-" + (monday.getMonth() + 1) + "-" + monday.getDate());
      component.set('v.tuesday', tuesday.getFullYear() + "-" + (tuesday.getMonth() + 1) + "-" + tuesday.getDate());
      component.set('v.wednesday', wednesday.getFullYear() + "-" + (wednesday.getMonth() + 1) + "-" + wednesday.getDate());
      component.set('v.thursday', thursday.getFullYear() + "-" + (thursday.getMonth() + 1) + "-" + thursday.getDate());
      component.set('v.friday', friday.getFullYear() + "-" + (friday.getMonth() + 1) + "-" + friday.getDate());
      component.set('v.saturday', saturday.getFullYear() + "-" + (saturday.getMonth() + 1) + "-" + saturday.getDate());
	},
    setSelectedDate : function(component, selectedDate){
        component.set("v.selectedDate",selectedDate.getFullYear() + "-" + (selectedDate.getMonth() + 1) + "-" + selectedDate.getDate());
        var dateSelectionEvent = component.getEvent("dateSelectionEvent");
        dateSelectionEvent.setParams({"selectedDate": selectedDate});
        dateSelectionEvent.fire();
    },
    formatDate : function(dateValue){
        if(typeof(dateValue) === 'string'){
            if(dateValue.indexOf('-'))
                return dateValue.split('-')[1] + '/' + dateValue.split('-')[2] + '/' + dateValue.split('-')[0];
            return dateValue;
        }
        return dateValue;
    }
})
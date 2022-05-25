({
        search : function(component, event, helper) {
            helper.searchLocation(component, event, helper);
        },        
        searchEvents: function(component, event, helper) {
          if(event.getParams().keyCode == 13){
                helper.searchLocation(component, event, helper);
            }
       }    
      
    })
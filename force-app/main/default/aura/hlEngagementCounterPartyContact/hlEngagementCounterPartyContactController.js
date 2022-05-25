({
	doInit : function(cmp, event, helper) {
		
        // handles checking for console and standard navigation and then navigating to the component appropriately        
        var myPageRef = cmp.get("v.pageReference");
        var id = myPageRef.state.c__id;
        console.log('id',id)
        cmp.set("v.id", id); 
		
	}
})
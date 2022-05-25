({
    fetchContacts : function(component, event, helper){
        var map = component.get('v.map');
        var bounds = map.getBounds();
        var NElng,NElat,SWlng,SWlat;
        var action = component.get("c.FindAllByLocation");
        NElng=bounds._northEast.lng;
        NElat=bounds._northEast.lat;
        SWlng=bounds._southWest.lng;
        SWlat=bounds._southWest.lat; 
        
        if(action != null){
            action.setParams({"NElng":NElng,"NElat":NElat,"SWlng":SWlng,"SWlat":SWlat});
            action.setCallback(this, function(response) {          
                var contactList =  response.getReturnValue();
                if(contactList.length > 0)
                    this.loadContactsOnMap(helper, contactList,map);                
            });
            action.setAbortable();
            $A.enqueueAction(action);
        }
    },
    loadContactsOnMap: function(helper, contacts,map){
        for (var i=0; i<contacts.length; i++) {
            var contact = contacts[i];
            var contactName = contact.Name;
            if(contact.MailingLatitude != null && contact.MailingLatitude !='' && contact.MailingLongitude != null && contact.MailingLongitude !=''){            	
                var latLng = [contact.MailingLatitude, contact.MailingLongitude];            
            	var marker = L.marker(latLng, {contact: contact}).addTo(map).on('click', function(event) { helper.navigateToDetailsView(event.target.options.contact.Id); });
                marker.bindPopup(contactName);		
            }
        }  
    },
    navigateToDetailsView : function(contactId) {
        var event = $A.get("e.force:navigateToSObject");
        event.setParams({
            "recordId": contactId
        });
        event.fire();
    },
    loadContactInCurrentMapView:function(contacts,NElng,NElat,SWlng,SWlat,component){       
        var event = $A.get("e.c:ContactsLoaded");
        event.setParams({"contacts": contacts});
        event.fire();
    }
})
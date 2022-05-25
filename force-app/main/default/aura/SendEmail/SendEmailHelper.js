({
	 removeRelatedObject:function(component, event, attribute){
         var source = event.getSource();
         var id = source.get("v.buttonTitle");
         var relatedObjects = component.get(attribute);
         for (var i = 0; i < relatedObjects.length; i++) {
                if(relatedObjects[i].Id === id){
                	relatedObjects.splice(i,1);
                    break;
                }
          }
          //Re-assign the attribute with the attendee removed
          component.set(attribute, relatedObjects); 
    }
})
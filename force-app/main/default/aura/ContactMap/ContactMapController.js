({
    jsLoaded: function(component, event, helper) {
             setTimeout(function() {
                var isChromium = window.chrome,
                winNav = window.navigator,
                vendorName = winNav.vendor,
                isOpera = winNav.userAgent.indexOf("OPR") > -1,
                isIEedge = winNav.userAgent.indexOf("Edge") > -1,
                isIOSChrome = winNav.userAgent.match("CriOS");
            //This code block added for "locate" functionality. locate function does not work on PC, it works only on mobile phone. Set Default to HL physical address
            if(isChromium !== null && isChromium !== undefined && vendorName === "Google Inc." && isOpera == false && isIEedge == false) {            
                var map = L.map('map').setView([34.0570850,-118.4174480], 12)
            } else { 
                var map = L.map('map').locate({setView: true, maxZoom: 16}); //setView([34.0570850,-118.4174480], 12)
            }
            
            L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                {
                    attribution: 'Tiles © Esri'
                }).addTo(map);
            component.set("v.map", map);
       		L.control.scale().addTo(map);                         
            var circle = L.circle(map.getCenter(), 100, {
                color: 'red',
                fillColor: '#f03',
                fillOpacity: 0.5
            }).addTo(map);
            
            map.on('moveend',         function (e) { 
                var bounds = map.getBounds();
                var NElng,NElat,SWlng,SWlat;
                NElng=bounds._northEast.lng;
                NElat=bounds._northEast.lat;
                SWlng=bounds._southWest.lng;
                SWlat=bounds._southWest.lat;                                 
                var MapLoadedEvent = component.getEvent("MapLoadedEvent");            
                MapLoadedEvent.setParams({"NElng": NElng, "NElat":NElat, "SWlng":SWlng, "SWlat":SWlat});
                component.set("v.SWlat",SWlat);
                MapLoadedEvent.fire();  
                helper.fetchContacts(component, event, helper);
            });
            
            var bounds = map.getBounds();
            var NElng,NElat,SWlng,SWlat;
            NElng=bounds._northEast.lng;
            NElat=bounds._northEast.lat;
            SWlng=bounds._southWest.lng;
            SWlat=bounds._southWest.lat;                 
            var MapLoadedEvent = component.getEvent("MapLoadedEvent");            
            MapLoadedEvent.setParams({"NElng": NElng, "NElat":NElat, "SWlng":SWlng, "SWlat":SWlat});
            component.set("v.SWlat",SWlat);
            MapLoadedEvent.fire();    
        });
    },
    searchMap: function(component, event, helper) {
        // Center the map on the account selected in the list
        var map = component.get('v.map');
        var coordinates = event.getParam("coordinates");
        map.panTo([coordinates[0], coordinates[1]]); //lat,lng
        var latLng = [coordinates[0], coordinates[1]];
        L.marker(latLng).addTo(map);
        helper.fetchContacts(component, event, helper);             
    }
    
})
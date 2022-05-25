public with sharing class HL_MapGeoLocationSearch {    
    @AuraEnabled
    static public List<double> geocodeAddress(string cityName, string zipCode)
    { 	       
        List<double> coordinates = new List<double>();
        // Key for Google Maps Geocoding API
        String geocodingKey = 'AIzaSyBwH9w49sxJ1Pu_rZqO3ISYS-ehSUrroPU';
       	String geoAddress= '';
        if(String.isBlank(cityName)) {
            geoAddress = EncodingUtil.urlEncode(zipcode, 'UTF-8');
        }else{
            geoAddress = EncodingUtil.urlEncode(cityName, 'UTF-8');
        }            
            // build and make the callout to the Geocoding API
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address='+ geoAddress + '&key=' + geocodingKey + '&sensor=false');
            request.setMethod('GET');
            request.setTimeout(60000);
            try {                                
                //make the http callout
                HttpResponse response = http.send(request);
                //parse JSON to extract co-ordinates
                JSONParser responseParser = JSON.createParser(response.getBody());
                // initialize co-ordinates
                double latitude = null;
                double longitude = null;
                while (responseParser.nextToken() != null) {
                    if ((responseParser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                        (responseParser.getText() == 'location')) {
                            responseParser.nextToken();
                            while (responseParser.nextToken() != JSONToken.END_OBJECT) {
                                String locationText = responseParser.getText();
                                responseParser.nextToken();
                                if (locationText == 'lat')
                                    latitude = responseParser.getDoubleValue();
                                else if (locationText == 'lng')
                                    longitude = responseParser.getDoubleValue();
                            }
                        }
                }                
                //Create coordinates list to return                
                if(latitude != null) {                   
                   coordinates.Add(latitude);
                   coordinates.Add(longitude);                    
                }
            } catch (Exception e) {                             
                throw new GeocodeException ('Error with getting address location: ' + e.getMessage());
            }        
        return coordinates;
       
    }
public class GeocodeException extends Exception {}    
}
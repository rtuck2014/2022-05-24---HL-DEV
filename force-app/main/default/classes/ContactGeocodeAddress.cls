public class ContactGeocodeAddress {
    
    // static variable to determine if geocodinghas already occurred
    private static Boolean geocodingCalled = false;
    
    // wrapper method to prevent calling future methods from an existing future context
    public static void DoAddressGeocode(List<id> contactIdList) {
        if(geocodingCalled || System.isFuture()) {
            System.debug(LoggingLevel.WARN,'***Address Geocoding Future Method Already Called - Aborting...');
            return;
        }
        
        // ifnot being called from future context, geocode the address
        geocodingCalled = true;
        geocodeAddress(contactIdList);
    }
    
    
    // we need a future method to call Google Geocoding API from Salesforce
    @future (callout=true)
    static private void geocodeAddress(List<id> contactIdList)
    { 	
        List<Contact> updatedContactList = new List<Contact>();
        // Key for Google Maps Geocoding API
        String geocodingKey = 'AIzaSyBwH9w49sxJ1Pu_rZqO3ISYS-ehSUrroPU';
        // get the passed in address
        List<Contact> geoContactList = [SELECT MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode
                                        FROM Contact
                                        WHERE id in :contactIdList];
        for(Contact geoContact: geoContactList){
            //check that we have enough information to geocode the address
            if((geoContact.MailingStreet == null) || (geoContact.MailingCity == null)) {
                System.debug(LoggingLevel.WARN,'Insufficient Data to Geocode Address');
                return;
            }
            //create a string for the address to pass to Google Geocoding API
            String geoAddress = '';
            if (geoContact.MailingStreet != null)
                geoAddress += geoContact.MailingStreet + ', ';
            
            if (geoContact.MailingCity != null)
                geoAddress += geoContact.MailingCity + ', ';
            if (geoContact.MailingState != null)
                geoAddress += geoContact.MailingState + ', ';
            if (geoContact.MailingCountry != null)
                geoAddress += geoContact.MailingCountry + ', ';
            if (geoContact.MailingPostalCode != null)
                geoAddress += geoContact.MailingPostalCode;
            
            //encode the string so we can pass it as part of URL
            geoAddress = EncodingUtil.urlEncode(geoAddress, 'UTF-8');
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
                //update co-ordinates on address if we get them back
                if(latitude != null) {
                    geoContact.Geolocation__Latitude__s = latitude;
                    geoContact.Geolocation__Longitude__s = longitude;
                    updatedContactList.add(geoContact);
                    // update geoContact;
                }
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR,'Error Geocoding Address - ' + e.getMessage());
            }
        }
        if(updatedContactList.size()>0){
            update updatedContactList;
        }
    }
    
}
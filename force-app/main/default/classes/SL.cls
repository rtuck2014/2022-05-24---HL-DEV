/**
 * @description utility class for app-wide constants, exceptions, and utility
 *  functions
 *
 * @author Stefan Schwaab
 */
public with sharing class SL {
    //--------------------------------------------------------------------------
    // Constants
    
    
    //--------------------------------------------------------------------------
    // Exceptions
    // @description base class for all exceptions
    public abstract class SL_Exception extends Exception {
    }
    
    // @description a failed assertion
    public class AssertionException extends SL_Exception {
    }
    
    // @description error in trigger definition or setup
    public class TriggerException extends SL_Exception {
    }
    
    // @description a data validation error of some sort
    public class ValidationException extends SL_Exception {
    }
    
    // @description HTTP error
    public class HttpException extends SL_Exception {
        public Integer code { get; private set; }
        public HttpException(Integer code, String msg) {
            this(msg);
            this.code = code;
        }
    }
    
    
    //--------------------------------------------------------------------------
    // Diagnostics
    private static transient Boolean debuggingValue = true;
    public static Boolean debugging { get { return debuggingValue; }}
    
    public static void error(Object message) {
        debug(LoggingLevel.ERROR, message);
    }
    public static void warn(Object message) {
        debug(LoggingLevel.WARN, message);
    }
    public static void info(Object message) {
        debug(LoggingLevel.INFO, message);
    }
    public static void debug(Object message) {
        debug(LoggingLevel.DEBUG, message);
    }
    private static void debug(LoggingLevel level, Object message) {
        if (debugging) {
            System.debug(level, '!!! ' + message);
        }
    }
    
    public static void assert(Boolean condition) {
        assert(condition, null);
    }
    public static void assert(Boolean condition, Object message) {
        if (debugging && !condition) {
            throw new SL.AssertionException(String.valueOf(message));
        }
    }
    public static void assertEquals(Object v1, Object v2) {
        assertEquals(v1, v2, null);
    }
    public static void assertEquals(Object v1, Object v2, Object message) {
        if (debugging && (v1 != v2)) {
            throw new SL.AssertionException(String.valueOf(message));
        }
    }
    public static void assertNotEquals(Object v1, Object v2) {
        assertNotEquals(v1, v2, null);
    }
    public static void assertNotEquals(Object v1, Object v2, Object message) {
        if (debugging && (v1 == v2)) {
            throw new SL.AssertionException(String.valueOf(message));
        }
    }
    
    
    //--------------------------------------------------------------------------
    // Utility functions
    /**
     * @description given an object field, return the pick list values/labels as 
     * a list of SelectOptions that can be displayed by a VF page.
     * @param field - the pick list field
     * @return all pick list options as a list of SelectOptions
    */
    public static SelectOption[] getPickListAsSelectOptions(SObjectField field) {
        SelectOption[] result = new SelectOption[] {};
        for (PicklistEntry e : field.getDescribe().getPickListValues()) {
            result.add(new SelectOption(e.getValue(), e.getLabel()));
        }

        return result;
    }
    
    /**
     * @description return the specified page parameter as a string
     * @param key - the key in the query string; may not be null
     * @param defaultValue - if the key doesn't exist, return this value
     */
    public static String getStringPageParam(String key, String defaultValue) {
        String param = ApexPages.currentPage().getParameters().get(key);
        return (null == param) ? defaultValue : param;
    }
    
    public static String getStringPageParam(String key) {
        return getStringPageParam(key, '');
    }
    
    /**
     * @description String formatting short cuts.
     * Note: single apostrophes need to be double escaped.
     * @see String.format
     */
    public static String format(String format, Object arg1) {
        return String.format(format.replaceAll('\'', '\'\''), new String[] {
            String.valueOf(arg1)});
    }
    
    public static String format(String format, Object arg1, Object arg2) {
        return String.format(format.replaceAll('\'', '\'\''), new String[] {
            String.valueOf(arg1), String.valueOf(arg2)});
    }
    
    public static String format(String format, Object arg1, Object arg2, Object arg3) {
        return String.format(format.replaceAll('\'', '\'\''), new String[] {
            String.valueOf(arg1), String.valueOf(arg2), String.valueOf(arg3)});
    }
    
    /**
     * @description redirect helper
     * @param nextPage - the page to redirect to
     * @param key - a key to append to the query string for the URL
     * @param value - the value to append to the query string for the URL
     * @return the page reference to the new page
    */
    public static PageReference redirect(String nextPage, String key, String value) { 
        PageReference result;
        if (null != nextPage) {
            result = new PageReference('/apex/' + nextPage);
            if (null != key) {
                result.getParameters().put(key, value);
            }
            result.setRedirect(false);  // allow a postback rather than a get if possible
        }
        
        return result;
    }

    public static PageReference redirect(String nextPage, String key, String value, String key2, String value2) { 
        PageReference result;
        if (null != nextPage) {
            result = new PageReference('/apex/' + nextPage);
            if (null != key) {
                result.getParameters().put(key, value);
            }
            if (null != key2) {
                result.getParameters().put(key2, value2);
            }
            result.setRedirect(false);  // allow a postback rather than a get if possible
        }
        
        return result;
    }
    
    public static PageReference redirect(PageReference nextPage, String key, String value) {
        return SL.redirect(nextPage.getUrl(), key, value);
    }

    public static PageReference redirect(PageReference nextPage, String key, String value, String key2, String value2) { 
        return SL.redirect(nextPage.getUrl(), key, value, key2, value2);
    }
    
    public static PageReference redirect(String nextPage) {
        return SL.redirect(nextPage, null, null); 
    }
    
    public static PageReference redirect(PageReference nextPage) {
        return SL.redirect(nextPage, null, null); 
    }
    
    // @return true if the specified object is null, empty, or only whitespace
    // WARNING this method doesn't work with empty sets or maps
    //  somehow, Set<String> is not recognized as an instanceof Set<Object> and
    //  Map<String,String> is not recognized as an instanceof Map<String,String>
    public static Boolean nullOrEmpty(Object o) {
        if (null == o) {
            return true;
        } else if ((o instanceof String) && (0 == ((String)o).trim().length())) {
            return true;
        } else if ((o instanceof List<Object>) && (0 == ((List<Object>)o).size())) {
            return true;
        }
        
        return false;
    }

    /**
     * @description do an HTTP request and return the response.
     *    Basic authentication is assumed.
     *    Any HTTP status code >= 300 will throw an HttpException.
     * @param username, password - login credentials
     * @param url - the endpoint
     * @param jsonBody - JSON-encoded body; may be null
     */
    public static String httpGet(String username, String password, String url, 
        String jsonBody, Map<String,String> headers) {
        return http('GET', username, password, url, jsonBody, headers);
    }
    
    public static String httpPost(String username, String password, String url, 
        String jsonBody, Map<String,String> headers) {
        return http('POST', username, password, url, jsonBody, headers);
    }
    
    public static String http(String op, String username, String password, String url,
        String jsonBody, Map<String,String> headers) {
        SL.debug('http(' + op + ', ' + username + ', ' + password + ', ' + url + ')'); 
            
        HttpRequest request = new HttpRequest();
        request.setMethod(op);
        request.setEndpoint(url);
        
        // authentication
        final Blob creds = Blob.valueOf(username + ':' + password);
        request.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(creds));
        if (null != headers) {
            for (String h : headers.keySet()) {
                final String value = headers.get(h);
                request.setHeader(h, (null == value) ? '' : value);
            }
        }
        
        // request parameters
        if (!SL.nullOrEmpty(jsonBody)) {
            request.setHeader('Content-Type', 'application/json;');
            request.setBody(jsonBody);
        }
        
        // make the request and handle the response
        final Http h = new Http();
        HttpResponse response = h.send(request);
        final Integer status = (null != response) ? response.getStatusCode() : 0;
        if (status >= 300) {
            throw new SL.HttpException(status, response.getBody());
        } else {
            return (null != response) ? response.getBody() : '';
        }
    }
    
    /**
     * @description return the unique field values for a given field in a list of 
     *  records. Null is not included.
     */
    public static Set<String> getFieldValues(SObject[] objects, String field) {
        Set<String> result = new Set<String>();
        if (null != objects) {
            for (SObject o : objects) {
                result.add(String.valueOf(o.get(field)));
            }
            result.remove(null);
        }
        return result;
    }
    
    public static Set<Id> getFieldIds(SObject[] objects, String field) {
        Set<Id> result = new Set<Id>();
        if (null != objects) {
            for (SObject o : objects) {
                result.add(String.valueOf(o.get(field)));
            }
            result.remove(null);
        }
        return result;
    }
    
    /**
     * @description add 'days' weekdays to a given date, 'start'
     * @param start - the date to use as a starting point
     * @param days - offset; may be positive or negative
     * @param eod - if 'start' is > 'eod', we will add 1 day when computing the result
     */
    public static Date addBusinessDays(DateTime start, Integer days, Time eod) {
        Date s = start.date();
        if ((null != eod) && (start.time() > eod)) {
            s += 1;
        }
        return addBusinessDays(s, days);
    }

    public static Datetime addBusinessDays(Datetime StartDatetime, integer BusinessDaysToAdd )
    {
        // Extract start date
        Date startDate = StartDatetime.Date();
        // Extract start time
        Time startTime = StartDatetime.Time();
        // Add Business Days to start date
        Date newDate = addBusinessDays(startDate, BusinessDaysToAdd);
        // Add time back to New Date
        return Datetime.newInstance(newDate, startTime);
    }
    
    public static Date addBusinessDays(Date StartDate, integer BusinessDaysToAdd )
    {
       //Add or decrease in BusinessDaysToAdd days 
       Date finalDate = StartDate;
       integer direction = BusinessDaysToAdd < 0 ? -1 : 1;
       //If start on a weekend, get to first weekday
       if ((isWeekendDay(finalDate)) && (direction==1)) {
            while(isWeekendDay(finalDate)) {
                finalDate = finalDate.AddDays(direction);
            }
       }
       while(BusinessDaysToAdd != 0)
        {
            finalDate = finalDate.AddDays(direction);
            system.debug('>>>>> Current Date = '+finalDate);
            if (!isWeekendDay(finalDate))
            {
                BusinessDaysToAdd -= direction;
            }
            system.debug('>>>>> BusinessDaysToAdd = '+BusinessDaysToAdd);            
        }
        system.debug('>>>>> Final Date = ' + finalDate);
        return finalDate;
    }

    public static Boolean isWeekendDay(Date dateParam)
    {
       boolean result     = false;
       //Recover the day of the week
       Date startOfWeek   = dateParam.toStartOfWeek();
       system.debug('>>>>> startOfWeek = '+startOfWeek);
       Integer dayOfWeek  = startOfWeek.daysBetween(dateParam);
       system.debug('>>>>> dayOfWeek = '+dayOfWeek);   
       result = dayOfWeek == 0 || dayOfWeek == 6 ? true : false;
       system.debug('>>>>> Is Weekend Day? '+result); 
       return result;
    } 
    
    public static void sendEmail(String to, String subject, String body) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { to });
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}
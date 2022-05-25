public with sharing class hlUniversalLookupController {
    //===============================================================================================
    //Purpose: Controller for hlUniversalLookup (Lightning Web Components)
    //Author: Larry Leonidas - Invest Apex Solutions 7/23/2019
    //Description - Returns Datatable of dynmaic search result for a particular target Object
    //===============================================================================================
    @AuraEnabled(cacheable=true)
    public static List<SObject> getLookupSearch(String objectApi, String filter, List<String> fields, String sortField, String sortDirection, String offset){
        system.debug('getLookupSearch--01-filter: '+ String.escapeSingleQuotes(filter));
        system.debug('getLookupSearch--02-fields: '+ String.join(fields,','));
        String lookFilter = String.escapeSingleQuotes(filter);
        String lookSortField = String.escapeSingleQuotes(sortField);
        String lookSortDirection = String.escapeSingleQuotes(sortDirection);
        String lookOffset = String.escapeSingleQuotes(offset);
        List<String> lookFields = new List<String>();
        for(String f: fields){
            lookFields.add(String.escapeSingleQuotes(f));
        }
        if(lookFilter == '' || lookFilter == null) lookFilter = 'Houlihan';
        String qry = 'FIND \'' + lookFilter + '\' IN NAME FIELDS RETURNING '+ objectApi +'('+ String.join(lookFields,',') +' ORDER BY '+lookSortField +' ' + lookSortDirection + ' NULLS FIRST LIMIT 50 OFFSET '+ lookOffset+')';
        List<List<SObject>> searchList = search.query(qry);
        system.debug('getLookupSearch--02-qry: '+ qry);
        system.debug('getLookupSearch--02-searchList: '+ searchList.size());
        system.debug('getLookupSearch--02-searchList[0].size(): '+ searchList[0].size());
        return searchList[0];
    }
}
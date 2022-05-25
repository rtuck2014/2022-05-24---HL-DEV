public without sharing class HL_DateUtility {
    @AuraEnabled
    public static Date GetDateFromJavascript(string dateValue){
         Integer intYear, intMonth, intDate;
        //Replacing '-' to '/'. Date.Parse() method take string in a specific format which takes '/' 
        List<String> lstDate = new List<String>();
        List<String> lstDateFormat = new List<String>();
        String dateFormat = GetDateFormat(UserInfo.getLocale()).replace('-','/').replace('.','/');
        dateValue = dateValue.replace('00:00:00', '').replaceAll('-', '/').trim();
        lstDate.addAll(dateValue.split('/'));
        lstDateFormat.addAll(dateFormat.split('/'));
        
         if(lstDateFormat.size() == 3 && lstDate.size() == 3){
             for(Integer i = 0; i<3; i++){
                 if(lstDateFormat[i].contains('d'))
                     intDate = Integer.valueOf(lstDate[i]);
                 else if(lstDateFormat[i].contains('M'))
                     intMonth = Integer.valueOf(lstDate[i]);
                 else if(lstDateFormat[i].contains('y'))
                     intYear = Integer.valueOf(lstDate[i]);
             }
         }
        else{
            intYear = (lstDate[0].length() == 4) ? Integer.valueOf(lstDate[0]) :  Integer.valueOf(lstDate[2]);  
            intMonth = (lstDate[0].length() == 4) ? Integer.valueOf(lstDate[1]): Integer.valueOf(lstDate[0]);
            intDate = (lstDate[0].length() == 4) ? Integer.valueOf(lstDate[2]): Integer.valueOf(lstDate[1]);
        }
        
        return Date.newinstance(intYear,intMonth,intDate);
    }
    
	//Date Local Mapper
    @AuraEnabled
    public static Map<String,String> GetDateFormatMap(){
		Map<String, String> localeMap = new Map<String, String>(); //holds the locale to timedate formats
		localeMap.put('ar', 'dd/MM/yyyy');
		localeMap.put('ar_AE', 'dd/MM/yyyy');
		localeMap.put('ar_BH', 'dd/MM/yyyy');
		localeMap.put('ar_JO', 'dd/MM/yyyy');
		localeMap.put('ar_KW', 'dd/MM/yyyy');
		localeMap.put('ar_LB', 'dd/MM/yyyy');
		localeMap.put('ar_SA', 'dd/MM/yyyy');
		localeMap.put('bg_BG', 'yyyy-M-d');
		localeMap.put('ca', 'dd/MM/yyyy');
		localeMap.put('ca_ES', 'dd/MM/yyyy');
		localeMap.put('ca_ES_EURO', 'dd/MM/yyyy');
		localeMap.put('cs', 'd.M.yyyy');
		localeMap.put('cs_CZ', 'd.M.yyyy');
		localeMap.put('da', 'dd-MM-yyyy');
		localeMap.put('da_DK', 'dd-MM-yyyy');
		localeMap.put('de', 'dd.MM.yyyy');
		localeMap.put('de_AT', 'dd.MM.yyyy');
		localeMap.put('de_AT_EURO', 'dd.MM.yyyy');
		localeMap.put('de_CH', 'dd.MM.yyyy');
		localeMap.put('de_DE', 'dd.MM.yyyy');
		localeMap.put('de_DE_EURO', 'dd.MM.yyyy');
		localeMap.put('de_LU', 'dd.MM.yyyy');
		localeMap.put('de_LU_EURO', 'dd.MM.yyyy');
		localeMap.put('el_GR', 'd/M/yyyy');
		localeMap.put('en_AU', 'd/MM/yyyy');
		localeMap.put('en_B', 'M/d/yyyy');
		localeMap.put('en_BM', 'M/d/yyyy');
		localeMap.put('en_CA', 'dd/MM/yyyy');
		localeMap.put('en_GB', 'dd/MM/yyyy');
		localeMap.put('en_GH', 'M/d/yyyy');
		localeMap.put('en_ID', 'M/d/yyyy');
		localeMap.put('en_IE', 'dd/MM/yyyy');
		localeMap.put('en_IE_EURO', 'dd/MM/yyyy');
		localeMap.put('en_NZ', 'd/MM/yyyy');
		localeMap.put('en_SG', 'M/d/yyyy');
		localeMap.put('en_US', 'M/d/yyyy');
		localeMap.put('en_ZA', 'yyyy/MM/dd');
        localeMap.put('en_HK', 'dd/MM/yyyy');
		localeMap.put('es', 'd/MM/yyyy');
		localeMap.put('es_AR', 'dd/MM/yyyy');
		localeMap.put('es_BO', 'dd-MM-yyyy');
		localeMap.put('es_CL', 'dd-MM-yyyy');
		localeMap.put('es_CO', 'd/MM/yyyy');
		localeMap.put('es_CR', 'dd/MM/yyyy');
		localeMap.put('es_EC', 'dd/MM/yyyy');
		localeMap.put('es_ES', 'd/MM/yyyy');
		localeMap.put('es_ES_EURO', 'd/MM/yyyy');
		localeMap.put('es_GT', 'd/MM/yyyy');
		localeMap.put('es_HN', 'MM-dd-yyyy');
		localeMap.put('es_MX', 'd/MM/yyyy');
		localeMap.put('es_PE', 'dd/MM/yyyy');
		localeMap.put('es_PR', 'MM-dd-yyyy');
		localeMap.put('es_PY', 'dd/MM/yyyy');
		localeMap.put('es_SV', 'MM-dd-yyyy');
		localeMap.put('es_UY', 'dd/MM/yyyy');
		localeMap.put('es_VE', 'dd/MM/yyyy');
		localeMap.put('et_EE', 'd.MM.yyyy');
		localeMap.put('fi', 'd.M.yyyy');
		localeMap.put('fi_FI', 'd.M.yyyy');
		localeMap.put('fi_FI_EURO', 'd.M.yyyy');
		localeMap.put('fr', 'dd/MM/yyyy');
		localeMap.put('fr_BE', 'd/MM/yyyy');
		localeMap.put('fr_CA', 'yyyy-MM-dd');
		localeMap.put('fr_CH', 'dd.MM.yyyy');
		localeMap.put('fr_FR', 'dd/MM/yyyy');
		localeMap.put('fr_FR_EURO', 'dd/MM/yyyy');
		localeMap.put('fr_LU', 'dd/MM/yyyy');
		localeMap.put('fr_MC', 'dd/MM/yyyy');
		localeMap.put('hr_HR', 'yyyy.MM.dd');
		localeMap.put('hu', 'yyyy.MM.dd');
		localeMap.put('hy_AM', 'M/d/yyyy');
		localeMap.put('is_IS', 'd.M.yyyy');
		localeMap.put('it', 'dd/MM/yyyy');
		localeMap.put('it_CH', 'dd.MM.yyyy');
		localeMap.put('it_IT', 'dd/MM/yyyy');
		localeMap.put('iw', 'dd/MM/yyyy');
		localeMap.put('iw_IL', 'dd/MM/yyyy');
		localeMap.put('ja', 'yyyy/MM/dd');
		localeMap.put('ja_JP', 'yyyy/MM/dd');
		localeMap.put('kk_KZ', 'M/d/yyyy');
		localeMap.put('km_KH', 'M/d/yyyy');
		localeMap.put('ko', 'yyyy. M. d');
		localeMap.put('ko_KR', 'yyyy. M. d');
		localeMap.put('lt_LT', 'yyyy.M.d');
		localeMap.put('lv_LV', 'yyyy.d.M');
		localeMap.put('ms_MY', 'dd/MM/yyyy');
		localeMap.put('nl', 'd-M-yyyy');
		localeMap.put('nl_BE', 'd/MM/yyyy');
		localeMap.put('nl_NL', 'd-M-yyyy');
		localeMap.put('nl_SR', 'd-M-yyyy');
		localeMap.put('no', 'dd.MM.yyyy');
		localeMap.put('no_NO', 'dd.MM.yyyy');
		localeMap.put('pl', 'yyyy-MM-dd');
		localeMap.put('pt', 'dd-MM-yyyy');
		localeMap.put('pt_AO', 'dd-MM-yyyy');
		localeMap.put('pt_BR', 'dd/MM/yyyy');
		localeMap.put('pt_PT', 'dd-MM-yyyy');
		localeMap.put('ro_RO', 'dd.MM.yyyy');
		localeMap.put('ru', 'dd.MM.yyyy');
		localeMap.put('sk_SK', 'd.M.yyyy');
		localeMap.put('sl_SI', 'd.M.y');
		localeMap.put('sv', 'yyyy-MM-dd');
		localeMap.put('sv_SE', 'yyyy-MM-dd');
		localeMap.put('th', 'M/d/yyyy');
		localeMap.put('th_TH', 'd/M/yyyy');
		localeMap.put('tr', 'dd.MM.yyyy');
		localeMap.put('ur_PK', 'M/d/yyyy');
		localeMap.put('vi_VN', 'dd/MM/yyyy');
		localeMap.put('zh', 'yyyy-M-d');
		localeMap.put('zh_CN', 'yyyy-M-d');
		localeMap.put('zh_HK', 'yyyy年M月d日');
		localeMap.put('zh_TW', 'yyyy/M/d');
        localeMap.put('zh_CN_PINYIN', 'yyyy/M/d');
		return localeMap; //return the map
	}
    
     //DateTime Local Mapper
    @AuraEnabled
    public static Map<String,String> GetDateTimeFormatMap(){
		Map<String, String> localeMap = new Map<String, String>(); //holds the locale to timedate formats
		localeMap.put('ar', 'dd/MM/yyyy hh:mm a');
		localeMap.put('ar_AE', 'dd/MM/yyyy hh:mm a');
		localeMap.put('ar_BH', 'dd/MM/yyyy hh:mm a');
		localeMap.put('ar_JO', 'dd/MM/yyyy hh:mm a');
		localeMap.put('ar_KW', 'dd/MM/yyyy hh:mm a');
		localeMap.put('ar_LB', 'dd/MM/yyyy hh:mm a');
		localeMap.put('ar_SA', 'dd/MM/yyyy hh:mm a');
		localeMap.put('bg_BG', 'yyyy-M-d H:mm');
		localeMap.put('ca', 'dd/MM/yyyy HH:mm');
		localeMap.put('ca_ES', 'dd/MM/yyyy HH:mm');
		localeMap.put('ca_ES_EURO', 'dd/MM/yyyy HH:mm');
		localeMap.put('cs', 'd.M.yyyy H:mm');
		localeMap.put('cs_CZ', 'd.M.yyyy H:mm');
		localeMap.put('da', 'dd-MM-yyyy HH:mm');
		localeMap.put('da_DK', 'dd-MM-yyyy HH:mm');
		localeMap.put('de', 'dd.MM.yyyy HH:mm');
		localeMap.put('de_AT', 'dd.MM.yyyy HH:mm');
		localeMap.put('de_AT_EURO', 'dd.MM.yyyy HH:mm');
		localeMap.put('de_CH', 'dd.MM.yyyy HH:mm');
		localeMap.put('de_DE', 'dd.MM.yyyy HH:mm');
		localeMap.put('de_DE_EURO', 'dd.MM.yyyy HH:mm');
		localeMap.put('de_LU', 'dd.MM.yyyy HH:mm');
		localeMap.put('de_LU_EURO', 'dd.MM.yyyy HH:mm');
		localeMap.put('el_GR', 'd/M/yyyy h:mm a');
		localeMap.put('en_AU', 'd/MM/yyyy HH:mm');
		localeMap.put('en_B', 'M/d/yyyy h:mm a');
		localeMap.put('en_BM', 'M/d/yyyy h:mm a');
		localeMap.put('en_CA', 'dd/MM/yyyy h:mm a');
		localeMap.put('en_GB', 'dd/MM/yyyy HH:mm');
		localeMap.put('en_GH', 'M/d/yyyy h:mm a');
		localeMap.put('en_ID', 'M/d/yyyy h:mm a');
		localeMap.put('en_IE', 'dd/MM/yyyy HH:mm');
		localeMap.put('en_IE_EURO', 'dd/MM/yyyy HH:mm');
		localeMap.put('en_NZ', 'd/MM/yyyy HH:mm');
		localeMap.put('en_SG', 'M/d/yyyy h:mm a');
		localeMap.put('en_US', 'M/d/yyyy h:mm a');
		localeMap.put('en_ZA', 'yyyy/MM/dd hh:mm a');
        localeMap.put('en_HK', 'dd/MM/yyyy, hh:mm a');
		localeMap.put('es', 'd/MM/yyyy H:mm');
		localeMap.put('es_AR', 'dd/MM/yyyy HH:mm');
		localeMap.put('es_BO', 'dd-MM-yyyy hh:mm a');
		localeMap.put('es_CL', 'dd-MM-yyyy hh:mm a');
		localeMap.put('es_CO', 'd/MM/yyyy hh:mm a');
		localeMap.put('es_CR', 'dd/MM/yyyy hh:mm a');
		localeMap.put('es_EC', 'dd/MM/yyyy hh:mm a');
		localeMap.put('es_ES', 'd/MM/yyyy H:mm');
		localeMap.put('es_ES_EURO', 'd/MM/yyyy H:mm');
		localeMap.put('es_GT', 'd/MM/yyyy hh:mm a');
		localeMap.put('es_HN', 'MM-dd-yyyy hh:mm a');
		localeMap.put('es_MX', 'd/MM/yyyy hh:mm a');
		localeMap.put('es_PE', 'dd/MM/yyyy hh:mm a');
		localeMap.put('es_PR', 'MM-dd-yyyy hh:mm a');
		localeMap.put('es_PY', 'dd/MM/yyyy hh:mm a');
		localeMap.put('es_SV', 'MM-dd-yyyy hh:mm a');
		localeMap.put('es_UY', 'dd/MM/yyyy hh:mm a');
		localeMap.put('es_VE', 'dd/MM/yyyy hh:mm a');
		localeMap.put('et_EE', 'd.MM.yyyy H:mm');
		localeMap.put('fi', 'd.M.yyyy H:mm');
		localeMap.put('fi_FI', 'd.M.yyyy H:mm');
		localeMap.put('fi_FI_EURO', 'd.M.yyyy H:mm');
		localeMap.put('fr', 'dd/MM/yyyy HH:mm');
		localeMap.put('fr_BE', 'd/MM/yyyy H:mm');
		localeMap.put('fr_CA', 'yyyy-MM-dd HH:mm');
		localeMap.put('fr_CH', 'dd.MM.yyyy HH:mm');
		localeMap.put('fr_FR', 'dd/MM/yyyy HH:mm');
		localeMap.put('fr_FR_EURO', 'dd/MM/yyyy HH:mm');
		localeMap.put('fr_LU', 'dd/MM/yyyy HH:mm');
		localeMap.put('fr_MC', 'dd/MM/yyyy HH:mm');
		localeMap.put('hr_HR', 'yyyy.MM.dd HH:mm');
		localeMap.put('hu', 'yyyy.MM.dd. H:mm');
		localeMap.put('hy_AM', 'M/d/yyyy h:mm a');
		localeMap.put('is_IS', 'd.M.yyyy HH:mm');
		localeMap.put('it', 'dd/MM/yyyy H.mm');
		localeMap.put('it_CH', 'dd.MM.yyyy HH:mm');
		localeMap.put('it_IT', 'dd/MM/yyyy H.mm');
		localeMap.put('iw', 'HH:mm dd/MM/yyyy');
		localeMap.put('iw_IL', 'HH:mm dd/MM/yyyy');
		localeMap.put('ja', 'yyyy/MM/dd H:mm');
		localeMap.put('ja_JP', 'yyyy/MM/dd H:mm');
		localeMap.put('kk_KZ', 'M/d/yyyy h:mm a');
		localeMap.put('km_KH', 'M/d/yyyy h:mm a');
		localeMap.put('ko', 'yyyy. M. d a h:mm');
		localeMap.put('ko_KR', 'yyyy. M. d a h:mm');
		localeMap.put('lt_LT', 'yyyy.M.d HH.mm');
		localeMap.put('lv_LV', 'yyyy.d.M HH:mm');
		localeMap.put('ms_MY', 'dd/MM/yyyy h:mm a');
		localeMap.put('nl', 'd-M-yyyy H:mm');
		localeMap.put('nl_BE', 'd/MM/yyyy H:mm');
		localeMap.put('nl_NL', 'd-M-yyyy H:mm');
		localeMap.put('nl_SR', 'd-M-yyyy H:mm');
		localeMap.put('no', 'dd.MM.yyyy HH:mm');
		localeMap.put('no_NO', 'dd.MM.yyyy HH:mm');
		localeMap.put('pl', 'yyyy-MM-dd HH:mm');
		localeMap.put('pt', 'dd-MM-yyyy H:mm');
		localeMap.put('pt_AO', 'dd-MM-yyyy H:mm');
		localeMap.put('pt_BR', 'dd/MM/yyyy HH:mm');
		localeMap.put('pt_PT', 'dd-MM-yyyy H:mm');
		localeMap.put('ro_RO', 'dd.MM.yyyy HH:mm');
		localeMap.put('ru', 'dd.MM.yyyy H:mm');
		localeMap.put('sk_SK', 'd.M.yyyy H:mm');
		localeMap.put('sl_SI', 'd.M.y H:mm');
		localeMap.put('sv', 'yyyy-MM-dd HH:mm');
		localeMap.put('sv_SE', 'yyyy-MM-dd HH:mm');
		localeMap.put('th', 'M/d/yyyy h:mm a');
		localeMap.put('th_TH', 'd/M/yyyy, H:mm ?.');
		localeMap.put('tr', 'dd.MM.yyyy HH:mm');
		localeMap.put('ur_PK', 'M/d/yyyy h:mm a');
		localeMap.put('vi_VN', 'HH:mm dd/MM/yyyy');
		localeMap.put('zh', 'yyyy-M-d ah:mm');
		localeMap.put('zh_CN', 'yyyy-M-d ah:mm');
		localeMap.put('zh_HK', 'yyyy年M月d日 ah:mm');
		localeMap.put('zh_TW', 'yyyy/M/d a h:mm');
        localeMap.put('zh_CN_PINYIN', 'yyyy/M/d a h:mm');
		return localeMap; //return the map
	}
    
    //Formats the Javascript Date (yyyy-mm-dd) to (mm/dd/yyyy) or (dd/mm/yyyy) where appropriate
    @AuraEnabled
    public static string FormatJSDate(string d){
        List<String> dateParts = d.split('-');
        if(dateParts.size() != 3)
            dateParts = DateTime.now().format('yyyy-MM-dd').split('-');
       	String dateFormat = GetDateFormat(UserInfo.getLocale()).toUpperCase();

        return dateFormat.toUpperCase().replace('YYYY', dateParts[0]).replace('MM', dateParts[1]).replace('M', dateParts[1]).replace('DD', dateParts[2]).replace('D', dateParts[2]);
        //return dateFormat.toUpperCase().indexOf('M') < dateFormat.indexOf('D') ? dateParts[1] + '/' + dateParts[2] + '/' + dateParts[0] : dateParts[2] + '/' + dateParts[1] + '/' + dateParts[0];
    }
    
    @AuraEnabled
    public static DateTime FormatDateTime(Date dateVal, String timeVal){
         Integer hourVal = timeVal.contains('AM') ? (Integer.valueOf(timeVal.substring(0,2)) == 12 ? 0 : Integer.valueOf(timeVal.substring(0,2))) : Integer.valueOf(timeVal.substring(0,2)) + (Integer.valueOf(timeVal.substring(0,2)) <> 12 ? 12 : 0);
         return DateTime.valueOf(dateVal.year() + '-' + dateVal.month() + '-' + dateVal.day() + ' ' + hourVal + ':' + timeVal.substring(3,5) + ':00');
    }
    
    //Gets the Date Format based on Locale
    @AuraEnabled
    public static String GetDateFormat(String locale){
        Map<String, String> localMap = GetDateFormatMap();
        String dateFormat = localMap.get(locale);
        //system.debug(system.LoggingLevel.DEBUG, 'format: ' + locale + ' ' + dateFormat);
        return !String.isBlank(dateFormat) ? dateFormat : 'MM/dd/yyyy';
    }
  	
    //Gets the Date Time Format based on Local
	@AuraEnabled
    public static String GetDateTimeFormat(String locale){
        Map<String, String> localMap = GetDateTimeFormatMap();
        String format = localMap.get(locale);
        return !String.isBlank(format) ? format : 'MM/dd/yyyy';
    }
}
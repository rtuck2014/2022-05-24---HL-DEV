/* 
	Author: Volodymyr Babin
	Main task: https://silverline.jira.com/browse/LIB-198
	Description:  Handles date format for JS code depending on current user locale. Almost fully taken from CalendarAnything functionality,
                    developed and supported by Denis Sorokin.
*/
public with sharing class SL_RTR_LIB16_DateObject {

    public SL_RTR_LIB16_DateObject(){
    }
    
    public static String sLocale {
        get {
            return UserInfo.getLocale(); 
        }
    } 
    
    public static String sFormatedLocale {
        get {
            Map<String, String> aResult;
            String[] aLocalBase = sLocale.split('_');
            if (aLocaleFormates.containsKey(sLocale)) {
                aResult = aLocaleFormates.get(sLocale);
            } else if (aLocale2Locale.containsKey(sLocale)) {
                aResult = aLocaleFormates.get(aLocale2Locale.get(sLocale));
            } else if (aLocaleFormates.containsKey(aLocalBase[0])) {
                aResult = aLocaleFormates.get(aLocalBase[0]);
            } else if (aLocale2Locale.containsKey(aLocalBase[0])) { 
                aResult = aLocaleFormates.get(aLocale2Locale.get(aLocalBase[0]));
            } else {
                aResult = aLocaleFormates.get('en');
            }

            String sCurrency = ( (1234.56).setScale(2)).format();
            aResult.put('coma', sCurrency.substring(1, 2) != '2' ? sCurrency.substring(1, 2) : '');
            aResult.put('dot', sCurrency.substring(sCurrency.length() - 3, sCurrency.length() - 2));
            return (String) JSON.serialize(aResult);
        }
    }
    
    public static String dateFormat{
        get{
            Map<String, String> mp = (Map<String, String>)JSON.deserialize(SL_RTR_LIB16_DateObject.sFormatedLocale, Map<String, String>.class);
            return mp.get('date');
        }
    }
    
    private static Map<String, Map<String, String>> aLocaleFormates = new Map<String, Map<String, String>>{
        'en' => new Map<String, String>{
            'time' => 'hh:ii:ss',
            'date' => 'mm/d/yyyy',
            'datetime' => 'mm/d/yyyy hh:ii:ss',
            'shortDatetime' => 'mm/d h(:ii)a',
            'fullDate' => 'mmmm dd, yyyy',
            'monthTitle'  => 'mmmm yyyy',
            'shortMonthTitle'  => 'mmm yyyy',
            'hourTitle' => 'h(:ii)a',
            'dateTitle' => 'mm/d'
        },
        'eu' => new Map<String, String>{
            'time' => 'hh:ii:ss',
            'date' => 'dd.mm.yyyy',
            'datetime' => 'dd.mm.yyyy hh:ii:ss',
            'shortDatetime' => 'dd.mm hh:ii',
            'fullDate' => 'dd mmmm yyyy',
            'monthTitle'  => 'mmmm yyyy',
            'shortMonthTitle'  => 'mmm yyyy',
            'hourTitle' => 'hh:ii',
            'dateTitle' => 'dd.mm'
        },
        'ar' => new Map<String, String>{
            'time' => 'hh:ii aa',
            'date' => 'dd/mm/yyyy',
            'datetime' => 'dd/mm/yyyy h(:ii) aa',
            'shortDatetime' => 'mm/d h(:ii) aa',
            'fullDate' => 'dd mmmm yyyy',
            'monthTitle'  => 'mmmm yyyy',
            'shortMonthTitle'  => 'mmm yyyy',
            'hourTitle' => 'h(:ii) aa',
            'dateTitle' => 'mm/d'
        },
        'ko' => new Map<String, String>{
            'time' => 'h:ii ',
            'date' => 'yyyy.d.m',
            'datetime' => 'yyyy.d.mm aa h(:ii)',
            'shortDatetime' => 'd.mm aa h(:ii)',
            'fullDate' => 'yyyy mmmm d ',
            'monthTitle'  => 'yyyy mmmm',
            'shortMonthTitle'  => 'yyyy mmm',
            'hourTitle' => 'aa h(:ii)',
            'dateTitle' => 'd.mm'
        },
        'nl' => new Map<String, String>{
            'time' => 'hh:ii ',
            'date' => 'd-mm-yyyy',
            'datetime' => 'd-mm-yyyy hh:ii',
            'shortDatetime' => 'd-m hh:ii',
            'fullDate' => 'd mmmm yyyy',
            'monthTitle'  => 'mmmm yyyy',
            'shortMonthTitle'  => 'mmm yyyy',
            'hourTitle' => 'hh:ii',
            'dateTitle' => 'd-m'
        },
        'pt' => new Map<String, String>{
            'time' => 'hh:ii ',
            'date' => 'dd-mm-yyyy',
            'datetime' => 'dd-mm-yyyy hh:ii',
            'shortDatetime' => 'dd-mm hh:ii',
            'fullDate' => 'dd mmmm yyyy',
            'monthTitle'  => 'mmmm yyyy',
            'shortMonthTitle'  => 'mmm yyyy',
            'hourTitle' => 'hh:ii',
            'dateTitle' => 'dd-mm'
        },
        'sk' => new Map<String, String>{
            'time' => 'hh:ii ',
            'date' => 'd.m.yyyy',
            'datetime' => 'd.m.yyyy hh:ii',
            'shortDatetime' => 'd.m hh:ii',
            'fullDate' => 'd mmmm yyyy',
            'monthTitle'  => 'mmmm yyyy',
            'shortMonthTitle'  => 'mmm yyyy',
            'hourTitle' => 'hh:ii',
            'dateTitle' => 'd.m'
        },
        'sl' => new Map<String, String>{
            'time' => 'hh:ii ',
            'date' => 'd.mm.yy',
            'datetime' => 'd.mm.yy hh:ii',
            'shortDatetime' => 'd.mm hh:ii',
            'fullDate' => 'd mmmm yy',
            'monthTitle'  => 'mmmm yy',
            'shortMonthTitle'  => 'mmm yy',
            'hourTitle' => 'hh:ii',
            'dateTitle' => 'd.mm'
        },
        'vi' => new Map<String, String>{
            'time' => 'hh:ii ',
            'date' => 'dd/mm/yyyy',
            'datetime' => 'hh:ii dd/mm/yyyy',
            'shortDatetime' => 'hh:ii dd/mm',
            'fullDate' => 'd mmmm yyyy',
            'monthTitle'  => 'mmmm yyyy',
            'shortMonthTitle'  => 'mmm yyyy',
            'hourTitle' => 'hh:ii',
            'dateTitle' => 'dd/mm'
        },
        'zh' => new Map<String, String>{
            'time' => 'aah(:ii)',
            'date' => 'yyyy-mm-d',
            'datetime' => 'yyyy-mm-d aah(:ii)',
            'shortDatetime' => 'mm-d aah(:ii)',
            'fullDate' => 'd mmmm yyyy',
            'monthTitle'  => 'mmmm yyyy',
            'shortMonthTitle'  => 'mmm yyyy',
            'hourTitle' => 'aah(:ii)',
            'dateTitle' => 'mm-d'
        },
        
        'e1_12' => new Map<String, String>{
            'time' => 'h(:ii) aa',
            'date' => 'd/mm/yy',
            'datetime' => 'd/mm/yyyy h(:ii) aa',
            'shortDatetime' => 'd/mm/yy h(:ii)a',
            'fullDate' => 'dd mmmm yyyy',
            'monthTitle'  => 'mmmm yyyy',
            'shortMonthTitle'  => 'mmm yyyy',
            'hourTitle' => 'h(:ii)a',
            'dateTitle' => 'd/mm'
       },
       'e1_24' => new Map<String, String>{
            'time' => 'hh:ii',
            'date' => 'dd/mm/yy',
            'datetime' => 'dd/mm/yyyy hh:ii',
            'shortDatetime' => 'dd/mm/yy hh:ii',
            'fullDate' => 'dd mmmm yyyy',
            'monthTitle'  => 'mmmm yyyy',
            'shortMonthTitle'  => 'mmm yyyy',
            'hourTitle' => 'hh:ii',
            'dateTitle' => 'dd/mm'
       },
       'e2_24' => new Map<String, String>{
            'time' => 'hh:ii',
            'date' => 'dd.mm.yy',
            'datetime' => 'dd.mm.yyyy hh:ii',
            'shortDatetime' => 'dd.mm.yy hh:ii',
            'fullDate' => 'dd mmmm yyyy',
            'monthTitle'  => 'mmmm yyyy',
            'shortMonthTitle'  => 'mmm yyyy',
            'hourTitle' => 'hh:ii',
            'dateTitle' => 'dd.mm'
       },
       'u1_12' => new Map<String, String>{
            'time' => 'h(:ii) aa',
            'date' => 'mm/d/yy',
            'datetime' => 'mm/d/yyyy h(:ii) aa',
            'shortDatetime' => 'mm/d/yy h(:ii)a',
            'fullDate' => 'mmmm d, yyyy',
            'monthTitle'  => 'mmmm yyyy',
            'shortMonthTitle'  => 'mmm yy',
            'hourTitle' => 'h(:ii)a',
            'dateTitle' => 'mm/d'
       },
       'u1_24' => new Map<String, String>{
            'time' => 'hh:ii',
            'date' => 'mm/d/yy',
            'datetime' => 'mm/d/yyyy hh:ii',
            'shortDatetime' => 'mm/d/yy hh:ii',
            'fullDate' => 'mmmm d, yyyy',
            'monthTitle'  => 'mmmm yyyy',
            'shortMonthTitle'  => 'mmm yyyy',
            'hourTitle' => 'hh:ii',
            'dateTitle' => 'mm/d'
       },
      'c1_24' => new Map<String, String>{
            'time' => 'hh:ii',
            'date' => 'yyyy-mm-dd',
            'datetime' => 'yyyy-mm-dd hh:ii',
            'shortDatetime' => 'yyyy-mm-dd h:ii',
            'fullDate' => 'dd mmmm yyyy',
            'monthTitle'  => 'mmmm yyyy',
            'shortMonthTitle'  => 'mmm yyyy',
            'hourTitle' => 'hh:ii',
            'dateTitle' => 'mm-dd'
       },
       'c1_12' => new Map<String, String>{
           'time' => 'h(:ii) aa',
            'date' => 'yyyy-mm-dd',
            'datetime' => 'yyyy-mm-dd h(:ii) aa',
            'shortDatetime' => 'yyyy-mm-dd h(:ii)a',
            'fullDate' => 'dd mmmm yyyy',
            'monthTitle'  => 'mmmm yyyy',
            'shortMonthTitle'  => 'mmm yyyy',
            'hourTitle' => 'h(:ii)a',
            'dateTitle' => 'mm-dd'
       },
       'c2_24' => new Map<String, String>{
            'time' => 'hh:ii',
            'date' => 'yyyy-dd-mm',
            'datetime' => 'yyyy-dd-mm hh:ii',
            'shortDatetime' => 'yyyy-dd-mm h:ii',
            'fullDate' => 'yyyy dd mmmm',
            'monthTitle'  => 'yyyy mmmm',
            'shortMonthTitle'  => 'yyyy mmm',
            'hourTitle' => 'hh:ii',
            'dateTitle' => 'dd-mm'
       },
       'iw' => new Map<String, String>{
            'time' => 'hh:ii',
            'date' => 'dd/mm/yy',
            'datetime' => 'hh:ii dd/mm/yyyy',
            'shortDatetime' => 'hh:ii dd/mm/yy',
            'fullDate' => 'dd mmmm yyyy',
            'monthTitle'  => 'mmmm yyyy',
            'shortMonthTitle'  => 'mmm yyyy',
            'hourTitle' => 'hh:ii',
            'dateTitle' => 'dd/mm'
       },
      'ja' => new Map<String, String>{
            'time' => 'hh:ii',
            'date' => 'yyyy/mm/dd',
            'datetime' => 'yyyy/mm/dd hh:ii',
            'shortDatetime' => 'yyyy/mm/dd h:ii',
            'fullDate' => 'yyyy mmmm dd',
            'monthTitle'  => 'yyyy mmmm',
            'shortMonthTitle'  => 'yyyy mmm',
            'hourTitle' => 'hh:ii',
            'dateTitle' => 'mm/dd'
        }
    };
    
    private static Map<String, String> aLocale2Locale = new Map<String, String>{
//        'fr' => 'eu',
//        'fi' => 'eu',
//        'hu' => 'eu',
//        'de' => 'eu',
//        'el' => 'eu',
//        'es' => 'eu',
//        'da' => 'eu',
//        'cs' => 'eu',
//        'ca' => 'eu',
//        'bg' => 'eu',
//        'is' => 'eu',
//        'it' => 'eu',
//        'ka' => 'eu',
//        'kk' => 'eu',
//        'no' => 'eu',
//        'pl' => 'eu',

//        'ro' => 'eu',
//        'ru' => 'eu',
//        'sh' => 'eu',
//        'tr' => 'eu',
//        'uk' => 'eu',
        
//        'sv' => 'pt',
        
//        'sr' => 'sk',
        
//        'th' => 'ar',
//        'tl' => 'ar',
//        'ur' => 'ar',
        
//        'js' => 'en',
        
        
        'is' => 'eu',
        'ur' => 'ar',
        'js' => 'en',
        'sh' => 'eu',
        'kk' => 'eu',
        
        
        
        'en_AU' => 'e1_12',
        'en_CA' => 'e1_12',
        'en_IN' => 'e1_12',
        'en_NZ' => 'e1_12',
        'es_CR' => 'e1_12',
        'es_GT' => 'e1_12',
        'es_MX' => 'e1_12',
        'ms_MY' => 'e1_12',
        'es_BO' => 'e1_12',
        'es_CL' => 'e1_12',
        'es_CO' => 'e1_12',
        'es_EC' => 'e1_12',
        'es_PE' => 'e1_12',
        'es_PY' => 'e1_12',
        'es_UY' => 'e1_12',
        'es_VE' => 'e1_12',
        'th' => 'e1_12',
        'th_TH' => 'e1_12',
        'ar' => 'e1_12',
        'ar_AE' => 'e1_12',
        'ar_BH' => 'e1_12',
        'ar_EG' => 'e1_12',
        'ar_JO' => 'e1_12',
        'ar_KW' => 'e1_12',
        'ar_LB' => 'e1_12',
        'ar_SA' => 'e1_12',
        'el' => 'e1_12',
        'el_GR' => 'e1_12',
        'en_GB' => 'e1_24',
        'en_IE' => 'e1_24',
        'iw' => 'iw',
        'iw_IL' => 'iw',
        'fr' => 'e1_24',
        'fr_FR' => 'e1_24',
        'fr_LU' => 'e1_24',
        'fr_MC' => 'e1_24',
        'ca' => 'e1_24',
        'ca_ES' => 'e1_24',
        'da' => 'e1_24',
        'da_DK' => 'e1_24',
        'es' => 'e1_24',
        'es_AR' => 'e1_24',
        'es_ES' => 'e1_24',
        'fr_BE' => 'e1_24',
        'in_ID' => 'e1_24',
        'nl' => 'e1_24',
        'nl_BE' => 'e1_24',
        'nl_NL' => 'e1_24',
        'nl_SR' => 'e1_24',
        'pt' => 'e1_24',
        'pt_AO' => 'e1_24',
        'pt_BR' => 'e1_24',
        'pt_PT' => 'e1_24',
        'vi' => 'e1_24',
        'vi_VN' => 'e1_24',
        'it' => 'e1_24',
        'it_IT' => 'e1_24',
        'no' => 'e2_24',
        'no_NO' => 'e2_24',
        'ru' => 'e2_24',
        'ru_RU' => 'e2_24',
        'de' => 'e2_24',
        'de_AT' => 'e2_24',
        'de_DE' => 'e2_24',
        'de_LU' => 'e2_24',
        'ro' => 'e2_24',
        'ro_RO' => 'e2_24',
        'tr' => 'e2_24',
        'tr_TR' => 'e2_24',
        'uk' => 'e2_24',
        'uk_UA' => 'e2_24',
        'de_CH' => 'e2_24',
        'fr_CH' => 'e2_24',
        'it_CH' => 'e2_24',
        'hr_HR' => 'e2_24',
        'sh' => 'e2_24',
        'sh_BA' => 'e2_24',
        'sh_CS' => 'e2_24',
        'et_EE' => 'e2_24',
        'sl_SI' => 'e2_24',
        'cs' => 'e2_24',
        'cs_CZ' => 'e2_24',
        'fi' => 'e2_24',
        'fi_FI' => 'e2_24',
        'sk' => 'e2_24',
        'sk_SK' => 'e2_24',
        'is_IS' => 'e2_24',
        'sr' => 'e2_24',
        'en_BB' => 'u1_12',
        'en_BM' => 'u1_12',
        'en_GH' => 'u1_12',
        'en_ID' => 'u1_12',
        'en_MY' => 'u1_12',
        'en_NG' => 'u1_12',
        'en_PH' => 'u1_12',
        'en_SG' => 'u1_12',
        'en_US' => 'u1_12',
        'en_ZA' => 'u1_12',
        'es_DO' => 'u1_12',
        'es_HN' => 'u1_12',
        'es_PA' => 'u1_12',
        'es_PR' => 'u1_12',
        'es_SVUS' => 'u1_12',
        'hy_AM' => 'u1_12',
        'ka' => 'u1_12',
        'ka_GE' => 'u1_12',
        'kk_KZ' => 'u1_12',
        'km_KH' => 'u1_12',
        'tl' => 'u1_12',
        'tl_PH' => 'u1_12',
        'ur_PK' => 'u1_12',
        'ja' => 'ja',
        'ja_JP' => 'ja',
        'bg' => 'u1_24',
        'bg_BG' => 'u1_24',
        'fr_CA' => 'c2_24',
        'pl' => 'u1_24',
        'sv' => 'c1_24',
        'sv_SE' => 'c1_24',
        'in' => 'u1_24',
        'sr_BA' => 'u1_24',
        'zh' => 'c1_12',
        'zh_CN' => 'c1_12',
        'ko' => 'c1_12',
        'ko_KR' => 'c1_12',
        'zh_TW' => 'c1_12',
        'zh_HK' => 'c1_12',
        'hu' => 'c1_24',
        'hu_HU' => 'c1_24',
        'lt_LT' => 'c1_24',
        'lv_LV' => 'c1_24'
    };
}
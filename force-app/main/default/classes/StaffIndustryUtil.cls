public class StaffIndustryUtil {
    public static String getStaffIndustry(Contact c){
        if(c.Department=='CF'){
            if(c.Industry_Group__c=='GEN - General' && (c.Office__c=='AM'||c.Office__c=='FF'||c.Office__c=='MD'||c.Office__c=='ML'||c.Office__c=='RO')){
                c.StaffIndustry__c='CEU';
            }else if(c.Industry_Group__c=='GEN - General' && (c.Office__c=='BE'||c.Office__c=='HK'||c.Office__c=='TK'||c.Office__c=='SG')){
                c.StaffIndustry__c='ASIA';
            }else if(c.Industry_Group__c=='GEN - General' && (c.Office__c=='SY')){
                c.StaffIndustry__c='SYD';
            }else if((c.Industry_Group__c=='GEN - General' && c.Office__c=='LO') || c.Industry_Group__c=='IFA - Illiquid Financial Assets' || c.Industry_Group__c=='FIG - Financial Institutions'){
                c.StaffIndustry__c='FIG';
            }else if((c.Industry_Group__c=='BUS - Business Services' || c.Industry_Group__c=='TRANS - Transportation & Logistics')){
                c.StaffIndustry__c='BUS';
            }else if(String.isNotBlank(c.Industry_Group__c) && (c.Industry_Group__c=='IG - Industrials' || c.Industry_Group__c.contains('ADG'))){
                c.StaffIndustry__c='IG';
            }else if((c.Industry_Group__c=='CORP - Corporate')){
                c.StaffIndustry__c='CORP';
            }else if((c.Industry_Group__c=='CFR - Consumer Food & Retail')){
                c.StaffIndustry__c='CFR';
            }else if((c.Industry_Group__c=='CM - Capital Markets')){
                c.StaffIndustry__c='CM';
            }else if((c.Industry_Group__c=='DA - Data & Analytics')){
                c.StaffIndustry__c='DA';
            }else if((c.Industry_Group__c=='TECH - Technology')){
                c.StaffIndustry__c='TECH';
            }else if((c.Industry_Group__c=='HC - Healthcare')){
                c.StaffIndustry__c='HC';
            }else if((c.Industry_Group__c=='M&A - Mergers & Acquisitions')){
                c.StaffIndustry__c='M&A';
            }else if((c.Industry_Group__c=='O&G - Oil & Gas')){
                c.StaffIndustry__c='O&G';
            }else if((c.Industry_Group__c=='PFG - Private Funds Group')){
                c.StaffIndustry__c='PFG';
            }else if((c.Industry_Group__c=='POW - Power & Utilities')){
                c.StaffIndustry__c='POW';
            }else if((c.Industry_Group__c=='RE - Real Estate Lodging and Leisure')){
                c.StaffIndustry__c='RE';
            }else if((c.Industry_Group__c=='TMT - Technology Media & Telecommunications')){
                c.StaffIndustry__c='TMT';
            }else{
                c.StaffIndustry__c='CORP';
            }
        }else if(c.Department=='FR'){
            if(c.Industry_Group__c=='O&G - Oil & Gas' || c.Office__c=='HO'){
                c.StaffIndustry__c='O&G';
            }else if(c.Industry_Group__c=='RE - Real Estate Lodging and Leisure'){
                c.StaffIndustry__c='RE';
            }else if(c.Industry_Group__c=='POW - Power & Utilities'){
                c.StaffIndustry__c='POW';
            }else {
                c.StaffIndustry__c='FR';
            }
        }else if(c.Department=='FVA'){
            if(c.Industry_Group__c=='O&G - Oil & Gas'){
                c.StaffIndustry__c='O&G';
            }else {
                c.StaffIndustry__c='FVA';
            }
        }else if(c.Department=='FSCG'){
            if(c.Industry_Group__c=='O&G - Oil & Gas'){
                c.StaffIndustry__c='O&G';
            }else {
                c.StaffIndustry__c='FSCG';
            }
        }
        if(c.Department!='CF' && c.Department!='FR' && c.Department!='FSCG' && c.Department!='FVA'){
            c.StaffIndustry__c='CORP';
        }
        return c.StaffIndustry__c;
    }
}
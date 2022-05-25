public with sharing class HL_InternalTeamModifyController {
    public Boolean ShowHeaderAndSideBar {get{
        return HL_PageUtility.GetParameter('showheader') <> null ? Boolean.valueOf(HL_PageUtility.GetParameter('showheader')) : true;
    } set;}
    public String SpecialRole {get; set;}
    public HL_InternalTeamModifyController(){
       SpecialRole = HL_PageUtility.GetParameter('specialRole');
        system.debug('SpecialRole'+SpecialRole);
    }
}
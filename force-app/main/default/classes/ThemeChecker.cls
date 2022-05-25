public with sharing class ThemeChecker {
    public static boolean isLightning(){
        String theme = UserInfo.getUiThemeDisplayed();
        
        if(theme=='Theme4d'||theme=='Theme4t'|| theme=='Theme4u'){
            return true;
        }else{
            return false;
        }
    }
}
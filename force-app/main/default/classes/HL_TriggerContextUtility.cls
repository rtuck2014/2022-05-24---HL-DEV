public with sharing class HL_TriggerContextUtility {
	private static boolean firstRun = true;
	//Used to prevent the Engagement Update Trigger from re-firing when updating the Z Fields
	public static boolean ByPassOnEIT = false;
	//Used to prevent the Engagement Internal Team Triggers from re-firing after the POCs are updated
	public static boolean ByPassOnPercentages = false;
	//Used to prevent the Monthly Revenue Process Control Mass Clear of the Current Revenue Accrual Lookup from re-firing all the engagement triggers
	public static boolean ByPassOnMonthlyRevenueProcess = false;

	public static boolean isFirstRun() {
	    return firstRun;
	}

	public static void setFirstRunFalse(){
	    firstRun = false;
	}

}
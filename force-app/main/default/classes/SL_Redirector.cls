public with sharing class SL_Redirector {

	private PageReference pgRef;

	public SL_Redirector(ApexPages.StandardController stdController) {	

		SL_Redirector__c cs = SL_Redirector__c.getInstance();

		if(cs != null && cs.Disable_Redirect__c) {
			Map<String, String> pageParams = ApexPages.currentPage().getParameters();

			String id = pageParams.get('id');
			if(id != null) {
				pgRef = new PageReference('/'+id+'/e'); 
			} else {
				if(ApexPages.currentPage().getURL().contains('MeetingNoteEvent')) {
					pgRef = new PageReference('/00U/e');
				} else {
					pgRef = new PageReference('/00T/e');
				}
			}

			pgRef.getParameters().putAll(pageParams);
			pgRef.getParameters().put('nooverride', '1');			
			pgRef.getParameters().remove('save_new');
		} 
		
	}

	public PageReference redirect() {
		if(pgRef != null) pgRef.setRedirect(true);
		return pgRef;
	
	}
}
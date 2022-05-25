public with sharing class HL_OffsiteTemplate_Update {
	private List<Offsite_Template__c> osToUpdate; // list received on instantiation of relationships to be updated
	private Id archiveRT;
	public HL_OffsiteTemplate_Update(List<Offsite_Template__c> osToUpdate) {
		this.osToUpdate = osToUpdate;
	}
	public List<Offsite_Template__c> UpdateAll()
	{
		archiveRT = HL_Utility.GetRecordTypeId('Offsite_Template__c', 'Archive');
		for(Offsite_Template__c os : this.osToUpdate)
			os.RecordTypeId = archiveRT;

		update osToUpdate;
		return osToUpdate;
	}
}
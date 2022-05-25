module.exports = function(prospectData){
	return {
		first_name: prospectData.firstName,
		last_name: prospectData.lastName,
		company: prospectData.company,
		crm_lead_fid: prospectData.crmLeadFid,
		crm_contact_fid: prospectData.crmContactFid,
		id: prospectData.id,
		email: prospectData.email
	}
}

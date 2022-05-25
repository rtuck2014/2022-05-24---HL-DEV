global class HL_Scheduler_OffsiteTemplateArchive implements Schedulable {
	global void execute(SchedulableContext sc) {
		HL_Batch_OffsiteTemplateArchive b = new HL_Batch_OffsiteTemplateArchive();
		Database.executeBatch(b, 200);
	}
}
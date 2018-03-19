global class ExpertAvailabilityBatchSchedular implements Schedulable {
	global void execute(SchedulableContext sc) {
		ExpertAvailabilityBatch expertAvailabilityBatch = new ExpertAvailabilityBatch();
		database.executebatch(expertAvailabilityBatch);
	}
}
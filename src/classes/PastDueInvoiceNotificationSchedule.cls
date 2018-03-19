global class PastDueInvoiceNotificationSchedule implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        PastDueInvoiceNotificationBatch batchInvoice = new PastDueInvoiceNotificationBatch();
        database.executeBatch(batchInvoice, 1);
    }
}
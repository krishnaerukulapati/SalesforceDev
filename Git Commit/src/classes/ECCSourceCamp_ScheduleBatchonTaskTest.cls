@isTest
private class ECCSourceCamp_ScheduleBatchonTaskTest {

    public static String CRON_EXP = '0 0 0 15 3 ? 2023';

    static testMethod void ECCSourceCampTaskTest() {
        String jobId = System.schedule('ECCSourceCamp_ScheduleBatchonTaskTest', CRON_EXP, new ECCSourceCamp_ScheduleBatchonTask());
         
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);

        System.assertEquals('2023-03-15 00:00:00', String.valueOf(ct.NextFireTime));
    }
}
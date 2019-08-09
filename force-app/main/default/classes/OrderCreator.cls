global class OrderCreator implements Database.Batchable <SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc){
        String query='SELECT Id FROM Contact LIMIT 5';

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Contact> scope){
        List<Order__c> orders = new List<Order__c>();

        if(scope.size() != 0){
            for (Contact contacts : scope) {
                for (Integer i = 0; i < 5; i++) {
                    Order__c newOrders = new Order__c (
                        Name = 'Order' + i,
                        Status__c = 'Draft',
                        Contact__c = contacts.Id
                    );
                    orders.add(newOrders);
                }
            }
            insert orders;
        }
    }

    global void finish(Database.BatchableContext bc){
        Integer countMinutes = Integer.valueOf(DateTime.now().addMinutes(5).minute());
        Boolean isCorrectMinute = Integer.valueOf(DateTime.now().minute()) > 54 ? false : true;
        Integer currentHour = isCorrectMinute == true ? Integer.valueOf(DateTime.now().hour()) : Integer.valueOf(DateTime.now().addHours(1).hour());
        String minutesCount = String.valueOf(countMinutes);
        String hourCurrent = String.valueOf(currentHour);
        String scheduleFormat = label.schedulerFormat;
        String scheduleParam = String.format(scheduleFormat, new List<String> {minutesCount, hourCurrent});

        List<CronTrigger> jobList = new List<CronTrigger>();
        jobList = [
            SELECT Id, CronJobDetail.Name
            FROM CronTrigger
            WHERE CronJobDetail.Name =: label.hourlyLabel
        ];

        for (CronTrigger job : jobList) {
            system.abortJob(job.id);
        }

        system.schedule(label.hourlyLabel, scheduleParam, new HourlyOrderCreator());
    }
}
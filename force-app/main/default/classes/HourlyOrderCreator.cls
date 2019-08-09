global class HourlyOrderCreator implements Schedulable {

    global void execute(SchedulableContext ctx) {
        OrderCreator orderCreator = new OrderCreator();
		Database.executeBatch(orderCreator);
    }
}
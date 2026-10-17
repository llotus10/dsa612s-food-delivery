import ballerina/log;
import ballerinax/kafka;

configurable string kafkaBootstrap = "localhost:9092";

listener kafka:Listener allEventsListener = new (kafkaBootstrap, {
    groupId: "notification-service-group",
    topics: [
        "orders.created", "orders.confirmed", "orders.ready",
        "payments.completed", "delivery.assigned", "delivery.completed"
    ],
    pollingInterval: 1,
    offsetReset: kafka:OFFSET_RESET_EARLIEST
});

service kafka:Service on allEventsListener {

    remote function onConsumerRecord(kafka:Caller caller, kafka:BytesConsumerRecord[] records) returns error? {
        foreach var rec in records {
            string valueStr = check string:fromBytes(rec.value);
            
            log:printInfo("[NOTIFICATION] payload=" + valueStr);
        }
        check caller->commit();
    }
}
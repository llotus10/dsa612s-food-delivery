import ballerina/log;
import ballerinax/kafka;

configurable string kafkaBootstrap = "localhost:9092";

final kafka:Producer restaurantProducer = check new (kafkaBootstrap, {
    clientId: "restaurant-service-producer"
});

listener kafka:Listener orderCreatedListener = new (kafkaBootstrap, {
    groupId: "restaurant-service-group",
    topics: ["orders.created"],
    pollingInterval: 1,
    offsetReset: kafka:OFFSET_RESET_EARLIEST
});

service kafka:Service on orderCreatedListener {

    remote function onConsumerRecord(kafka:BytesConsumerRecord[] records) returns error? {
        foreach var rec in records {
            string valueStr = check string:fromBytes(rec.value);
            log:printInfo("Restaurant received order: " + valueStr);

            check restaurantProducer->send({
                topic: "orders.confirmed",
                value: valueStr.toBytes()
            });
        }
    }
}
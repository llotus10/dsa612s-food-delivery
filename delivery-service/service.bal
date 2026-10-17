import ballerina/log;
import ballerinax/kafka;

configurable string kafkaBootstrap = "localhost:9092";

final kafka:Producer deliveryProducer = check new (kafkaBootstrap, {
    clientId: "delivery-service-producer"
});

listener kafka:Listener orderReadyListener = new (kafkaBootstrap, {
    groupId: "delivery-service-group",
    topics: ["orders.ready"],
    pollingInterval: 1,
    offsetReset: kafka:OFFSET_RESET_EARLIEST
});

service kafka:Service on orderReadyListener {

    remote function onConsumerRecord(kafka:Caller caller, kafka:BytesConsumerRecord[] records) returns error? {
        foreach var rec in records {
            string valueStr = check string:fromBytes(rec.value);
            log:printInfo("Delivery assigned for: " + valueStr);

            check deliveryProducer->send({
                topic: "delivery.assigned",
                value: valueStr.toBytes()
            });

            check deliveryProducer->send({
                topic: "delivery.completed",
                value: valueStr.toBytes()
            });
        }
        check caller->commit();
    }
}
import ballerina/http;
import ballerina/log;
import ballerina/uuid;
import ballerinax/kafka;

type PaymentRequest record {|
    string orderId;
    decimal amount;
|};

type PaymentCompletedEvent record {|
    string orderId;
    string paymentId;
    decimal amount;
    string status;
|};

configurable string kafkaBootstrap = "localhost:9092";

final kafka:Producer paymentProducer = check new (kafkaBootstrap, {
    clientId: "payment-service-producer"
});

service /payments on new http:Listener(8082) {

    resource function post process(PaymentRequest request) returns string|error {
        string paymentId = uuid:createRandomUuid();

        PaymentCompletedEvent event = {
            orderId: request.orderId,
            paymentId: paymentId,
            amount: request.amount,
            status: "COMPLETED"
        };

        check paymentProducer->send({
            topic: "payments.completed",
            value: event.toJsonString().toBytes()
        });

        log:printInfo("Payment processed: " + paymentId);
        return "Payment processed: " + paymentId;
    }
}
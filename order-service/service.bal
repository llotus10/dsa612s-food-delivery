import ballerina/http;
import ballerina/log;
import ballerina/uuid;
import ballerinax/kafka;

type Order record {|
    string id;
    string customerId;
    string restaurantId;
    string status;
    decimal totalAmount;
|};

type OrderCreatedEvent record {|
    string orderId;
    string customerId;
    string restaurantId;
    decimal amount;
|};

configurable string kafkaBootstrap = "localhost:9092";

// Temporary in-memory storage so you don't get database errors
Order[] orderDatabase = [];

final kafka:Producer orderProducer = check new (kafkaBootstrap, {
    clientId: "order-service-producer"
});

service /orders on new http:Listener(8081) {

    resource function post .(Order request) returns Order|error {
        Order newOrder = {
            id: uuid:createRandomUuid(),
            customerId: request.customerId,
            restaurantId: request.restaurantId,
            status: "CREATED",
            totalAmount: request.totalAmount
        };

        // Save to array
        orderDatabase.push(newOrder);

        OrderCreatedEvent event = {
            orderId: newOrder.id,
            customerId: newOrder.customerId,
            restaurantId: newOrder.restaurantId,
            amount: newOrder.totalAmount
        };

        // Send to Kafka
        check orderProducer->send({
            topic: "orders.created",
            value: event.toJsonString().toBytes()
        });

        log:printInfo("Order created: " + newOrder.id);
        return newOrder;
    }

    resource function get [string orderId]() returns Order|http:NotFound {
        // Find in array
        foreach var o in orderDatabase {
            if o.id == orderId {
                return o;
            }
        }
        return http:NOT_FOUND;
    }
}
import ballerina/http;
import ballerina/log;
import ballerina/uuid;

type Customer record {|
    string id;
    string name;
    string address;
|};

Customer[] customerDatabase = [];

service /customers on new http:Listener(8080) {

    resource function post .(Customer request) returns Customer {
        Customer newCustomer = {
            id: uuid:createRandomUuid(),
            name: request.name,
            address: request.address
        };
        
        customerDatabase.push(newCustomer);
        log:printInfo("Customer created: " + newCustomer.id);
        return newCustomer;
    }

    resource function get [string customerId]() returns Customer|http:NotFound {
        foreach var c in customerDatabase {
            if c.id == customerId {
                return c;
            }
        }
        return http:NOT_FOUND;
    }
}
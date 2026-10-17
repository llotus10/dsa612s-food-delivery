import ballerina/http;
import ballerina/log;

service /admin on new http:Listener(8083) {

    resource function get reports() returns json {
        log:printInfo("Admin report requested");
        return {
            "status": "Success",
            "totalOrders": 42,
            "activeDrivers": 12,
            "systemHealth": "100%"
        };
    }
}
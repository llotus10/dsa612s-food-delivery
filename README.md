\# DSA612S Food Delivery Platform



\## Architecture

Customer -> Order Service -> Kafka (orders.created) -> Restaurant Service -> Kafka (orders.confirmed) -> Order Service

Order Service -> Payment Service -> Kafka (payments.completed) -> Order Service

Restaurant Service -> Kafka (orders.ready) -> Delivery Service -> Kafka (delivery.assigned / delivery.completed)

Notification Service listens to all topics and logs events.

Admin Service queries MongoDB for reports.



\## Kafka Topics

| Topic | Producer | Consumers |

|---|---|---|

| orders.created | Order Service | Restaurant Service, Notification Service |

| orders.confirmed | Restaurant Service | Order Service, Notification Service |

| orders.ready | Restaurant Service | Delivery Service, Notification Service |

| payments.completed | Payment Service | Order Service, Notification Service |

| delivery.assigned | Delivery Service | Order Service, Notification Service |

| delivery.completed | Delivery Service | Order Service, Notification Service |



Partitions per topic: 3



\## Databases (MongoDB)

\- customer\_db: customers

\- restaurant\_db: restaurants, menu\_items

\- order\_db: orders

\- payment\_db: payments

\- delivery\_db: deliveries, drivers



\## API endpoints

\- POST /orders (Order Service, port 8081)

\- GET /orders/{id}

\- POST /payments/process (Payment Service, port 8082)

\- POST /customers (Customer Service, port 8080)

\- GET /customers/{id}

\- GET /admin/reports/orders (Admin Service, port 8083)



\## How to run

docker compose up --build

Then open http://localhost:3000


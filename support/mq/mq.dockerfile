FROM rabbitmq:3.8-alpine

COPY rabbitmq.conf /etc/rabbitmq/rabbitmq.conf
COPY definitions.json /etc/rabbitmq/definitions.json

RUN chown rabbitmq:rabbitmq /etc/rabbitmq/rabbitmq.conf
RUN chown rabbitmq:rabbitmq /etc/rabbitmq/definitions.json
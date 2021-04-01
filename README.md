# Change Capture Example

Using Debezium to capture change events from PostgreSQL

## To run the db
1. `cd support`
2. `docker-compose up`

## to run the application
1. `./gradlew clean shadowjar`
2. `java -jar ./build/libs/change-capture-0.1-all.jar capture`
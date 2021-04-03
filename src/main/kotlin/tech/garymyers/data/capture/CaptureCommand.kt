package tech.garymyers.data.capture

import io.debezium.config.Configuration
import io.debezium.engine.ChangeEvent
import io.debezium.engine.DebeziumEngine
import io.debezium.engine.format.CloudEvents
import io.micronaut.context.annotation.Value
import picocli.CommandLine.Command
import java.util.concurrent.CountDownLatch
import java.util.function.Consumer
import javax.inject.Inject

@Command(
    name = "capture",
    description = ["Capture events coming from PostgreSQL"]
)
class CaptureCommand @Inject constructor(
    @Value("\${cdc.db.host}") private var host: String,
    @Value("\${cdc.db.port}") private var port: String,
    @Value("\${datasources.default.username}") private var username: String,
    @Value("\${datasources.default.password}") private var password: String,
    @Value("\${cdc.db.database}") private var database: String,
): Runnable {
    override fun run() {
        val countDownLatch = CountDownLatch(1)
        val configuration = Configuration.create()
            .with("name", "change-capture-connector")
            .with("connector.class", "io.debezium.connector.postgresql.PostgresConnector")
            .with("offset.storage",  "org.apache.kafka.connect.storage.FileOffsetBackingStore")
            .with("offset.storage.file.filename", "/tmp/cdc-offset.dat")
            .with("offset.flush.interval.ms", 1000)
            .with("plugin.name", "pgoutput")
            .with("database.server.name", "$host-$database")
            .with("database.hostname", host)
            .with("database.port", port)
            .with("database.user", username)
            .with("database.password", password)
            .with("database.dbname", database)
            .build()

        val engine = DebeziumEngine.create(CloudEvents::class.java).using(configuration.asProperties())
            .notifying(Consumer<ChangeEvent<String, String>> {
                if (!it.destination().contains("flyway") && !it.destination().endsWith("type_domain")) {
                    println(it.value())
                }
            }).build()

        val engineThread = Thread(engine)
        engineThread.isDaemon = true
        engineThread.start()

        Runtime.getRuntime().addShutdownHook(Thread {
            countDownLatch.countDown()
        })

        countDownLatch.await()
        engine.close()
    }
}
package tech.garymyers.data

import io.micronaut.configuration.picocli.PicocliRunner

import picocli.CommandLine.Command
import picocli.CommandLine.Option
import tech.garymyers.data.capture.CaptureCommand
import tech.garymyers.data.create.CreateCommand

@Command(
    name = "change-capture",
    description = ["Example Postresql change data capture tool"],
    mixinStandardHelpOptions = true,
    subcommands = [
        CreateCommand::class,
        CaptureCommand::class,
    ]
)
class ChangeCaptureCommand : Runnable {
    override fun run() {

    }

    companion object {
        @JvmStatic fun main(args: Array<String>) {
            PicocliRunner.run(ChangeCaptureCommand::class.java, *args)
        }
    }
}

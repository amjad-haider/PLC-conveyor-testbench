using ConveyorMonitor.Modbus;

const string plcHost = "127.0.0.1";
const int plcPort = 1502;

try
{
    Console.WriteLine("Connecting to OpenPLC Runtime...");

    var modbus = new ModbusTcpClient(
        plcHost,
        plcPort
    );

    // Read motor status from coil address 0
    bool motorEnabled = await modbus.ReadCoilAsync(0);

    Console.WriteLine("Connected successfully.");

    Console.WriteLine();
    Console.WriteLine("=== Conveyor Monitor ===");

    Console.WriteLine($"PLC Address : {plcHost}:{plcPort}");

    Console.WriteLine(
        $"Motor Status: {(motorEnabled ? "ON" : "OFF")}");
}
catch (Exception ex)
{
    Console.Error.WriteLine(
        $"Communication error: {ex.Message}");

    Environment.ExitCode = 1;
}
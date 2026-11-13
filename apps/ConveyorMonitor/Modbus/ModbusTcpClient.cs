using System.IO;
using System.Net.Sockets;

namespace ConveyorMonitor.Modbus;

public sealed class ModbusTcpClient
{
    private readonly string _host;
    private readonly int _port;
    private readonly byte _unitId;

    private static readonly TimeSpan Timeout =
        TimeSpan.FromSeconds(3);

    public ModbusTcpClient(
        string host,
        int port = 502,
        byte unitId = 1)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(host);
        ArgumentOutOfRangeException.ThrowIfNegativeOrZero(port);

        if (port > 65535)
            throw new ArgumentOutOfRangeException(nameof(port));

        _host = host;
        _port = port;
        _unitId = unitId;
    }

    public async Task<bool> ReadCoilAsync(
        ushort address,
        CancellationToken cancellationToken = default)
    {
        using var timeout =
            CancellationTokenSource.CreateLinkedTokenSource(
                cancellationToken);

        timeout.CancelAfter(Timeout);

        try
        {
            using var client = new TcpClient();

            await client.ConnectAsync(
                _host,
                _port,
                timeout.Token);

            using NetworkStream stream = client.GetStream();

            // Modbus TCP request: Read one coil
            byte[] request =
            [
                0x00, 0x01,              // Transaction ID
                0x00, 0x00,              // Protocol ID
                0x00, 0x06,              // Message length
                _unitId,                // Unit ID
                0x01,                   // Function: Read Coils
                (byte)(address >> 8),   // Address high byte
                (byte)(address & 0xFF), // Address low byte
                0x00, 0x01              // Quantity: one coil
            ];

            await stream.WriteAsync(request, timeout.Token);

            // Read Modbus TCP header (7 bytes)
            byte[] header = new byte[7];

            await stream.ReadExactlyAsync(
                header,
                timeout.Token);

            int transactionId = (header[0] << 8) | header[1];
            int protocolId = (header[2] << 8) | header[3];
            int length = (header[4] << 8) | header[5];

            // Validate response header
            if (transactionId != 1 ||
                protocolId != 0 ||
                header[6] != _unitId ||
                length < 3 ||
                length > 254)
            {
                throw new IOException(
                    "Invalid Modbus TCP response header.");
            }

            // Read response data
            byte[] pdu = new byte[length - 1];

            await stream.ReadExactlyAsync(
                pdu,
                timeout.Token);

            // Handle Modbus exception response
            if (pdu.Length == 2 && pdu[0] == 0x81)
            {
                throw new IOException(
                    $"Modbus exception: 0x{pdu[1]:X2}");
            }

            // Validate Read Coils response
            if (pdu.Length != 3 ||
                pdu[0] != 0x01 ||
                pdu[1] != 0x01)
            {
                throw new IOException(
                    "Unexpected Modbus response.");
            }

            // Extract the first coil's value
            return (pdu[2] & 0x01) != 0;
        }
        catch (OperationCanceledException)
            when (!cancellationToken.IsCancellationRequested)
        {
            throw new TimeoutException(
                "Modbus request timed out after 3 seconds.");
        }
    }
}
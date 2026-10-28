# PLC Conveyor Testbench

[Deutsch](README.de.md)

A small conveyor-control testbench built around an IEC 61131-3 Structured Text program. The project covers PLC control logic, fault handling, Modbus TCP communication and automated checks from a C# application.

The aim is to keep the control program independent of the monitoring client and make its behavior easy to reproduce without physical PLC hardware.

**Status:** Initial design. The controller and communication client have not been implemented or validated yet.

## Scope

The first version models a single conveyor section with one item in transit at a time.

| Signal | Direction | Purpose |
| --- | --- | --- |
| Start / Stop | Input | Operator commands |
| Entry sensor | Input | Detect an arriving item |
| Exit sensor | Input | Confirm an item has left the conveyor |
| Simulated emergency-stop input | Input | Force the motor command off and latch a fault |
| Reset | Input | Acknowledge a fault once its cause is cleared |
| Motor enable | Output | Conveyor motor command |
| State / fault code | Output | Diagnostics |
| Item count | Output | Count completed transfers |

The PLC logic is planned as a state machine (`IDLE`, `RUNNING`, `FAULT`) with separate function blocks for conveyor control and timeout monitoring. An entry event starts a transfer; an exit event completes it. If the item does not reach the exit sensor before the configured timeout, the controller enters the fault state and switches the motor command off.

## Technology

- **PLC logic:** IEC 61131-3 Structured Text (ST)
- **Development and simulation:** OpenPLC Editor v4
- **PLC runtime for integration:** OpenPLC Runtime v4
- **Communication:** Modbus TCP
- **Monitoring and test client:** C# / .NET 10, NModbus
- **Automated tests:** xUnit

The C# application is an external Modbus client, not part of the PLC's control cycle.

## Planned layout

```text
plc-conveyor-testbench/
├── plc/                     # OpenPLC project and ST source
├── src/PlcMonitor/          # C# Modbus client
├── tests/PlcMonitor.Tests/  # Automated tests
├── docs/                    # I/O map, states, test cases and results
├── README.md
└── README.de.md
```

Only the documentation is present at the initial commit. The folders will be added with their first source files.

## Implementation plan

1. Define the I/O signals and state transitions.
2. Implement the controller in Structured Text and test it in the OpenPLC Editor simulator.
3. Configure the OpenPLC Runtime v4 Modbus interface and document the verified register mapping.
4. Build the C# client to read status and issue test commands.
5. Automate normal-operation and fault scenarios; record actual results.

**Initial test targets (not measured results):** configurable 3 s transfer timeout, nominal 20 ms PLC task period, 100 ms client polling interval and at least 15 test scenarios. Timing behavior will be measured rather than assumed.


## References

- OpenPLC Editor and Runtime v4 documentation
- IEC 61131-3 — programmable-controller programming languages
- Modbus Application Protocol Specification

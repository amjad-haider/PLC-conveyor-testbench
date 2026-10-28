# PLC Conveyor Testbench

[English](README.md) 

Ein Testsystem für die Steuerung einer Förderstrecke mit IEC 61131-3 Structured Text. Das Projekt behandelt SPS-Steuerungslogik, Fehlerbehandlung, Modbus-TCP-Kommunikation und automatisierte Prüfungen über eine C#-Anwendung.

Die Steuerungslogik soll unabhängig vom Diagnoseprogramm laufen. Entwicklung und Tests sind zunächst ohne physische SPS-Hardware vorgesehen.

**Stand:** Konzeptphase. Steuerungsprogramm und Kommunikationsclient sind noch nicht implementiert oder validiert.

## Funktionsumfang

Die erste Version bildet eine einzelne Förderstrecke ab. Es befindet sich jeweils maximal ein Werkstück im Transport.

| Signal | Richtung | Funktion |
| --- | --- | --- |
| Start / Stopp | Eingang | Bedienbefehle |
| Eingangssensor | Eingang | Erkennt ein ankommendes Werkstück |
| Ausgangssensor | Eingang | Bestätigt das Verlassen der Förderstrecke |
| Simulierter Not-Halt-Eingang | Eingang | Schaltet den Motorbefehl ab und verriegelt einen Fehler |
| Reset | Eingang | Quittiert einen Fehler nach Behebung der Ursache |
| Motorfreigabe | Ausgang | Ansteuerung des Fördermotors |
| Zustand / Fehlercode | Ausgang | Diagnoseinformationen |
| Stückzähler | Ausgang | Zählt abgeschlossene Transporte |

Die Steuerung wird als Zustandsautomat (`IDLE`, `RUNNING`, `FAULT`) aufgebaut. Für Förderbandsteuerung und Zeitüberwachung sind getrennte Funktionsbausteine vorgesehen. Ein Signal am Eingangssensor startet die Transportüberwachung. Ein Signal am Ausgangssensor schließt den Transport ab. Wird die eingestellte Zeit überschritten, wechselt die Steuerung in den Fehlerzustand und schaltet die Motorfreigabe ab.

## Technologien

- **SPS-Programmierung:** IEC 61131-3 Structured Text (ST)
- **Entwicklung und Simulation:** OpenPLC Editor v4
- **SPS-Laufzeit für die Integration:** OpenPLC Runtime v4
- **Kommunikation:** Modbus TCP
- **Diagnose- und Testanwendung:** C# / .NET 10, NModbus
- **Automatisierte Tests:** xUnit

Die C#-Anwendung greift als externer Modbus-Client auf die SPS zu und ist nicht Teil des zyklischen Steuerungsprogramms.

## Geplante Projektstruktur

```text
plc-conveyor-testbench/
├── plc/                     # OpenPLC-Projekt und ST-Quellcode
├── src/PlcMonitor/          # C#-Modbus-Client
├── tests/PlcMonitor.Tests/  # Automatisierte Tests
├── docs/                    # E/A-Zuordnung, Zustände, Testfälle und Ergebnisse
├── README.md
└── README.de.md
```

Beim ersten Commit sind nur die Dokumentationsdateien vorhanden. Die Verzeichnisse entstehen mit den jeweiligen Quelldateien.

## Umsetzung

1. E/A-Signale und Zustandsübergänge festlegen.
2. Steuerung in Structured Text implementieren und im OpenPLC-Editor-Simulator prüfen.
3. Modbus-Schnittstelle der OpenPLC Runtime v4 konfigurieren und die tatsächlich verwendete Registerzuordnung dokumentieren.
4. C#-Client für Statusabfragen und Testbefehle entwickeln.
5. Normalbetrieb und Fehlerfälle automatisiert prüfen; Messergebnisse dokumentieren.

**Erste Testziele (keine Messergebnisse):** einstellbare Transportzeitüberwachung von 3 s, nominelle SPS-Zykluszeit von 20 ms, Client-Abfrageintervall von 100 ms und mindestens 15 Testszenarien. Das tatsächliche Zeitverhalten wird gemessen.


## Referenzen

- Dokumentation zu OpenPLC Editor und Runtime v4
- IEC 61131-3 — Programmiersprachen für speicherprogrammierbare Steuerungen
- Modbus Application Protocol Specification

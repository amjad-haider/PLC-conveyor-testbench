PROGRAM main
VAR
    (* Operator inputs *)
    xStart          : BOOL := FALSE;
    xStop           : BOOL := FALSE;
    xReset          : BOOL := FALSE;
    xEmergencyStop  : BOOL := FALSE;

    (* Controller outputs *)
    xMotorEnable    : BOOL := FALSE;
    iState          : INT := 0;
    iFaultCode      : INT := 0;

    (* Rising-edge detectors *)
    fbStartEdge     : R_TRIG;
    fbResetEdge     : R_TRIG;

    (* Conveyor sensors *)
    xEntrySensor     : BOOL := FALSE;
    xExitSensor      : BOOL := FALSE;

    (* Product tracking *)
    xItemInTransit   : BOOL := FALSE;
    udiItemCount     : UDINT := 0;

    (* Sensor edge detection *)
    fbEntryEdge      : R_TRIG;
    fbExitEdge       : R_TRIG;

    (* Jam detection *)
    fbJamMonitor : FB_JamMonitor;
    tJamTimeout  : TIME := T#3s;

END_VAR

(* Detect rising edges *)
fbStartEdge(CLK := xStart);
fbResetEdge(CLK := xReset);


(* Emergency-stop simulation has highest priority *)
IF xEmergencyStop THEN

    iState := 2;
    iFaultCode := 2;


(* Handle latched fault state *)
ELSIF iState = 2 THEN

    IF fbResetEdge.Q THEN
        iState := 0;
        iFaultCode := 0;
    END_IF;


(* Normal state-machine operation *)
ELSE

    CASE iState OF

        0:  (* IDLE *)

            IF fbStartEdge.Q AND NOT xStop THEN
                iState := 1;
            END_IF;


        1:  (* RUNNING *)

            IF xStop THEN
                iState := 0;
            END_IF;


        ELSE
            (* Invalid controller state *)
            iState := 2;
            iFaultCode := 3;

    END_CASE;

END_IF;

(* Detect sensor rising edges *)
fbEntryEdge(CLK := xEntrySensor);
fbExitEdge(CLK := xExitSensor);


(* Conveyor product tracking *)
IF (iState = 1) AND NOT xStop AND NOT xEmergencyStop THEN

    (* Product has reached the exit *)
    IF fbExitEdge.Q AND xItemInTransit THEN

        udiItemCount := udiItemCount + 1;
        xItemInTransit := FALSE;

    (* New product detected at entry *)
    ELSIF fbEntryEdge.Q AND NOT xItemInTransit THEN

        xItemInTransit := TRUE;

    END_IF;

ELSE

    (* Discard incomplete transfer when conveyor stops *)
    xItemInTransit := FALSE;

END_IF;

(* Execute jam monitoring function block *)
fbJamMonitor(
    xEnable := (iState = 1)
               AND NOT xStop
               AND NOT xEmergencyStop,

    xItemInTransit := xItemInTransit,
    tTimeout := tJamTimeout
);


(* Handle conveyor jam *)
IF fbJamMonitor.xJamDetected AND (iState = 1) THEN

    iState := 2;
    iFaultCode := 1;

    (* Cancel incomplete transfer *)
    xItemInTransit := FALSE;

END_IF;

(* Motor output *)
xMotorEnable :=
    (iState = 1)
    AND NOT xStop
    AND NOT xEmergencyStop;

END_PROGRAM
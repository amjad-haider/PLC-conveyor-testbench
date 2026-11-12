PROGRAM main
VAR
    (* Operator inputs *)
    xStart          : BOOL := FALSE;
    xStop           : BOOL := FALSE;
    xReset          : BOOL := FALSE;
    xEmergencyStop  : BOOL := FALSE;

    (* Conveyor sensors *)
    xEntrySensor    : BOOL := FALSE;
    xExitSensor     : BOOL := FALSE;

    (* Controller status *)
    xMotorEnable    : BOOL := FALSE;
    iState          : INT := 0;
    iFaultCode      : INT := 0;

    (* Product tracking *)
    xItemInTransit  : BOOL := FALSE;
    udiItemCount    : UDINT := 0;

    (* Configuration *)
    tJamTimeout     : TIME := T#3s;

    (* Function block instances *)
    fbConveyor      : FB_Conveyor;
    fbItemTracker   : FB_ItemTracker;
    fbJamMonitor    : FB_JamMonitor;

END_VAR

(* Product tracking *)
fbItemTracker(
    xRunEnable := (iState = 1)
                  AND NOT xStop
                  AND NOT xEmergencyStop,

    xEntrySensor := xEntrySensor,
    xExitSensor := xExitSensor
);

xItemInTransit := fbItemTracker.xItemInTransit;
udiItemCount := fbItemTracker.udiItemCount;


(* Transfer timeout supervision *)
fbJamMonitor(
    xEnable := (iState = 1)
               AND NOT xStop
               AND NOT xEmergencyStop,

    xItemInTransit := xItemInTransit,
    tTimeout := tJamTimeout
);


(* Conveyor state machine *)
fbConveyor(
    xStart := xStart,
    xStop := xStop,
    xReset := xReset,
    xEmergencyStop := xEmergencyStop,
    xJamDetected := fbJamMonitor.xJamDetected
);


(* Update controller status *)
iState := fbConveyor.iState;
iFaultCode := fbConveyor.iFaultCode;
xMotorEnable := fbConveyor.xMotorEnable;


(* Clear diagnostic transfer status when stopped *)
IF iState <> 1 THEN
    xItemInTransit := FALSE;
END_IF;

END_PROGRAM
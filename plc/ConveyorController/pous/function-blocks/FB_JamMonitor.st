FUNCTION_BLOCK FB_JamMonitor
VAR_INPUT
    xEnable         : BOOL;
    xItemInTransit  : BOOL;
    tTimeout        : TIME := T#3s;
END_VAR

VAR_OUTPUT
    xJamDetected    : BOOL;
    tElapsed        : TIME;
END_VAR

VAR
    fbTimer         : TON;
END_VAR

(* Conveyor transfer timeout supervision *)

fbTimer(
    IN := xEnable AND xItemInTransit,
    PT := tTimeout
);

(* Output signals *)
xJamDetected := fbTimer.Q;
tElapsed := fbTimer.ET;

END_FUNCTION_BLOCK
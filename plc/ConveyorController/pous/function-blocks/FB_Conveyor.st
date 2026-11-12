FUNCTION_BLOCK FB_Conveyor
VAR_INPUT
    xStart          : BOOL;
    xStop           : BOOL;
    xReset          : BOOL;
    xEmergencyStop  : BOOL;
    xJamDetected    : BOOL;
END_VAR

VAR_OUTPUT
    xMotorEnable    : BOOL := FALSE;
    iState          : INT := 0;
    iFaultCode      : INT := 0;
END_VAR

VAR
    fbStartEdge     : R_TRIG;
    fbResetEdge     : R_TRIG;
END_VAR

(* Detect operator command edges *)
fbStartEdge(CLK := xStart);
fbResetEdge(CLK := xReset);


(* Simulated emergency stop has highest priority *)
IF xEmergencyStop THEN

    iState := 2;
    iFaultCode := 2;


(* Handle latched fault *)
ELSIF iState = 2 THEN

    IF fbResetEdge.Q AND NOT xJamDetected THEN

        iState := 0;
        iFaultCode := 0;

    END_IF;


(* Handle conveyor jam *)
ELSIF xJamDetected AND (iState = 1) THEN

    iState := 2;
    iFaultCode := 1;


(* Normal operating states *)
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

            (* Invalid state *)
            iState := 2;
            iFaultCode := 3;

    END_CASE;

END_IF;


(* Motor command *)
xMotorEnable :=
    (iState = 1)
    AND NOT xStop
    AND NOT xEmergencyStop
    AND NOT xJamDetected;

END_FUNCTION_BLOCK
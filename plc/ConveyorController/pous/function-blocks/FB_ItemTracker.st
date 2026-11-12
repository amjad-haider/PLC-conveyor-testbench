FUNCTION_BLOCK FB_ItemTracker
VAR_INPUT
    xRunEnable       : BOOL;
    xEntrySensor     : BOOL;
    xExitSensor      : BOOL;
END_VAR

VAR_OUTPUT
    xItemInTransit    : BOOL := FALSE;
    udiItemCount      : UDINT := 0;
END_VAR

VAR
    fbEntryEdge       : R_TRIG;
    fbExitEdge        : R_TRIG;
END_VAR

(* Detect sensor rising edges *)
fbEntryEdge(CLK := xEntrySensor);
fbExitEdge(CLK := xExitSensor);


(* Product tracking *)
IF xRunEnable THEN

    (* Complete an active transfer *)
    IF fbExitEdge.Q AND xItemInTransit THEN

        udiItemCount := udiItemCount + 1;
        xItemInTransit := FALSE;

    (* Register a new product *)
    ELSIF fbEntryEdge.Q AND NOT xItemInTransit THEN

        xItemInTransit := TRUE;

    END_IF;

ELSE

    (* Discard incomplete transfer when disabled *)
    xItemInTransit := FALSE;

END_IF;

END_FUNCTION_BLOCK
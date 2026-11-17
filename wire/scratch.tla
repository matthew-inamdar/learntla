---- MODULE scratch ----
EXTENDS TLC, Integers, Sequences

ClockType == (0..23) \X (0..59) \X (0..59)

/* Converts a clock set to seconds
ToSeconds(time) == time[1]*3600 + time[2]*60 + time[3]

/* Converts seconds to a clock set
ToClock(seconds) == CHOOSE x \in ClockType: ToSeconds(x) = seconds % 86400

Eval == ToClock(86401)
====
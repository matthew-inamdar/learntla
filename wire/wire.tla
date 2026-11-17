---- MODULE wire ----
EXTENDS TLC, Integers

People == {"alice", "bob"}
Money == 1..10

(*--algorithm wire
variables
    acct \in [People -> Money];

define
    NoOverdrafts == \A p \in People:
        acct[p] >= 0
end define;

process wire \in {1,2}
variable
amnt \in 1..5;
from \in People;
to \in People;
begin
    Check:
        if acct[from] >= amnt then
            Withdraw:
                acct[from] := acct[from] - amnt;
            Deposit:
                acct[to] := acct[to] + amnt;
        end if;
end process;

end algorithm;
*)
\* BEGIN TRANSLATION (chksum(pcal) = "521c0dc9" /\ chksum(tla) = "dd81df78")
VARIABLES pc, acct

(* define statement *)
NoOverdrafts == \A p \in People:
    acct[p] >= 0

VARIABLES amnt, from, to

vars == << pc, acct, amnt, from, to >>

ProcSet == ({1,2})

Init == (* Global variables *)
        /\ acct \in [People -> Money]
        (* Process wire *)
        /\ amnt \in [{1,2} -> 1..5]
        /\ from \in [{1,2} -> People]
        /\ to \in [{1,2} -> People]
        /\ pc = [self \in ProcSet |-> "Check"]

Check(self) == /\ pc[self] = "Check"
               /\ IF acct[from[self]] >= amnt[self]
                     THEN /\ pc' = [pc EXCEPT ![self] = "Withdraw"]
                     ELSE /\ pc' = [pc EXCEPT ![self] = "Done"]
               /\ UNCHANGED << acct, amnt, from, to >>

Withdraw(self) == /\ pc[self] = "Withdraw"
                  /\ acct' = [acct EXCEPT ![from[self]] = acct[from[self]] - amnt[self]]
                  /\ pc' = [pc EXCEPT ![self] = "Deposit"]
                  /\ UNCHANGED << amnt, from, to >>

Deposit(self) == /\ pc[self] = "Deposit"
                 /\ acct' = [acct EXCEPT ![to[self]] = acct[to[self]] + amnt[self]]
                 /\ pc' = [pc EXCEPT ![self] = "Done"]
                 /\ UNCHANGED << amnt, from, to >>

wire(self) == Check(self) \/ Withdraw(self) \/ Deposit(self)

(* Allow infinite stuttering to prevent deadlock on termination. *)
Terminating == /\ \A self \in ProcSet: pc[self] = "Done"
               /\ UNCHANGED vars

Next == (\E self \in {1,2}: wire(self))
           \/ Terminating

Spec == Init /\ [][Next]_vars

Termination == <>(\A self \in ProcSet: pc[self] = "Done")

\* END TRANSLATION 
====

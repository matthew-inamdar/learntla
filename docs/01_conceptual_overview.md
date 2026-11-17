# Conceptual Overview

TLA+ is a very dense language so PlusCal is what we'll be writing. PlusCal is an abstraction of TLA+ (not a superset)
which can be translated to TLA+.

PlusCal is used for having a simpler API to define algorithms. It is embeded directly into TLA+ via a special comment
(which TLA+ ignores): `(* --algorithm <module-name> ... end algorithm; *)`.

A pre-compile step is ran to translate the PlusCal into TLA+ which replaces the comment with valid TLA+ code.

## Structure

* The **specification** is the description of the system and what it can do.
* The **properties** are the system requirements which must be met for the spec to be correct.

## Specifications

```tla
---- MODULE wire ----
EXTENDS TLC, Integers

People == {"alice", "bob"}
Money == 1..10
NumTransfers == 2

(* --algorithm wire
variables
  acct \in [People -> Money];

define
  NoOverdrafts ==
    \A p \in People:
      acct[p] >= 0
end define;

process wire \in 1..NumTransfers
variable
  amnt \in 1..5;
  from \in People;
  to \in People
begin
  Check:
    if acct[from] >= amnt then
      Withdraw:
        acct[from] := acct[from] - amnt;
      Deposit:
        acct[to] := acct[to] + amnt;
    end if;
end process;
end algorithm; *)

====
```

* Definitions use `==`.
* `People` and `Money` are sets (collections of unique and unordered values). 
* `[People -> Money]` is also a set (a function set). It represents all possible permutations of `People` to `Money` 
  values.
* The variable `acct` isn't a fixed value, it is one of all possible permutations the set represents. When the model is
  checked, every permutation is explored.
* `NoOverdrafts` is a **quantifier**. It is true if every element of `People` has a `Money` value greater than or equal 
  to 0.
* There is more than 1 `wire` process running concurrently. In this case there are 2.
* Each step in the algorithm belongs to a separate **label**. The label groups what happens atomically, and what can be
  interrupted by another process running concurrently. This is how we can check for race conditions.

## Models

Values can be parameterised in specs which allow for multiple models to run against the same invariants:

```diff
 ---- MODULE wire ----
 EXTENDS TLC, Integers
-
-People == {"alice", "bob"}
-Money == 1..10
-NumTransfers == 2
+CONSTANTS People, Money, NumTransfers
 
 (* --algorithm wire
 variables
```
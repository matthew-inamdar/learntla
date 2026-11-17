# Setup

## Setting Up a Project

```tla
---- MODULE wire ----

====
```

For Historical Reasons, the `MODULE $name` must be surrounded by at least four dashes, the module must end with at least 
four equal-signs, and the `$name` of the module must match the filename (case sensitive). Everything above the module 
name and below the `====` is ignored, making those good places to store notes.

## Translating Specs

The PlusCal embedded within a TLA+ spec can be translated into native TLA+ via a pre-compile step.

On vscode:

```
cmd+shift+p

>TLA+: Parse module...
```

## Running Models

Models need to have a `.cfg` file added with the same name as the module, e.g. `wire.tls` and `wire.cfg`.

The config defines the specification type and the invariants that must hold:

```tla
SPECIFICATION Spec
INVARIANT NoOverdrafts
```

You can then run the model in vscode:

```
cmd+shift+p

>TLA+: Check model with TLC
```

If any of the invariants are violated, an error trace is displayed showing the sequence of steps that led to the 
violation.

## Making a Scratchfile

```tla
---- MODULE scratch ----
EXTENDS Integers, TLC, Sequences

Eval == 0
====
```

You can test TLA+ such as the outputs of operators by using scratchfiles.

You can then get TLC to evaluate an expression on vscode:

```
cmd+shift+p

>TLA+: Evaluate expression...
  
  Eval
```


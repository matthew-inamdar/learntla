# Operators and Values

## Operators

Operators are analogus to functions in other languages.

They can take any number of arguments or none at all. There are no default values, overloaded definitions, ot optional
arguments.

```tla
EXTENDS Integers

MinutesToSeconds(m) == m * 60
```

In this case `MinutesToSeconds(m)` is the operator which takes a single argument.

## If-Then-Else

There are 3 keywords for structuring expressions:
1. LET statements
2. case statements
3. conditionals

```tla
Abs(x) == IF x < 0 THEN -x ELSE x
```

Expressions must always yield a value, so there must always be an `ELSE` branch.

## Values

TLA+ is an untyped language, however, in practice the model checker recognises 4 primitive types and 4 complex types:

**Primitives:**
1. strings
2. booleans
3. integers
4. model values

**Complex:**
1. sets
2. sequences
3. structures
4. functions

Every type in TLA+ has its own operators with no overlap and no overloading.

The two exceptions are `=` (equals) and `#` (not equals).

Values of different types cannot be tested for equality – this will result in an error.

### The obvious ones

Integers and strings.

To get access to the basic integer operators you need `EXTENDS Integers`.

Strings must use double quotes.

The only operators for strings are `=` and `#`. If you need to manipulate strings you should store them in a sequence
type.

Strings are typically used as opaque identiers.

There is no **float** type – you should abstract this away. If you need floats then TLA+ is not the correct tool for the
job.

### Booleans

Boolean operators take after the mathematical symbols:

| Logic             | TLA+ Symbol | Math Symbol |
|-------------------|-------------|-------------|
| and (conjunction) | `/\`        | $\land$     |
| or (disjunction)  | `\/`        | $\lor$      |
| not (negation)    | `~`         | $\lnot$     |
| implies           | `=>`        | $\implies$  |

We can use these to build other operators such as XOR:

```tla
Xor(A, B) == A = ~B
```

`A => B` can be expressed as `~A \/ B` as this evaluates to `TRUE` if either: 
* `A` is `TRUE` and `B` is `TRUE`; or 
* `A` is not `TRUE` (it doesn't matter what `B` is as the implication doesn't cover `B` when `A` is `FALSE`).

Contrapositives are equivalent statements formed by reversing or negating both sides of an implication. The following 
are all equivalent:

$$
\underbrace{A \implies B}_{\text{Original}}
\equiv
\underbrace{\lnot A \lor B}_{\text{Original (disjunction)}}
\equiv
\underbrace{\lnot B \implies \lnot A}_{\text{Contrapositive}}
\equiv
\underbrace{B \lor \lnot A}_{\text{Contrapositive (disjunction)}}
$$

The following truth table demonstrates this:

| A     | B     | Original: $A \implies B$ | Disjunction: $\lnot A \lor B$ | Contrapositive: $\lnot B \implies \lnot A$ | Contrapositive disjunction: $B \lor \lnot A$ |
|-------|-------|--------------------------|-------------------------------|--------------------------------------------|----------------------------------------------|
| TRUE  | TRUE  | TRUE                     | TRUE                          | TRUE                                       | TRUE                                         |
| TRUE  | FALSE | FALSE                    | FALSE                         | FALSE                                      | FALSE                                        |
| FALSE | TRUE  | TRUE                     | TRUE                          | TRUE                                       | TRUE                                         |
| FALSE | FALSE | TRUE                     | TRUE                          | TRUE                                       | TRUE                                         |

Coming from a programming background, logical implication (`A => B`) can be unintuitive because it resembles an `if` 
statement, where the condition is evaluated before the consequent. However, implication does not describe execution 
order; it describes a logical relationship between two propositions. Specifically, `A => B` is false only when A is true 
and B is false. This explains why reversing **and negating** both propositions (`~B => ~A`) produces an equivalent 
statement, known as the *contrapositive*. Both expressions rule out exactly the same combination of truth values. Simply 
reversing the propositions (`B => A`), however, is not equivalent.

TLA+ also has "bullet point notation" which can make complex boolean expressions easier to read:

```tla
A /\ (B \/ C) /\ (D \/ (E /\ F))
```

Can be rewritten in bullet point notation as:

```tla
/\ A
/\ \/ B
   \/ C
/\ \/ D
   \/ /\ E
      /\ F
```

The `/\` infront of the `A` is optional but makes the "shape more pleasing" apparently...

Bullet point notation **is the only place in the language** where whitespace matters.

## Sequences

Sequences are ordered lists, written as:

```tla
<<a, b, c>>
```

The elements can be any value, including other sequences.

The elements can be addressed directly via their index:

```tla
seq[n]
```

The indices begin from 1, so looping through all can be written as:

```tla
1..Len(seq)
```

The `Sequences` module provides some operations to use with sequences. You import with:

```tla
EXTENDS Sequences
```

_TLA+ can only have a single `EXTENDS` statement, but it can import multiple modules._

The operations provided:

| Expression                  | Gives               |
|-----------------------------|---------------------|
| `Append(S, "b")`            | `<<"a", "b">>`      |
| `S \o <<"b", "c">>`         | `<<"a", "b", "c">>` |
| `Head(S)`                   | `"a"`               |
| `Tail(<<1, 2, 3>>)`         | `<<2, 3>>`          |
| `Len(S)`                    | `1`                 |
| `SubSeq(<<1, 3, 5>>, 1, 2)` | `<<1, 3>>`          |

Fixed-length sequences are called "tuples".

You can represent a 24-hour clock using sequences:

```tla
EXTENDS Integers, Sequences

ToSeconds(time) == time[1]*3600 + time[2]*60 + time[3]
Earlier(t1, t2) == ToSeconds(t1) < ToSeconds(t2)
```

## Sets

Sets are a collection of unique, unodered elements of the same type.

Unlike sequences, sets must be composed of the same type. TLA+ allows complex types to contain any value, but TLC adds
some restructions:

| Example                     | TLC                                         |
|-----------------------------|---------------------------------------------|
| `{<<1>>, <<2, 3>>}`         | Valid                                       |
| `{<<1, "a">>, <<2, "b">>}`  | Valid                                       |
| `{<<1>>, <<"a">>}`          | May fail: incompatible element types        |
| `{<<1, "a">>, <<2, TRUE>>}` | May fail: incompatible values at position 2 |

### Set Operators

| Operator                                   | Action                                                           |
|--------------------------------------------|------------------------------------------------------------------|
| `x \in set`                                | Checks if `x` exists as an element within `set`.                 |
| `set1 \union set2`<br>`set1 \cup set2`     | A set containing all elements from both sets.                    |
| `set1 \intersect set2`<br>`set1 \cap set2` | A set containing all elements present in both `set1` and `set2`. |
| `set1 \ set2`                              | A set containing all elements in `set1` but not `set2`.          |

```tla
>>> {1, 3} \union {1, 5}

{1, 3, 5}

>>> {1, 3} \intersect {1, 5}

{1}

>>> {1, 3} \ {1, 5}

{3}
```

If you extend `FiniteSet` you get access to the `Cardinality(set)` operator which gives you the lenth of the set:

```tla
EXTENDS FiniteSet

len == Cardinality({1, 2, 3})
/* len == 3
```

The common way to check for an empty sequence or set it by comparing them to an empty sequence or set:

```tla
set = {}
seq = <<>>
```

Note that the equality and assignment operands differ between TLA+ and PlusCal:

| Operation  | TLA+                 | PlusCal              |
|------------|----------------------|----------------------|
| Equality   | `a = b`              | `a = b`              |
| Inequality | `a # b`              | `a # b`              |
| Assignment | `x' = value`         | `x := value`         |
| Definition | `Name == expression` | `Name == expression` |

### Sets of Values

For every type of value in TLA+, there is a method to generate sets of those values.

To get a set of all booleans (`TRUE` and `FALSE`) you can just use:

```tla
BOOLEANS
/* {TRUE, FALSE}
```

To get a set of integers in the range `(a, b)`, you need to import the `Integers` module and use the following syntax:

```tla
EXTENDS Integers

a..b
/* {a, a+1, a+2, ..., b}
```

If `a > b` then the result is an empty set `{}`. This is convinent for ranging through sequences:

```tla
1..Len(<<>>)
/* {} since this evaluates to 1..0
```

You can use the `\X` operand to compute the cartesian product of multiple values, which returns a set of sequences for
each cartesian product:

```tla
EXTENDS TLC, Integers

S == 1..3

S \X S \X S
(*
    {
        <<1, 1, 1>>, 
        <<1, 1, 2>>, 
        <<1, 1, 3>>,
        <<1, 2, 1>>,
        <<1, 2, 2>>,
        <<1, 2, 3>>,
        <<1, 3, 1>>,
        <<1, 3, 2>>,
        <<1, 3, 3>>,
        <<2, 1, 1>>,
        <<2, 1, 2>>,
        <<2, 1, 3>>,
        <<2, 2, 1>>,
        <<2, 2, 2>>,
        <<2, 2, 3>>,
        <<2, 3, 1>>,
        <<2, 3, 2>>,
        <<2, 3, 3>>,
        <<3, 1, 1>>,
        <<3, 1, 2>>,
        <<3, 1, 3>>,
        <<3, 2, 1>>,
        <<3, 2, 2>>,
        <<3, 2, 3>>,
        <<3, 3, 1>>,
        <<3, 3, 2>>,
        <<3, 3, 3>>
    }
*)
```

We can use the cartesian product operand to generate a set of all valid clock values:

```tla
ClockType == (0..23) \X (0..59) \X (0..59)
```

The `SUBSET()` operator returns every possible subset of a given set (note that this is very expensive as it is 
exponential):

```tla
EXTENDS FiniteSet

SUBSET ClockType
/* Cardinality (length) of 2^86400
```

To check if a set is a subset of another set, use `\subseteq` as this just checks for existance, whereas `SUBSET()` 
actually generates all possible subsets first which is very inneficient.

```tla
S1 \subseteq S2 
```

#### Map and Filter

Sets can be mapped and filtered (just like the JS array functions `.Map()` and `.Filter()`):

```tla
\* Map
Squares == {x*x: x \in 1..4}

\* Filter
Evens == {x \in 1..4: x % 2 = 0 }
```

This syntax seems strange when coming from a programming background, but you need to appreciate that TLA+ treats mapping
and filtering as two distinct forms of set construction:
* **Mapping** constructs new elements.
* **Filtering** selects existing elements.

We can use filtering to get all clock times in the second half of each hour (only the distinct minutes):

```tla
{t \in ClockType: t[2] > 30 /\ t[3] = 0}
```

We can use mapping to get the set of all elements in a sequence:

```tla
Range(seq) = {seq[i]: i \in 1..Len(seq)}
```

### CHOOSE

You can use `CHOOSE` to pick a single element from a set:

```tla
EXTENDS TLC, Integers, Sequences

ClockType == (0..23) \X (0..59) \X (0..59)

/* Converts a clock set to seconds
ToSeconds(time) == time[1]*3600 + time[2]*60 + time[3]

/* Converts seconds to a clock set
ToClock(seconds) == CHOOSE x \in ClockType: ToSeconds(x) = seconds % 86400

Eval == ToClock(86401)
```

If we remove the modulo operand then the model checker fails as we'll end up with a sequence that doesn't exist within
the `ClockType` set.

If multiple values in the set satisfy `CHOOSE` then TLC will be deterministic to ensure the same value is always 
returned, which typically will be the lowest value that matches the set.

## LET

The `LET` directive lets us declare sub-operators within the lexical scope of the operator it runs within.

`LET` can contain multiple operators where each subsequent operators can reference the prior operators in the list.

When using `LET` you must also use `IN` for the actual operator logic:

```tla
ThreeMax(a, b, c) ==
   LET
     Max(x, y) == IF x > y THEN x ELSE y
     maxab == Max(a, b)
   IN
     Max(maxab, c)
```

Note that `maxab` is an operator, however, in TLA+ zero-argument operators must omit the parenthesis.

The clock example looks like this if we use sub-operators:

```tla
ToClock2(seconds) ==
  LET
    h == seconds \div 3600
    h_left == seconds % 3600
    m == h_left \div 60
    m_left == h_left % 60
    s == m_left
  IN
    <<h, m, s>>
```

## Summary

* Operators are top-level functions, and evaluate to expressions. They are written `Op(a, b) == expr`, with two 
  equal-signs.
  * Operators can have conditions with `IF-THEN-ELSE`, and suboperators with `LET-IN`.
* Sequences are collections of ordered values, and are 1-indexed.
* Logic is `/\` for "and", `\/` for "or", and `~` for "not".
  * Logical statements can be written "bullet-points" style.
* Sets are collections of unordered distinct values.
  * We can test if an element is `\in` a set or if a set is a `\subseteq` of another set.
  * We can `\union`, `\intersect`, and (set difference) two sets.
  * We can `CHOOSE` elements of a set.
* All types have "sets of" that type. For integers it's `a..b`, for booleans it's `BOOLEAN`, for sets its `SUBSET`, and
  for sequences it's `S1 \X S2`.
  * We can map and filter sets.
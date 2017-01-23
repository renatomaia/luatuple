Index
=====

- [`tuple`](#tuple-manipulation)
- [`tuple.create`](#tuplecreate-)
- [`tuple.concat`](#tupleconcat-)
- [`tuple.istuple`](#tupleistuple-t-)
- [`tuple.size`](#tuplesize-t-)
- [`tuple.totuple`](#tupletotuple-v-)
- [`tuple.unpack`](#tupleunpack-t-)

Contents
========

Tuple Manipulation
-------------------

This library provides generic functions for manipulation of tuples.
A tuple is a finite sequence of arbitrary non-nil values, and it is defined only by this sequence of values.
Therefore the same sequence of values denotes the same tuple.

Tuples manupulated using this library are tables which contents are opaque.
Changing these contents is undefined.
Tuples might be collected if no strong references are kept to them.
After being collected, a tuple obtained again might be represented by other value (table).

### `tuple.create (...)`

Returns the tuple denoted by the parameters.
All parameters must be different from `nil`.

### `tuple.concat (...)`

Receives zero or more tuples.
Returns the tuple denoted by the justaposition of all values that denotes the tuples received as arguments.
If one of the arguments is not a tuple, it is treated like the tuple denoted by that value.
For example, the following call

```lua
tuple.concat(tuple.create(1, 2, 3), 4, tuple.create(5, 6), 7)
```

is equivalent to

```
tuple.create(1, 2, 3, 4, 5, 6, 7)
```

### `tuple.istuple (t)`

Return `true` if `t` is a tuple, or `false` otherwise.

### `tuple.len (t)`

Receives a tuple and returns the number of values that denotes the tuple.
Returns `0` for the tuple denoted by an empty sequence of values: `tuple.create()`.

### `tuple.totuple (v)`

If `v` is not a tuple, is equivalent to `tuple.create(v)`.
Returns `v` otherwise.

### `tuple.unpack (t)`

Receives a tuple and returns all values that denotes tuple `t`.


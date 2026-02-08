# ❄ NixTypes (nt) ❄
<p align="center">Because Nix never held your hand. It shot off your fingers and spat out God's longest stack trace</p>

>[!WARNING]
> ✨ **Under Construction** ✨
>
> NixTypes is **quite** a large project to do alone, but it's been staring at me for the last 12 months.
> If you're interested feel free to contact me and/or submit pull requests :yellow_heart::yellow_heart:
>
> **Be not afraid!** It's only a matter of time until NixTypes is ready for use!

>[!CAUTION]
> The current syntax is quite ugly and **no it's not final.** NixTypes is in an
> **extremely experimental** prototyping stage!

## 💙 Huh?
Nix has no type system duh!? Sure that's fine for configuring your distro,
but what about developing in Nix itself? The code people write tends to be unnecessarily complex
or full or bugs. Nix needs standards, and NixTypes gives you those.

## :rainbow: More Than Types
NixTypes isn't *exactly* just a type system. **You didn't think I'd give you types
then say goodbye did you?** Then we'd be right back where we started... Instead
there's a whole standard library built from the ashes.

Some of the sweet sweet batteries included:
1. **Pattern Matching** (finally!!)
2. **Attribute Set Parsing**
3. **Pretty Printing** (no more `builtins.toString` errors)
4. **A Module System** (say goodbye to managing all your `imports`)
5. **Types, Types, & More Types** (Maybe/Some/None, Monads, Tree, Rose, etc)
6. **Support For Pipe Operators** (cleaner code with `<|` and `|>` )

## Types For Humans
Let's design a `Result` type using the NixTypes system!
We'll start simple and use the following attribute set
as our naive basis:
```nix
Result = success: value:
  assert builtins.isBool success;
  { inherit success value; };
    
};
```

We can 
```nix
let
  inherit (nt)
    print
    toString
    Bool
    Fn
    Type
    ;
in rec {
  Result = Type (Self: {
    ops = {
      # we need to make a constructor
      mk = Fn [Bool Any] Self (success: value: { inherit success value; });
      # create some alternative constructors
      mkSuccess = Self.mk true;
      mkFail = Self.mk false; 

      isSuccess = self: self.success;
      isFail = self: ! self.success;

      unwrap = self: self.value;
    };
  });

  # Example Usage:
  tryGetAttr = name: attrs: let
    success = attrs ? name;
    value = attrs.${name} or "AttrSet missing attribute name \"${name}\"";
  in
    Result success value;

  # prints myAttr and returns the default value (same as builtins.trace!)
  printMyAttr = attrs: default: let 
    result = tryGetAttr "myAttr";
  in
    if result.isSuccess
    then print (toString result.unwrap) default
    else default;
}
```

Now let's try something a little harder and try to make our
`Result` type act more like Rust's `std::result` crate:
```rust
enum Result<T, E> {
   Ok(T),
   Err(E),
}
```
>[!TODO]
> I'm sleepy and I'll finish this in the morning...


## Types (Not) For Humans
Let's define a Maybe type in two diferent ways:
1. As a polymorphic type `PolyMaybe := Some | None` for monads `Some` and `None`
2. And as an lax-idempotent (Kock–Zöberlein) monad `KZMaybe` with states `KZSome` and `KZNone`
```nix
let
  inherit
    (nt)
    mk
    enfNotNull
    Type
    Sum
    Monad'
    KZMonad' # apostrophe implies typeclass
    ;
in rec {
  # === METHOD 1:
  Some = Type {
    ops = {
      Monad'.result = value: mk { inherit value; };
      Monad'.unwrap = self: self.value;
      Monad'.bind = self: f: f self.value;
    };
    impls = [ Monad' ];
  };
  None = Type {
    ops.mk = mk {
      Monad'.result = mk {};
      Monad'.unwrap = _: null;
      Monad'.bind = _: _: null;
    };
    impls = [ Monad' ];
  };
  PolyMaybe = Sum [Some None];

  # === METHOD 2:
  KZSome = value:
    assert enfNotNull value "KZSome value";
      KZMaybe;
  KZNone = KZMaybe null;
  KZMaybe = Type {
    ops = {
      # Lift a value INTO the monadic context
      # NOTE: because KZMaybe implements KZMonad' lax-idempotence
      # NOTE: is automatically added to the result operation
      Monad'.result = value: mk { inherit value; };
      # Lift a value OUT OF the monadic context
      Monad'.unwrap = self: self.value;
      # Alter a value inside the monadic context
      Monad'.bind = f: x: f x;
    };

    impls = [ KZMonad' ];
  };
}
```


### ❄🎁 Parse the Parcel
*Close your eyes with me ok? MMmmmmmmmmm yes just like that...* **NOW** imagine
you're a moderately depressed and very sleepy programmer. You're reading a README.md
for a type system in Nix, I doubt it's that hard. Then **whoooshhh boooom**, Zeus
himself hath commended thee to fulfill his greatest ambition **OR DIE!!** You must
write a function taking an attribute set of the structure
```nix
{
  a = {        # optional
    b = {      # optional
      c = ...; # optional (any type, default: null)
      d = ...; # optional (string, default: "hola")
    };
  };
  e = {      # required
    f = ...; # required (path)
    g = ...; # optional (function, default: (x: x))
    h = ...; # optional (string, default: "null")
  };
}
```
Not having a great day now are you? It's doable and not overtly difficult,
but coming back in a couple months you'd have to decipher your solution.
**NOW BEHOLD:**
```nix
# nix made simple <3
let
  inherit
    (nt)
    projectOnto
    missing
    verify
    ;
in
{
  f = attrs:
    attrs
    |> projectOnto
    {
      a = {
        b = {
          c = null;  
          d = "hola";
        };
      };
      e = {
        f = required "error message..."; 
        g = x: x;
        h = null |> verify isString;
      };
    };
    |> ...; # your logic here...
}
```

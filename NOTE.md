also I never really answered "why does Nix need a type system", it's basically because `nixpkgs` relies on a LOT of naive types under the hood. the most notable being `result = success: value: { inherit success value; };` and the excessive use of the `throw`/`abort`. Like if we pretend `builtins.getAttr` doesn't exist and try implement it from scratch we have two options: return a naive type (like the previous `result`) or raise the panic handler. Both are terrible solutions. Specifically with the first solution, too much reliance on naive types means memorizing what functions return what attribute set structure, and reinventing functions to do basic operations on them. Plus since the naive types are really just attribute sets we can do operations on them like any other attribute set (ie `builtins.attrNames`). NixTypes instead provides an alternative `nt.builtins` for people to use that ensure this never happens. Nix primitives types then have isomorphisms to their NixTypes counterpart so we can do implicit type coercion. Plus there's no reinventing the wheel, we don't have to define an `unwrapResult` operation because in NixTypes `Result` implements `Wrap` so we can do this:
```nix
myResult
|> Wrap.unwrap

# which implicitly uses the morphism defined by Result implementing Wrap.
# we can do type coercion explicitly via:
myResult
|> as Wrap
|> Wrap.unwrap
```

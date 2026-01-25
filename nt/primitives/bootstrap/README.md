## Primitives - /nt/primitives
All expressions in the `/nt/primitives` directory should have no dependencies on NixTypes
because **`/nt/primitives` is the dependency of NixTypes**! However for consistency in
the development process `/nt/primitives` is structured using the Mix Module subsystem
(`/nt/primitives/mix`).

*"But Emile..."* I hear you say! **How can primitives be a Mix module if Mix depends on primitives??**
Welp I'm sure I could have done some cool exploit of lazy evaluation in recursion,
*but I was alas lazy...* So the solution is **they can't... ;-;** But they can be pretty close!

Instead we have `/nt/primitives/bootstrap`! Which provides a **miniature dependency-free standard library.**
`import ./nt/primitives/bootstrap/default.nix` is passed as to `import ./nt/primitives/mix` which is
then passed to `import ./nt`.

Most importantly, `/nt/primitives/bootstrap/default.nix` contains the function `bootstrap:: Path | List | Attrs | Function -> Attrs`:
```nix
# et voilà!
let
  this = bootstrap {inherit this bootstrap;} [
    {
      std = ./std/bootstrap.nix;
      types = ./types/bootstrap.nix;
      parse = ./parse/bootstrap.nix;
    }
  ];
in
  this;
```
**\~\~!!KABOOM !!\~\~**

Now **our primitives have a primitive module system!**

The init process looks like this:
```nix
# REF: flake.nix
{
  outputs = _: let
    # Step 1: Bootstrap and blast off (*zooommmmm whoooosshhhhh pppppeeeeeeewww*)
    bootstrap = import ./nt/primitives/bootstrap;
    # Step 2: Lie to Mix about its real identity (it's not ready for the truth...)
    mix = import ./nt/primitives/mix {this = bootstrap;};
  in
    # Step 3: Actually import NixTypes
    import ./nt {inherit mix;};
    # Step 4: Like and subscripe!!1!11!!!!!
}
```


## A note on /nt/primitives/bootstrap
**None of these functions/types/etc are exported for users of NixTypes!** So they should
remain as simple and minimal as possible to avoid extra work maintaining.
Instead, **most of these will be reimplemented post-bootstrap to be NixType compatible**.

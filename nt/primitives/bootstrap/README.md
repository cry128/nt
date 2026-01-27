## Types of Types
This is the convention I personally use when referring to types:
- **Primitive Types:** The base types Nix provides, accessible via `builtins.typeOf`
- **Naive Types:** An attempt at constructing a **non-primitive type** without using NixTypes.
  nixpkgs.lib makes use of naive types, and so does the bootstrapping process for NixTypes.
  A common example is `result = success: value: { inherit success value; }`.
- **Types / NT Types:** Any type provided by or compatible with the NixTypes standard

## /nt/primitives/bootstrap
**None of these functions/types/etc are exported for users of NixTypes!** So they should
remain as simple and minimal as possible to avoid extra work maintaining.
Instead, **most of these will be reimplemented post-bootstrap to be NixType compatible**.

## Primitive Standard Functions
>[!NOTE]
> This directory is dedicated to porting functions from `nixpkgs.pkgs.lib`.

The `/nt/primitives` directory should have no dependencies on NixTypes *(with one exception explained below)*.
Thus the **NixTypes system must be constructed from a dependency-free standard library.**

This includes dependency on `this` (provided by the `nt.mix` module system)!
`/nt/primitives` is structured as a `nt.mix` module, and hence `/nt/primitives/mix`
must also depend on `/nt/primitives/std`. My point is, **`/nt/primitives/std`
cannot use mix at all!**

### Internal Use Only
**None of these functions are exported for users of NixTypes!** So they should
remain as simple and minimal as possible to avoid extra work maintaining.
Instead, **all of these functions will be reimplemented** post-bootstrap
to be NixType compatible.

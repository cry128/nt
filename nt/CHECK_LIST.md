- [ ] Write out beginner examples of how someone can import nt in a flake and also a nix expression
- [ ] Fix the README.md "Parse The Parcel" example to use a different nt function (projectOnto allows additional attributes which we don't want)
- [ ] mix should warn explicitly or have an "allowShadow" & "allowShadowPredicate"
        decl option when content will be shadowed
- [ ] allowing shadowing be enabled by mix, but all the backend shit should be in parsing related functions
- [ ] extend the parsing system
- [ ] implement the pattern matching system
- [ ] mix should do a deeply nested merge, not a surface level merge
- [ ] implement isomorphisms (especially from primitives to NixTypes)
- [ ] NOTE TO SELF: what would a "Category Oriented Programming" paradigm look like? (is that my goal with NixTypes?)


A Generic Type/Class could be implement to use like:
```nix
# NOTE: this example is COMPLETELY overkill, it's just an example
isAttrs x
|> as Maybe # type coercion via isomorphisms
|> match [
  (Some (Generic Bool) |> case (t: throw "t is from Generic, see \"nix:Bool\"=${typeOf t}"))
  (None                |> case (_: throw "not attrs"))
]

isAttrs x
|> as Maybe # type coercion via isomorphisms
|> (match <| Pattern (Some (Generic Bool)) (t: throw "t is from Generic, see \"nix:Bool\"=${typeOf t}")
          <| Pattern None (_: throw "not attrs"))


# Rust inspired pattern matching syntax:
# resultA = match [platform arch] [
#   (Pattern ["darwin" Any]                         darwin_package)
#   (Pattern ["openbsd" "x86_64"]                   openbsd_x86_64_package)
#   (Pattern [(x: x == "linux") (y: y == "x86_64")] linux_x86_64_package)
#   (Pattern (x: y: x == "linux" && y == "aarch64") linux_aarch64_package)
#   (Pattern Any                                    default_package)
# ];
# resultB = match [platform arch] [
#   (["darwin" Any]                         |> case darwin_package)
#   (["openbsd" "x86_64"]                   |> case openbsd_x86_64_package)
#   ([(x: x == "linux") (y: y == "x86_64")] |> case linux_x86_64_package)
#   ((x: y: x == "linux" && y == "aarch64") |> case linux_aarch64_package)
#   (Any                                    |> case default_package)
# ];
```

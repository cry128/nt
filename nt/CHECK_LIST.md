- [ ] implement naive Tip/Terminal type
- [ ] remove all dependency on Wrap type (it's already gone anyways...)
- [ ] /primitives/bootstrap/parse/parse.nix should be able to terminate on Tip/Terminal elements
- [ ] mix should do a deeply nested merge, not a surface level merge
- [ ] implement isomorphisms (especially from primitives to NixTypes)


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

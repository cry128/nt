# WARNING: /nt/primitives/bootstrap cannot depend on mix
# WARNING: this file is strictly for bootstrapping nt
{bootstrap, ...} @ inputs:
bootstrap inputs [
  ./parse.nix
  ./sig.nix
]

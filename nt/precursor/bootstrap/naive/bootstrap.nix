# WARNING: /nt/primitives/bootstrap cannot depend on mix
# WARNING: this file is strictly for bootstrapping nt
{bootstrap, ...} @ inputs:
bootstrap inputs [
  {
    maybe = ./maybe.nix;
    terminal = ./terminal.nix;
  }
]

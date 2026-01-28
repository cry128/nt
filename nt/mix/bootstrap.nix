# WARNING: /nt/mix is structured as a nt.mix modules
# WARNING: this file is strictly for bootstrapping mix
{this, ...}:
this.bootstrap {nt = this;} [
  ./mixture.nix
  ./import.nix
]

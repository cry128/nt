# WARNING: /nt/mix is structured as a nt.mix modules
# WARNING: this file is strictly for bootstrapping mix
{
  this,
  bootstrap,
  ...
}: let
  inputs = {
    inherit bootstrap;
    this = mix;
    nt = this;
  };

  mix = bootstrap inputs [
    ./mix.nix
    ./import.nix
  ];
in
  mix

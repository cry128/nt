{
  description = "NixTypes (nt)";

  outputs = _: let
    # nt depends on the mix subsystem for bootstrapping,
    # we can fake its dependency on this mwahahahah
    this.util = import ./nt/primitives/util/bootstrap.nix;
    mix = import ./nt/primitives/mix {inherit this;};
  in
    import ./nt {inherit mix;};
}

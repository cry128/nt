{
  description = "NixTypes (nt)";

  outputs = _: let
    # nt depends on the mix subsystem for bootstrapping
    mix = import ./nt/primitives/mix;
  in
    import ./nt {inherit mix;};
}

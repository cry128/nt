{
  description = "NixTypes (nt)";

  outputs = _: let
    # nt depends on the mix subsystem for bootstrapping,
    # we can fake its dependency on this mwahahahah
    bootstrap = import ./nt/primitives/bootstrap;
    mix = import ./nt/primitives/mix {this = bootstrap;};
  in
    import ./nt {inherit mix;};
}

{
  description = "NixTypes (nt)";

  inputs = {
    systems.url = "github:nix-systems/default";
    mix.url = "github:emilelcb/mix";
  };

  outputs = {...} @ inputs:
    import ./nt inputs;
}

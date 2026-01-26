{
  description = "NixTypes (nt)";

  outputs = inputs: let
    # Step 1: Bootstrap and blast off (*zooommmmm whoooosshhhhh pppppeeeeeeewww*)
    bootstrap = import ./nt/primitives/bootstrap;
    # Step 2: Lie to Mix about its real identity (it's not ready for the truth...)
    mix = import ./nt/mix {this = bootstrap;};
  in
    # Step 3: Actually import NixTypes
    import ./nt {
      inherit mix;
      flake = inputs.self;
    };

  # Step 4: Like and subscripe!!1!11!!!!!
}

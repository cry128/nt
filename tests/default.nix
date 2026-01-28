let
  bootstrap = import ../nt/primitives/std;

  mix = import ../nt/mix/bootstrap.nix {
    this = bootstrap;
  };

  nt = import ../nt {
    inherit mix;
    # flake.nix passes `flake = inputs.self`
    flake = builtins.getFlake ../.;
  };

  primitives = import ../nt/primitives {inherit mix;};

  dummyTest = {
    expr = 1;
    expected = 1;
  };
in {
  testPass = dummyTest;

  testMaybe = let
    maybe-mod = import ./maybe.nix {this = primitives;};

    inherit
      (maybe-mod)
      unwrapSome
      Some
      ;
  in {
    expr = Some true;
    expected = {
      _''traps''_ = {
        _'nt = {
          derive = ["nt::&Maybe"];
          instance = true;
          ops = {
            "nt::&Maybe".unwrap = unwrapSome;
          };
          req = {};
          sig = "nt::Some";
        };
        _'ntDyn = {value = true;};
      };
    };
  };
}

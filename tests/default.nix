let
  bootstrap = import ../nt/primitives/bootstrap;

  nt = import ../nt {
    mix = import ../nt/mix {
      this = bootstrap;
    };
    # flake.nix passes `flake = inputs.self`
    flake = builtins.getFlake ../.;
  };

  dummyTest = {
    expr = 1;
    expected = 1;
  };
in {
  testPass = dummyTest;

  testMaybe = let
    maybe-mod = import ./maybe.nix {this = bootstrap;};

    inherit
      (maybe-mod)
      Maybe
      Some
      None
      ;
  in {
    expr = Some true;
    expected = {
      _''traps''_ = {
        _'nt = {
          derive = ["nt::&Maybe"];
          instance = true;
          ops = {
            "nt::&Maybe" = {
              unwrap = f: self: f self.${bootstrap.ntDynamicTrapdoorKey}.value;
            };
          };
          req = {};
          sig = "nt::Some";
        };
        _'ntDyn = {value = true;};
      };
    };
  };
}

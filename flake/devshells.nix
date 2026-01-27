{this, ...}: let
  inherit
    (this.util)
    forAllSystems
    ;
in {
  devShells = forAllSystems (
    system: pkgs: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          python312
          nix-unit
          nixfmt
        ];

        shell = "${pkgs.bash}/bin/bash";
      };
    }
  );
}

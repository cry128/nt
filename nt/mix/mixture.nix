{
  this,
  nt,
  ...
}: let
  inherit
    (this)
    mkIncludes
    mkSubMods
    ;

  inherit
    (nt)
    projectOnto
    ;
in {
  newMixture = inputs: modBuilder: let
    # parse mixture declaration structure
    decl =
      modBuilder mixture.private
      |> projectOnto
      {
        isolated = false;

        includes = {
          public = [];
          private = [];
          protected = [];
        };
        submods = {
          public = [];
          private = [];
          protected = [];
        };
        # XXX: TODO: are these needed?
        # options = Terminal {};
        # config = Terminal {};
      };

    inputBuilder = mixture:
      if decl.isolated
      then inputs // {this = mixture;}
      else {this = mixture;} // inputs;
    descendentInputs = inputBuilder mixture.protected;

    mkMixtureIncludes = layer: mkIncludes decl.includes.${layer} descendentInputs;
    mkMixtureSubMods = layer: mkSubMods decl.submods.${layer} descendentInputs;

    includes = {
      public = mkMixtureIncludes "public";
      protected = includes.public // mkMixtureIncludes "protected";
      private = includes.protected // mkMixtureIncludes "private";
    };
    submods = {
      public = mkMixtureSubMods "public";
      protected = submods.public // mkMixtureSubMods "protected";
      private = submods.protected // mkMixtureSubMods "private";
    };

    # mixture components are ordered based on shadowing
    mixture = {
      public =
        includes.public
        // submods.public;
      protected =
        includes.protected
        // submods.protected;
      private =
        includes.private
        // submods.private;
    };
  in
    mixture.public;
}

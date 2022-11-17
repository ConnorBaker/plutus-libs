{
  description = "Packaging plutus-libs";
  nixConfig = {
    extra-substituters = ["https://cache.iog.io" "https://iohk.cachix.org"];
    extra-trusted-public-keys = ["hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo="];
    allow-import-from-derivation = true;
  };
  inputs = {
    haskell-nix.url = "github:input-output-hk/haskell.nix/4ee7270856a6ba4617c7e51a6c619f365faad894";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    haskell-nix,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = haskell-nix.legacyPackages.${system};
      haskellNixPkgs = pkgs.haskell-nix;

      ghcVersion = "ghc810420210212";
      ghc = haskellNixPkgs.compiler.${ghcVersion};
      cabal-install = haskellNixPkgs.cabal-install.${ghcVersion};

      # Build cabal-cache from hackage because it has dependencies marked as broken on nixpkgs.
      # This also lets us use the same version of GHC we'll use to build everything else.
      inherit
        ((haskellNixPkgs.hackage-package {
            name = "cabal-cache";
            compiler-nix-name = ghcVersion;
            version = "1.0.4.0";
            index-state = "2022-05-02T00:00:00Z";
          })
          .components
          .exes)
        cabal-cache
        ;
    in {
      devShells.default = pkgs.mkShell {
        buildInputs =
          (with pkgs; [
            cvc4
            libsodium
            lzma
            pkg-config
            zlib
          ])
          ++ [ghc cabal-install cabal-cache];
      };
      formatter = pkgs.alejandra;
    });
}

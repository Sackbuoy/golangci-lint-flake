{
  description = "Custom Golangci-lint version flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    # Function to build a specific Go version
    buildGolangCi = {
      version,
      sha256,
    }:
      pkgs.stdenv.mkDerivation {
        pname = "golangci-lint";
        inherit version;

        src = pkgs.fetchurl {
          url = "https://github.com/golangci/golangci-lint/releases/download/v${version}/golangci-lint-${version}-linux-amd64.tar.gz";
          inherit sha256;
        };

        sourceRoot = ".";

        installPhase = ''
          mkdir -p $out/bin
          cp ./golangci-lint-${version}-linux-amd64/golangci-lint $out/bin/
        '';

        # Skip unnecessary phases
        dontConfigure = true;
        dontBuild = true;

        meta = with pkgs.lib; {
          description = "Golangci-lint";
          homepage = "https://golangci-lint.run/";
          license = licenses.bsd3;
          platforms = platforms.linux;
        };
      };

    # Predefined Go versions

    v_1_54_0 = buildGolangCi {
      version = "1.54.0";
      sha256 = "ppTxnb+rPqTTlWyxBdLnTB3EnLTAbs6QOjxTS86Gs9w=";
    };

    v_1_64_5 = buildGolangCi {
      version = "1.64.5";
      sha256 = "5r05mgR5xf2Ebc+fOZDSBEi08NHlAn2CNI6rn4D3rHE=";
    };

    v_1_64_7 = buildGolangCi {
      version = "1.64.7";
      sha256 = "2tpAleq1P4aPkxhA8EuZy0vmVORfUNTTsoMtya077eg=";
    };

    # Function to generate a devShell for a specific version
    mkShell = golangciPkg:
      pkgs.mkShell {
        buildInputs = [golangciPkg];

        shellHook = ''
          golangci-lint version
        '';
      };
  in {
    packages.${system} = {
      # v1.54.x
      v-1-54-0 = v_1_54_0;

      # v1.64.x
      v-1-64-5 = v_1_64_5;
      v-1-64-7 = v_1_64_7;
      # Default package
      default = v_1_64_7;
    };

    devShells.${system} = {
      # v1.54.x
      v-1-54-0 = mkShell v_1_54_0;

      # v1.64.x
      v-1-64-5 = mkShell v_1_64_5;
      v-1-64-7 = mkShell v_1_64_7;
      # Default shell
      default = mkShell v_1_64_7;
    };
  };
}

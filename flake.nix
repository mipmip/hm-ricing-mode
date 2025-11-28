{
  description = "Ricing mode utility for Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }:
  let
    supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; config.allowUnfree = true; config.cudaSupport= true; overlays = [  ];  });
  in
  {
    packages = forAllSystems (system:
      let
        pkgs = nixpkgsFor.${system};
      in
      {
        hm-ricing-mode = pkgs.callPackage ./package/package.nix {};
      });

    hm-ricing-mode = forAllSystems (system: self.packages.${system}.hm-ricing-mode);
    defaultPackage = forAllSystems (system: self.packages.${system}.hm-ricing-mode);

    homeManagerModules.hm-ricing-mode = { pkgs, ... }:
    {
      imports = [
        "${self}/module/hm-ricing-mode.nix"
      ];
    };

    };
}

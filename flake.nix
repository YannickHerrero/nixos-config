{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-apple-silicon = {
      url = "github:tpwrules/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-apple-silicon, ... }: {
    nixosConfigurations.pulse15 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/pulse15/configuration.nix
        home-manager.nixosModules.home-manager
      ];
    };

    nixosConfigurations.macbook-air = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { inherit nixos-apple-silicon; };
      modules = [
        nixos-apple-silicon.nixosModules.apple-silicon-support
        ./hosts/macbook-air/configuration.nix
        home-manager.nixosModules.home-manager
      ];
    };
  };
}

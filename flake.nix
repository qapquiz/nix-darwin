{
  description = "armariya's Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
				[
				pkgs.neovim
					pkgs.fzf
					pkgs.ripgrep
					pkgs.starship
					pkgs.tmux
					pkgs.zoxide
					pkgs.stow
					pkgs.tldr
					pkgs.mise
					pkgs.eza
					pkgs.zsh-autosuggestions
					pkgs.rustup
					pkgs.lazygit

# macOS programs
					pkgs.alacritty
				];

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
			programs.zsh = {
				enable = true;
				interactiveShellInit = ''
					source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
				'';
			};
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "x86_64-darwin";

      system.defaults = {
				dock.autohide = true;
      };

			# homebrew
			homebrew.enable = true;
			homebrew.casks = [
				"nikitabobko/tap/aerospace"
				"discord"
				"telegram"
				"raycast"
			];
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Ariyas-MacBook-Pro
    darwinConfigurations."Ariyas-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."Ariyas-MacBook-Pro".pkgs;
  };
}

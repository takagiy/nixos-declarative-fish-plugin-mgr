{ lib, config, pkgs, ...}:

with lib;

let
  cfg = config.programs.fish;

  pluginDrvs = map (name: {
    name = baseNameOf name;
    path = fetchGit {
      url = "https://github.com/${name}.git";
    };
  }) cfg.plugins;

  initScript = fishPath: ''
    set -g nixos_fish_plugins ${fishPath}
    set -g fisher_path ${fishPath}
    set -p fish_function_path fish_function_path[1] ''$nixos_fish_plugins/functions
    set -p fish_complete_path fish_complete_path[1] ''$nixos_fish_plugins/completions

    ${concatMapStringsSep "\n" (drv: ''
      path=${drv.path} package=${drv.name} builtin source ${drv.path}/init.fish 2> /dev/null
    '') pluginDrvs}

    for file in ''$nixos_fish_plugins/conf.d/*.fish
        builtin source ''$file 2> /dev/null
    end
  '';

  installScript = fishPath: ''
    if [ -z $nixos_fish_plugins_installed ]
      for file in ${fishPath}/conf.d/*.fish
        emit (basename ''$file .fish)_install
        echo emit (basename ''$file .fish)_install
      end
      set -Ux nixos_fish_plugins_installed yes
      ${initScript fishPath}
    end
  '';

  fishPath =
    if length cfg.plugins == 0 then null
    else pkgs.buildEnv rec {
      name = "fish-plugins";
      paths = map (drv: drv.path) pluginDrvs;
      pathsToLink = [ "/conf.d" "/functions" "/completions" ];
      buildInputs = [ pkgs.fish ];
    };
in

{
  options.programs.fish.plugins = mkOption {
    type = with types; listOf str;
    default = [];
    example = literalExample ''
      [
        "jethrokuan/fzf"
        "b4b4r07/enhancd"
      ]
    '';
    description = ''
      List of fish plugins to be installed.
    '';
  };

  config = mkIf cfg.enable {
    programs.fish.interactiveShellInit =
      optionalString (fishPath != null) (initScript fishPath + installScript fishPath);
      environment.variables."nixos_fish_plugins_installed"="";
  };
}

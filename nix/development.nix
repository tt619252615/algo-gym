{ mkShell, python3, fish, writeText, ruff, black, mypy, poetry }:

let
  # Python with packages
  pythonEnv = python3.withPackages (ps:
    with ps; [
      pip
      virtualenv
      # Add your packages here
      numpy
      pandas
      requests
      jupyterlab
    ]);

  # Fish shell theme configuration
  fishConfig = writeText "config.fish" ''
    # Python dev environment theme
    set -g fish_greeting ""

    # Color scheme - Ocean
    set -g fish_color_normal normal
    set -g fish_color_command blue --bold
    set -g fish_color_param cyan
    set -g fish_color_error red --bold
    set -g fish_color_comment brblack
    set -g fish_color_quote green
    set -g fish_color_operator yellow

    # Custom prompt
    function fish_prompt
      set -l last_status $status
      set -l cwd (prompt_pwd)

      # Python icon and version
      set -l py_version (python --version 2>&1 | string replace "Python " "")

      # Git branch
      set -l git_branch ""
      if git rev-parse --git-dir >/dev/null 2>&1
        set git_branch (git branch --show-current 2>/dev/null)
        if test -n "$git_branch"
          set git_branch " 󰊢 $git_branch"
        end
      end

      # Status indicator
      set -l status_color green
      if test $last_status -ne 0
        set status_color red
      end

      echo ""
      set_color blue; echo -n " $py_version"
      set_color brblack; echo -n " │"
      set_color yellow; echo -n " $cwd"
      set_color magenta; echo -n "$git_branch"
      echo ""
      set_color $status_color; echo -n "❯ "
      set_color normal
    end

    function fish_right_prompt
      set_color brblack
      echo -n "🐍 python"
      set_color normal
    end
  '';

in mkShell {
  name = "python-dev";

  packages = [
    pythonEnv
    fish
    # Development tools
    ruff # Fast Python linter
    black # Code formatter
    mypy # Type checker
    poetry # Dependency management
  ];

  shellHook = ''
    export SHELL=${fish}/bin/fish
    export XDG_CONFIG_HOME="$PWD/.config"
    mkdir -p $XDG_CONFIG_HOME/fish
    cp ${fishConfig} $XDG_CONFIG_HOME/fish/config.fish

    echo "🐍 Python development environment"
    echo "   Python: $(python --version)"
    echo "   Tools: ruff, black, mypy, poetry"
    echo ""

    exec fish
  '';
}

# Python Development Environment

## Quick Start

```bash
# Enter development shell
nix develop

# Or run directly without entering shell
nix develop -c python your_script.py
```

## Adding Python Packages

Edit `nix/development.nix`, find the `pythonEnv` section:

```nix
pythonEnv = python3.withPackages (ps: with ps; [
  pip
  virtualenv
  # Add your packages here
  numpy
  pandas
  requests
  flask
  pytest
]);
```

Then re-enter the shell:

```bash
exit
nix develop
```

## Adding System Dependencies

Edit `nix/development.nix`, add packages to the `packages` list:

```nix
packages = [
  pythonEnv
  fish
  ruff
  black
  mypy
  poetry
  # Add system packages here
  postgresql
  redis
];
```

## Adding Development Tools

Common tools you might want to add:

```nix
packages = [
  # ... existing packages

  # Testing
  python3Packages.pytest
  python3Packages.pytest-cov

  # Database
  postgresql
  sqlite

  # Other tools
  pre-commit
  just
];
```

## Customizing Shell Theme

Edit the `fishConfig` section in `nix/development.nix`:

```nix
# Change colors
set -g fish_color_command blue --bold    # Command color
set -g fish_color_param cyan             # Parameter color
set -g fish_color_error red --bold       # Error color

# Change prompt icon
set_color blue; echo -n " $py_version"  # Change  to other icon
```

## Using with direnv

Create `.envrc` in your project root:

```bash
use flake
```

Then run:

```bash
direnv allow
```

## Project Structure

```
.
├── flake.nix           # Flake entry point
├── flake.lock          # Locked dependencies
├── nix/
│   └── development.nix # Shell configuration
└── README.md
```

## Common Issues

### Package not found

Search for package name in nixpkgs:

```bash
nix search nixpkgs python3Packages.packagename
```

### Need unfree packages

Add to `flake.nix`:

```nix
pkgs = import nixpkgs {
  inherit system;
  config.allowUnfree = true;
};
```

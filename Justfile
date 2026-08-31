check *args=".":
    #!/usr/bin/env fish

    set -l nvim_bin (command -v nvim)

    # Resolve symlinks to get the actual Nix store path
    set -l nvim_real (realpath $nvim_bin)

    # Extract the Nix store package root (e.g. /nix/store/<hash>-neovim-x.y.z)
    set -l nvim_store_root (string match -r '^/nix/store/[^/]+' $nvim_real)

    if test -z "$nvim_store_root"
        echo "Error: nvim is not installed via Nix ($nvim_real)" >&2
        exit 1
    end

    # Look for the runtime directory in the package
    set -l runtime_dir "$nvim_store_root/share/nvim/runtime"

    if test -z "$runtime_dir"; or not test -d "$runtime_dir"
        echo "Error: could not locate VIMRUNTIME in $nvim_store_root" >&2
        exit 1
    end

    # plenary.nvim/lua/plenary/busted.lua globally redefines `assert` as
    # Luassert, which is not fixed by our own workspace/library ignore config:
    # emmylua_check's --config flag canonicalizes the (Nix-store-symlinked)
    # config file and takes its *parent* as the config root, so relative
    # excludes resolve against /nix/store instead of this project. Passing
    # --ignore here avoids that path entirely.
    VIMRUNTIME=$runtime_dir emmylua_check --ignore "**/plenary/busted.lua" {{ args }}

format:
    @stylua **/*.lua

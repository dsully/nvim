check:
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

    VIMRUNTIME=$runtime_dir emmylua_check --config ./.emmyrc.json .

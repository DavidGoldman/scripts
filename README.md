# Scripts

This repository has a few of my scripts for personal use.
Some of them I may have made; others I may have found online and modified to my liking.

## zsh

Directory has files for [zsh shell](https://github.com/zsh-users/zsh)

* [up.zsh](./zsh/up.zsh) - quickly go up directories
  * Similar to [bd](https://github.com/0rax/fish-bd), use `up <parent dir substring>` to quickly
    `cd` to a parent directory. This tries to be case sensitive at first and tries case
    insensitive matching as a backup. Also included are `pup` and `oup` which use `pushd` and
    `open` instead of `cd`.

## fish

Directory has files for [fish shell](https://github.com/fish-shell/fish-shell)

* [up.fish](./fish/up.fish) - quickly go up directories
  * See the description of up.zsh above; this mirrors the same functionality but for fish.

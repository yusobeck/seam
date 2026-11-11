# Seam

**English** | [한국어](README.ko.md)

A shell that shows the home folders of several Linux machines at home under **one root, `#`**.
It is plain bash, but other machines' files look like your own folders. That's all it does.

```
#> ls
#/home/desk  #/home/laptop
#> cp #/home/laptop/photo.jpg #/home/desk/       # copy between machines
#> vim #/home/laptop/notes.txt                   # edit a file on another machine directly
#> cd @/git                                      # go to the machine that has a git folder
```

> The version that also shows CPU/GPU status (`top`) and runs commands on an idle machine (`run`) is **seam-full**, in the [`full/`](full/) folder.

## Requirements

- Two or more Linux machines (same Wi-Fi / network)
- On each machine: `bash` (4+), `ssh`, `sshfs`
- On the other machines: an ssh server (`openssh-server`)

| OS | Install | Status |
|---|---|---|
| Ubuntu / Debian / Mint | `sudo apt install sshfs openssh-server` | Tested |
| Fedora | `sudo dnf install fuse-sshfs openssh-server` | Untested (expected to work) |
| Arch | `sudo pacman -S sshfs openssh` | Untested (expected to work) |
| Windows | Install Ubuntu in WSL2, then follow the steps above inside it | Untested (sshfs on WSL not verified) |
| macOS | - | **Not supported**: bash 3.x by default, needs macFUSE, no `fusermount` |

## Install

Once on **each machine** you want to use Seam on:

```
git clone https://github.com/yusobeck/seam.git
cd seam          # don't delete this folder after installing
./install.sh
```

This creates `~/.local/bin/seam`, and on first run the `seam setup` wizard starts right away.

1. **Prepare this machine**: checks for ssh and sshfs (shows how to install them if missing)
2. **Name this machine**: keep it short, e.g. `desk`, `laptop`
3. **Other machines to join**: enter a name and address (IP), and Seam will:
   - create an ssh key if you don't have one
   - ask for that machine's password **once** and register the key
   - connect automatically without a password from then on
4. **Save**: to `~/.config/seam/machines` (you can edit it by hand)

If you already have a Host entry in `~/.ssh/config`, just type that name as the address.

## Usage

```
seam            # start (leave with exit; type help inside)
seam setup      # add/change machines
seam doctor     # check connections
```

### Paths

| Write | Meaning |
|---|---|
| `#` | The top of Seam. Plain `cd` takes you here |
| `#/home/laptop/a.txt` | `~/a.txt` on the machine `laptop` |
| `@/laptop` | laptop's home (same as `#/home/laptop`) |
| `@/git` | Finds the machine that has `~/git`. If several do, lists the candidates and does nothing |

No matter how many times you `cd ..`, you can't go above `#`.

`ls cat cp mv rm mkdir rmdir touch vim nano less head tail grep find du stat file` accept `#/` and `@/` paths as-is.

## Good to know

- Other machines' homes are **real**. `rm` really deletes.
- `>` redirects and commands not in the list above (python, etc.) don't understand `#/` paths. `cd` into the folder and use relative paths instead.
- Other machines' homes are unmounted when you close the last Seam window.
- The tool's own messages (setup wizard, errors, `help`) are currently in Korean.
- Only tested between Linux machines so far (see the table above). Clone it on each new machine.

## Files

```
seam              launcher (start / setup / doctor)
install.sh        links ~/.local/bin/seam + first-time setup
linux/common.sh   machine list, shared ssh helper
linux/seamrc      the Seam shell (# @ paths, cd, ls ...)
full/             seam-full
```

## License

[MIT](LICENSE)

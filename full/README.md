# Seam (full)

**English** | [한국어](README.ko.md)

> The lightweight version that only joins files is [**seam**](../). This one, **seam-full**, adds CPU/GPU status and `run` (run a command on the least busy machine).

A shell that joins several Linux machines at home under **one root, `#`**.
It is plain bash, but other machines' files look like your own folders, and you can send commands to whichever machine is idle.

```
#> ls
#/home/desk  #/home/laptop  #/dev
#> cp #/home/laptop/photo.jpg #/home/desk/       # copy between machines
#> cd @/git                                      # go to the machine that has a git folder
#> run make -j4                                  # build on the least busy machine
#> run --gpu python train.py                     # run on the machine with a GPU
#> top                                           # CPU/RAM/GPU of every machine at a glance
```

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
| macOS | - | **Not supported**: bash 3.x by default, needs macFUSE, no `/proc`, `lspci` or `fusermount` |

## Install

Once on **each machine** you want to use Seam on:

```
git clone https://github.com/yusobeck/seam.git
cd seam/full     # don't delete this folder after installing
./install.sh
```

This creates `~/.local/bin/seam-full`, and on first run the `seam-full setup` wizard starts right away.

1. **Prepare this machine**: checks for ssh and sshfs (shows how to install them if missing)
2. **Name this machine**: keep it short, e.g. `desk`, `laptop`
3. **Other machines to join**: enter a name and address (IP), and Seam will:
   - create an ssh key if you don't have one
   - ask for that machine's password **once** and register the key
   - connect automatically without a password from then on
4. **Save**: to `~/.config/seam/machines`

If you already have a Host entry in `~/.ssh/config`, just type that name as the address.

## Usage

```
seam-full              # start (leave with exit; type help inside)
seam-full setup        # add/change machines
seam-full doctor       # check connections
seam-full run ...      # one-off run from outside the shell (see below)
```

### Paths

| Write | Meaning |
|---|---|
| `#` | The top of Seam. Plain `cd` takes you here |
| `#/home/laptop/a.txt` | `~/a.txt` on the machine `laptop` |
| `@/laptop` | laptop's home (same as `#/home/laptop`) |
| `@/git` | Finds the machine that has `~/git`. If several do, lists the candidates and does nothing |
| `#/dev/<machine>/` | Info files for that machine: `cpu_name` `cpus` `load` `mem_free_mb` `gpu_name` ... |

No matter how many times you `cd ..`, you can't go above `#`.

`ls cat cp mv rm mkdir vim nano less head tail grep find du stat` and friends accept `#/` and `@/` paths as-is.

### run: run on an idle machine

```
run                    # CPU/RAM/GPU of each machine + where a run would go now
run make               # on the machine with the most free cores
run --on laptop make   # pick the machine yourself
run --gpu python t.py  # on a machine with an NVIDIA GPU
run -j4 make -j4       # prefer a machine with 4 free cores
run --port 8000 python3 -m http.server 8000
                       # wherever it runs, localhost:8000 works on this machine too
run 'ls | wc -l'       # quote pipes and other shell syntax
```

Plain `run` prints something like this (example):

```
  desk (this machine)
    CPU  Intel Core i5-3450 3.10GHz  4 cores (12% busy, 3.5 free)
    RAM  15.5GB (10.8GB free)
    GPU  NVIDIA GeForce GTX 1050 Ti  (4.0GB, 0.5GB used, 3% busy)
  laptop
    CPU  Intel Core i5 M 450 2.40GHz  4 cores (0% busy, 4.0 free)
    RAM  7.6GB (6.3GB free)
    GPU  AMD Mobility Radeon HD 5430/5450/5470  (not a compute GPU -> no --gpu)
-> run would go to laptop right now
```

(The tool's own messages are currently in Korean; the example above is translated.)

- **How a machine is picked**: free cores are computed from the current CPU usage (measured over 0.4 s), and the machine with the most wins. On a tie, the one with more free RAM. A machine that just got busy is reflected immediately.
- **`--gpu`**: only machines with an NVIDIA GPU (`nvidia-smi`) are candidates. It goes there even if that machine is busy.
- The current folder follows you. Send from `#/home/desk/git` to laptop and it runs in laptop's `~/git`.
- Ctrl-C stops the remote process and closes the port tunnel too.
- The command's exit code is passed through (`$?`).

### From outside the shell: seam-full run

Scripts, cron, or an AI agent can't open the Seam shell, so use this. Options are the same as `run` above.

```
seam-full run --gpu python train.py
~/.local/bin/seam-full run --gpu python train.py   # when it's not on PATH (non-interactive ssh, etc.)
```

This works with ssh only, no sshfs mounts (`#/` path arguments only make sense when mounts exist).

## Good to know

- Other machines' homes are **real**. `rm` really deletes.
- `>` redirects and commands not in the list above (python, etc.) don't understand `#/` paths. `cd` into the folder and use relative paths instead.
- Other machines' homes are unmounted when you close the last Seam window.
- One job is never split across machines (one machine at a time).
- It sends whole jobs. The whole program runs on the chosen machine; it does not use another machine's GPU as a remote device.
- Usage is a 0.4 s average taken at the moment you call it, so when two machines are almost equally free the choice may flip.
- seam and seam-full share the machine list (`~/.config/seam/machines`) but mount in different places, so you can have both open at once.
- Only tested between Linux machines so far (see the table above). Clone it on each new machine.

## Files

```
seam              launcher (start / setup / doctor / run)
install.sh        links ~/.local/bin/seam-full + first-time setup
linux/common.sh   machine list, shared ssh helper
linux/seamrc      the Seam shell (# paths, cd, top, run ...)
```

## License

[MIT](../LICENSE)

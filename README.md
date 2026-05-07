# ra-yavuz Linux packages

> **Live repository:** [https://ra-yavuz.github.io/apt/](https://ra-yavuz.github.io/apt/)

Personal Debian/Ubuntu apt repository for [ra-yavuz](https://github.com/ra-yavuz)'s Linux tools. Hosted as static files on GitHub Pages.

## Disclaimer / no warranty

> All packages distributed from this repository are provided **as is, without warranty of any kind**, express or implied, including but not limited to merchantability, fitness for a particular purpose, and noninfringement. The maintainer is **not liable** for any damage to your hardware, data, or system caused by installing or running these packages.
>
> Each package may interact with low-level system interfaces (battery firmware, kernel sysfs, etc). Read the per-package README before installing. By adding this repository to your apt sources, you accept full responsibility for any consequences.

## What's in here

| Package | Source | Description |
|---|---|---|
| `herald` | [ra-yavuz/herald](https://github.com/ra-yavuz/herald) | Print a quote at the top of every new terminal and at login |
| `hydra-llm` | [ra-yavuz/hydra-llm](https://github.com/ra-yavuz/hydra-llm) | Run local LLMs the easy way, with an OpenAI-compatible `/v1` endpoint |
| `hydra-llm-plasma` | [ra-yavuz/hydra-llm](https://github.com/ra-yavuz/hydra-llm) | KDE Plasma 6 panel widget for `hydra-llm` |
| `inhibit-charge` | [ra-yavuz/inhibit-charge](https://github.com/ra-yavuz/inhibit-charge) | Park your laptop battery at a target charge using the kernel's `inhibit-charge` mode |
| `lillycoder` | [ra-yavuz/lillycoder](https://github.com/ra-yavuz/lillycoder) | Local-first coder REPL with file and shell tools, talks to any OpenAI-compatible `/v1` endpoint |
| `meowtrics` | [ra-yavuz/meowtrics](https://github.com/ra-yavuz/meowtrics) | Animated emoji tray pet that reacts to your machine's vital signs |

## Add the repository and install

### One-line setup + install

Adds the signed repo if not already added, refreshes the package index, and installs the package. Idempotent, safe to re-run. Replace `<package>` with the package you want (e.g. `inhibit-charge`, `herald`, `meowtrics`, `lillycoder`, `hydra-llm`):

```bash
sudo bash -c 'set -e; install -m 0755 -d /etc/apt/keyrings && curl -fsSL https://ra-yavuz.github.io/apt/pubkey.gpg -o /etc/apt/keyrings/ra-yavuz.gpg && echo "deb [signed-by=/etc/apt/keyrings/ra-yavuz.gpg] https://ra-yavuz.github.io/apt stable main" > /etc/apt/sources.list.d/ra-yavuz.list && apt update && apt install -y <package>'
```

If you already added the repository earlier, all you need for any future package is:

```bash
sudo apt update && sudo apt install <package>
```

The `sudo apt update` step is required: without it, apt will not see new packages or new versions published to this repository.

**Tested on Ubuntu (Linux only).** Packages should also work on Debian and any close Ubuntu derivative, and on **WSL2** Ubuntu / Debian (it is a Linux distro), with the caveat that some projects (e.g. `inhibit-charge`, `meowtrics`) need hardware sysfs or a Linux desktop tray that WSL2 does not provide. **macOS** is not a target for the apt repository: `apt` is not native to Darwin. macOS users should follow each project's per-project install path (e.g. `hydra-llm` runs under Docker Desktop, `lillycoder` installs from source via `pip`).

### Step by step

```bash
# 1. Trust the signing key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://ra-yavuz.github.io/apt/pubkey.gpg \
  | sudo tee /etc/apt/keyrings/ra-yavuz.gpg > /dev/null

# 2. Add the apt source
echo "deb [signed-by=/etc/apt/keyrings/ra-yavuz.gpg] https://ra-yavuz.github.io/apt stable main" \
  | sudo tee /etc/apt/sources.list.d/ra-yavuz.list

# 3. Refresh the package index, then install (replace inhibit-charge with any package above)
sudo apt update
sudo apt install inhibit-charge
```

## Signing key

- **Name:** `ra-yavuz Linux Packages <yavuzramazan1994@gmail.com>`
- **Fingerprint:** `54A2 E458 04D1 C743 F933 27E3 5F74 F91A 8E47 CE5A`
- **Public key (binary, for `signed-by`):** [`pubkey.gpg`](pubkey.gpg)
- **Public key (ASCII armored):** [`pubkey.asc`](pubkey.asc)

Verify the fingerprint before trusting the key:

```bash
gpg --show-keys /etc/apt/keyrings/ra-yavuz.gpg
# expect: 54A2 E458 04D1 C743 F933  27E3 5F74 F91A 8E47 CE5A
```

## Repository layout

```
.
├── pool/main/<initial>/<package>/<package>_<version>_<arch>.deb
└── dists/stable/
    ├── Release             metadata + sha256 of every Packages file
    ├── Release.gpg         detached GPG signature (legacy clients)
    ├── InRelease           clear-signed Release (modern clients)
    └── main/binary-{amd64,arm64,all}/
        ├── Packages
        └── Packages.gz
```

The repository is rebuilt by `.github/workflows/publish.yml` on every push to `main` that touches `pool/`, then deployed to GitHub Pages.

## Removing the repository

```bash
sudo rm /etc/apt/sources.list.d/ra-yavuz.list /etc/apt/keyrings/ra-yavuz.gpg
sudo apt update
```

## License

Repository tooling: MIT. Each `.deb` carries its own license (see the package's `/usr/share/doc/<package>/copyright`).

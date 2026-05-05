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
| `inhibit-charge` | [ra-yavuz/inhibit-charge](https://github.com/ra-yavuz/inhibit-charge) | Park your laptop battery at a target charge using the kernel's `inhibit-charge` mode |

(more to follow as projects ship)

## Add the repository

```bash
# 1. Trust the signing key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://ra-yavuz.github.io/apt/pubkey.gpg \
  | sudo tee /etc/apt/keyrings/ra-yavuz.gpg > /dev/null

# 2. Add the apt source
echo "deb [signed-by=/etc/apt/keyrings/ra-yavuz.gpg] https://ra-yavuz.github.io/apt stable main" \
  | sudo tee /etc/apt/sources.list.d/ra-yavuz.list

# 3. Update and install
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

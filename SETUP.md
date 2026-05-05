# One-time setup for the apt repository

These steps activate the auto-publish workflow. Until they are done, the workflow will fail with a clear error and Pages will not deploy.

## 1. Add the GPG signing key as a repo secret

The signing key was generated locally and saved to:

```
~/.config/github/apt-gpg-private.asc      # ASCII-armored private key, mode 0600
~/.config/github/apt-gpg-keyid            # fingerprint
```

Add them as repository secrets at **https://github.com/ra-yavuz/apt/settings/secrets/actions**:

| Secret name | Value |
|---|---|
| `APT_GPG_PRIVATE_KEY` | the full contents of `~/.config/github/apt-gpg-private.asc` (paste exactly, including the `-----BEGIN PGP PRIVATE KEY BLOCK-----` and `-----END ...-----` lines) |
| `APT_GPG_KEY_ID` | `54A2E45804D1C743F93327E35F74F91A8E47CE5A` |

Quick way to view the file's contents in your terminal without exposing it on screen:

```bash
xclip -selection clipboard < ~/.config/github/apt-gpg-private.asc   # Linux X11
wl-copy < ~/.config/github/apt-gpg-private.asc                      # Linux Wayland
```

(or just `cat` it on a trusted terminal and paste).

## 2. Enable GitHub Pages

At **https://github.com/ra-yavuz/apt/settings/pages**:

- Source: **GitHub Actions**

That's it. The workflow already handles the artifact upload and deploy.

## 3. Trigger a publish

Either push any change to `pool/`, `index.html`, `pubkey.*`, or `scripts/`, or run the workflow manually from **Actions -> publish -> Run workflow**.

After ~1 min the site will be live at **https://ra-yavuz.github.io/apt/**.

## Rotating the key (if it ever leaks)

1. Generate a new key locally.
2. Replace `pubkey.gpg` and `pubkey.asc` in this repo.
3. Update both secrets.
4. Re-run the workflow.
5. Tell users to re-fetch `pubkey.gpg` (the README install snippet does this on every fresh install).

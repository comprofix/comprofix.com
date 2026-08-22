# comprofix.com

Source for the [comprofix.com](https://comprofix.com) site — built with [Hugo](https://gohugo.io) using the [Chirpy](https://github.com/comprofix/comprofix-hugo-theme-chirpy) theme, pulled in as a Hugo Module.

## Prerequisites

- **Go** — required because the theme is imported as a Hugo Module (see `go.mod`). Hugo shells out to `go` to fetch modules.
- **Hugo Extended** — the site uses SCSS asset pipelines, which require the extended edition.
- **Node.js + npm** — only needed to install Dart Sass.
- **Dart Sass (embedded)** — required to compile the theme's SCSS. Hugo does **not** bundle this, even in the extended build.

## Install steps (Debian/Ubuntu)

```sh
# Go
sudo apt-get update
sudo apt-get install -y golang-go

# Hugo (extended)
sudo apt-get install -y hugo
hugo version   # confirm output includes "+extended"

# Node.js + npm
sudo apt-get install -y nodejs npm
```

### Install Dart Sass

Hugo talks to Dart Sass over the **Embedded Sass protocol**, which is only implemented by the `sass-embedded` npm package — not the plain `sass` package (that one is a pure-JS reimplementation with no embedded-host support, and will fail with an `unexpected EOF when executing "sass"` error).

```sh
sudo npm install -g sass-embedded

# Verify — should print a protocol handshake, not an error:
sass --embedded --version
```

For other platforms, see the official install docs: [Hugo](https://gohugo.io/installation/), [Go](https://go.dev/doc/install), [Node.js](https://nodejs.org/en/download).

## Running locally

```sh
git clone git@github.com:comprofix/comprofix.com.git
cd comprofix.com
hugo server
```

Hugo will download the theme module on first run. Site will be available at `http://localhost:1313`.

## Production build

```sh
hugo --minify --gc --enableGitInfo
```

Output goes to `public/` (gitignored).

## Building with Docker instead

To skip local tool installation entirely, build via the provided `Dockerfile`, which uses `hugomods/hugo:exts` (bundles Hugo Extended + Dart Sass) and serves the result with nginx:

```sh
docker build -t comprofix.com .
docker run --rm -p 8080:80 comprofix.com
```

## Troubleshooting

**`ERROR TOCSS-DART: ... this feature is not available in your current Hugo version`**
Dart Sass isn't installed. Follow the [Install Dart Sass](#install-dart-sass) steps above.

**`got unexpected EOF when executing "sass"`**
You have the plain `sass` npm package installed instead of `sass-embedded`. Fix:

```sh
sudo npm uninstall -g sass
sudo npm install -g sass-embedded
```

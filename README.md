# Latex Dev Container

A complete development container for Latex for use with VSCode/GitHub Codespaces

---

## Features

 - [`texlive`](https://tug.org/texlive/) install (images for basic and small)
 - Compile to PDF with [`latexmk`](https://mg.readthedocs.io/latexmk.html)
 - Format with [`latexindent`](https://latexindentpl.readthedocs.io/en/latest/)
 - Lint with [`chktex`](https://www.nongnu.org/chktex/)
 - Spelling and grammar checking with [`ltex-ls`](https://github.com/valentjn/ltex-ls)
 - Include SVG graphics with [`inskscape`](https://inkscape.org)
 - All the features provided via [`LaTeX-Workshop`](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop)
 - Install more packages with [`tlmgr`](https://www.tug.org/texlive/tlmgr.html)
 - Sits atop my [dotfiles](https://github.com/willfantom/.files)
 - Use on `amd64` and `aarch64`

## Local Usage Requirements

- [Docker](https://www.docker.com/products/docker-desktop) installed and running
- [VS code](https://code.visualstudio.com/download) installed
- [VS code remote containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) installed

## Usage

 1. In the root of your project, create a directory named `.devcontainer`
 2. Copy the `devcontainer.json` file from this repository to the newly created directory
 3. **optional:** Change to image being used for the devcontainer by updating the `image` field in the JSON file. For example, use the full texlive install scheme: `ghcr.io/willfantom/devcontainer-latex:latest-full`
 4. **optional:** Add other packages to be installed by `tlmgr` when the container starts to the `postCreateCommand` field in the JSON file
 5. Open the project in the devontainer via the [devcontainer CLI](https://github.com/devcontainers/cli), the commands in VSCode, or in a GitHub Codespace

### Full TexLive Install

For this, you will have to build the container with the build arg `TEX_SCHEME` set to `full`. This may end up being around 6GB once built... Make sure to set the `image` field in the devcontainer JSON file to the tag of your full scheme image.

---

This has been extended from [qdm12/latexdevcontainer](https://github.com/qdm12/latexdevcontainer) with the following core changes:

 - Inclusion of [`ltex-ls`](https://github.com/valentjn/ltex-ls) to use with the LanguageTool and [LTeX](https://marketplace.visualstudio.com/items?itemName=valentjn.vscode-ltex) extensions to provide grammar and spell checking in tex documents.
 - Inclusion of [`inskscape`](https://inkscape.org) to allow the inclusion of SVG graphics in tex documents.
 - No explicit reference to texlive **2022** in the Dockerfile.
 - Building [`biblatex`](https://github.com/plk/biblatex) from source to get a specific version regardless of version provided by the package manager (`tlmgr`). This has been done since `biblatex` and `biber` are heavily tied to one another and can easily become incompatible.
 - No use of `docker-compose` to simplify the devcontainer setup process.
 - My [dotfiles](https://github.com/willfantom/.files) are used as the base of the image. This offers no real difference in most use cases, but it is a change I guess.





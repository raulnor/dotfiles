# Junk Drawer
This is a collection of my miscellaneous scripts and customizations.

## Running Scripts
If you're grabbing this to run something, you'll to want the following above and beyond standard UNIX and Perl/Python/Ruby/Shell:

- [fzf](https://github.com/junegunn/fzf)
- [ImageMagick](https://github.com/ImageMagick/ImageMagick)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [uv](https://docs.astral.sh/uv/)

## Installation
- `make` or `make scripts` - Installs all scripts from `src/bin/` to `$(HOME)/bin` with executable permissions and removes file extensions

## Directory Layout
- `bin/` - Current collection of executable scripts
- `old/` - Legacy scripts and utilities (archived)
- `Makefile` - Simple build system for script installation

## Working with Scripts
- All scripts should be executable and include appropriate shebangs
- When adding new scripts, place them in `bin/` directory
- Run `make` to install after adding or modifying scripts
- Scripts should handle their own dependencies and provide usage information
- Python scripts should use `uv run --script` in their shebang
- Python scripts should list dependancies based on [PEP 723](https://peps.python.org/pep-0723/)
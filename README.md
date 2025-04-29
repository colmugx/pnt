# PNT(Pico NodeJS Toolkit)

[![Release Build](https://github.com/colmugx/pnt/actions/workflows/release.yml/badge.svg)](https://github.com/colmugx/pnt/actions/workflows/release.yml)

[简体中文](README-zh.md) | [日本語](README-ja.md)

PNT(Pico NodeJS Toolkit) is a Node.js management tool built on Moonbit including a fast version manager similar to `gmn` and `fnm`, and a registry manager similar to `nrm`.

(This project is experimental. Do not use it in production.)

## Main Features

- **High Performance**: Fast execution speed for common operations, low memory usage, suitable for resource-constrained environments.
- **Versatile Features**:
  - Remote version listing with LTS filter support
  - Quick installation, switching, and uninstallation of Node.js versions
  - Registry management for easy switching of Node.js mirrors
- **Lightweight**: Minimal resource consumption for local operations, suitable for various scenarios

## Usage

PNT is a command-line tool that can be used as follows:

### List Remote Modules

```bash
pnt list_remote
```

To list only LTS versions:

```bash
pnt list_remote --lts
```

### Install a Specific Version

```bash
pnt install <version>
```

To install the latest LTS:

```bash
pnt install lts
```

### Switch to a Specific Version

```bash
pnt use <version>
```

To switch to the latest LTS:

```bash
pnt use lts
```

## Build Guide

1. Clone the repository:
   ```bash
   git clone https://github.com/colmugx/pnt.git
   ```
2. Enter the project directory:
   ```bash
   cd pnt
   ```
3. Install dependencies and build the project (ensure all required dependencies are installed):
   ```bash
   moon build --target native
   ```

## Notes

1. Requires Zig 0.11.0 or later.
2. Ensure that the MoonBit runtime environment is properly set up.
3. The current code only supports macOS/aarch64 platform.

## Inspired

- [akazwz/gnm](https://github.com/akazwz/gnm)

## License

This project is licensed under the MIT License. For details, see [LICENSE](LICENSE).

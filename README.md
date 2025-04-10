# NTM

[简体中文](README-zh.md) | [日本語](README-ja.md)

NTM (Node Tool in Moonbit) is a fast Node.js version management tool built on Moonbit, similar to `gmn` and `fnm`.

(This project is experimental. Do not use it in production.)

## Main Features

- **User-friendly**: Built-in common commands (such as list_remote, install, use) make it easy to get started.

## Usage

NTM is a command-line tool that can be used as follows:

### List Remote Modules

```bash
ntm list_remote
```

To list only LTS versions:

```bash
ntm list_remote --lts
```

### Install a Specific Version

```bash
ntm install <version>
```

To install the latest LTS:

```bash
ntm install lts
```

### Switch to a Specific Version

```bash
ntm use <version>
```

To switch to the latest LTS:

```bash
ntm use lts
```

## Build Guide

1. Clone the repository:
   ```bash
   git clone https://github.com/colmugx/ntm.git
   ```
2. Enter the project directory:
   ```bash
   cd ntm
   ```
3. Install dependencies and build the project (ensure all required dependencies are installed):
   ```bash
   moon build --target native
   ```

## Notes

1. Requires Zig 0.11.0 or later.
2. Ensure that the MoonBit runtime environment is properly set up.
3. The current code only supports macOS/aarch64 platform.

## License

This project is licensed under the MIT License. For details, see [LICENSE](LICENSE).

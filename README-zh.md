# NTM

NTM（Node Tool in Moonbit ~~(for Development)~~） 是一个基于 Moonbit 的，快速的 Node.js 版本管理工具，类似于 `gmn`, `fnm`。

（项目为实验性项目，请**完全不要**投入生产环境使用）

## 主要特点

- **易用性高**：内置常用命令（如 list_remote、install、use 等），简单上手。

## 使用方法

NTM 基于命令行操作，可通过以下方式使用：

### 列出远程模块

```bash
ntm list_remote
```

可以只列出 `lts`

```bash
ntm list_remote --lts
```

### 安装指定模块

```bash
ntm install <version>
```

可以安装最新 `lts`

```bash
ntm install lts
```

### 切换使用指定版本

```bash
ntm use <version>
```

可以使用最新 `lts`

```bash
ntm use lts
```

## 构建指南

1. 克隆该仓库：
   ```bash
   git clone https://github.com/colmugx/ntm.git
   ```
2. 进入项目目录：
   ```bash
   cd ntm
   ```
3. 安装依赖并构建项目（请确保已安装所需依赖）：
   ```bash
   moon build --target native
   ```

## 注意事项

1. 需要安装 Zig 0.11.0 或更高版本
2. 确保已正确设置 MoonBit 运行时环境
3. 代码仅支持 macOS/aarch64 平台

## 许可证

本项目采用 MIT 许可证，详细信息请见 [LICENSE](LICENSE) 文件。

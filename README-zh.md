# PNT(Pico NodeJS Toolkit)

PNT(Pico NodeJS Toolkit) 是一个基于 Moonbit 开发的 NodeJS 工具

其包含快速的 Node.js 版本管理工具，类似于 `gmn`, `fnm`，以及快速的源切换工具，类似于 `nrm`

（项目为实验性项目，请**完全不要**投入生产环境使用）

## 主要特点

- **高性能**：常用操作响应迅速，内存占用低，适合在资源有限的环境下运行。
- **功能丰富**：
  - 支持远程版本列表及 LTS 过滤
  - 快速安装、切换和卸载 Node.js 版本
  - 支持源管理，便于切换不同的 Node.js 镜像源
- **轻量级**：本地操作资源占用极小，适合多种场景使用。

## 使用方法

PNT 基于命令行操作，可通过以下方式使用：

### 列出远程模块

```bash
pnt list_remote
```

可以只列出 `lts`

```bash
pnt list_remote --lts
```

### 安装指定模块

```bash
pnt install <version>
```

可以安装最新 `lts`

```bash
pnt install lts
```

### 切换使用指定版本

```bash
pnt use <version>
```

可以使用最新 `lts`

```bash
pnt use lts
```

## 构建指南

1. 克隆该仓库：
   ```bash
   git clone https://github.com/colmugx/pnt.git
   ```
2. 进入项目目录：
   ```bash
   cd pnt
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

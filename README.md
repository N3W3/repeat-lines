# rl (repeat-lines)

A fast, lightweight, and versatile command-line utility written in Zsh to generate and append formatted repetitive lines to files with dynamic placeholders, custom ranges, and zero-padding.

[![Shell](https://img.shields.io/badge/shell-zsh-blue.svg)](https://www.zsh.org/)
[![Platform](https://img.shields.io/badge/platform-linux%20%7C%20macos-lightgrey.svg)](#requirements)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage & Syntax](#usage--syntax)
  - [3-Argument Syntax (Count or Range)](#1-three-argument-syntax-count-or-range)
  - [4-Argument Syntax (Explicit Bounds)](#2-four-argument-syntax-explicit-bounds)
- [Placeholders Reference](#placeholders-reference)
- [Examples](#examples)
  - [Basic Repetition](#1-basic-repetition)
  - [1-Based Counter](#2-1-based-counter)
  - [0-Based Indexing](#3-0-based-indexing)
  - [Zero-Padded Numbers](#4-zero-padded-numbers)
  - [Custom Ranges](#5-custom-ranges)
  - [Using Bounds and Total Count](#6-combining-bounds-and-total-count)
  - [Real-World Use Cases](#7-real-world-scenarios)
- [Error Handling](#error-handling)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

When testing, mocking configuration files, or building test data, you often need to generate multiple similar lines with incrementing counters, padded IDs, or formatted hostnames. 

`rl` streamlines this task into a single command: provide your template text, iteration count or range, and destination file. It takes care of variable substitutions and safely appends the generated lines directly to your target file.

---

## Features

- **Flexible Iteration Bounds**: Run $N$ times (1 to $N$), specify ranges (`3..7`), or pass start and end as distinct arguments (`3 7`).
- **Rich Placeholder System**:
  - 1-based indices (`{i}`, `{n}`, `{index}`, `{}`)
  - 0-based indices (`{i0}`, `{n0}`)
  - Dynamic zero-padding with configurable width (`{i:02}`, `{n:05}`)
  - Range metadata (`{start}`, `{end}`, `{total}`, `{count}`)
- **Safe & Non-Destructive**: Always appends (`>>`) without overwriting existing file content.
- **Auto-Directory Creation**: Automatically creates missing parent directories (`mkdir -p`) if the target file path contains them.
- **Robust Validation**: Enforces strict argument checks, positive integers, and bounds consistency (`start <= end`), emitting clear errors to `stderr`.

---

## Requirements

- **Zsh** (Z Shell) 5.0 or higher.
- Standard Unix utilities (`dirname`, `mkdir`, `printf`).

Compatible with Linux, macOS, and WSL environments.

---

## Installation

### Clone the Repository

```bash
git clone https://github.com/N3W3/repeat-lines.git
cd repeat-lines
chmod +x rl.sh
```

### (Optional) Make it Globally Accessible

To use `rl` anywhere from your terminal:

```bash
# Option A: Symlink to ~/.local/bin (recommended for single-user)
mkdir -p ~/.local/bin
ln -s "$(pwd)/rl.sh" ~/.local/bin/rl

# Option B: Copy to /usr/local/bin (system-wide, requires sudo)
sudo cp rl.sh /usr/local/bin/rl
```

Ensure `~/.local/bin` is included in your `$PATH`.

---

## Usage & Syntax

`rl` supports two calling conventions:

### 1. Three-Argument Syntax (Count or Range)

```bash
./rl.sh <text> <count_or_range> <target_file>
```

- `<text>`: The string template to repeat (wrap in quotes if it contains spaces or special characters).
- `<count_or_range>`:
  - An integer $N > 0$ to iterate from `1` to $N$ (e.g. `5`).
  - A range formatted as `start..end` (e.g. `3..7` or `0..10`).
- `<target_file>`: The path to the destination file. Created if it does not exist.

### 2. Four-Argument Syntax (Explicit Bounds)

```bash
./rl.sh <text> <start> <end> <target_file>
```

- `<text>`: The string template to repeat.
- `<start>` and `<end>`: The explicit starting and ending indices, separated by a space (e.g., `3 7`). `<start>` must be a non-negative integer ($\ge 0$), and `<end>` must be $\ge$ `<start>`.
- `<target_file>`: The path to the destination file.

---

## Placeholders Reference

You can embed any combination of the following placeholders inside your `<text>` template:

| Placeholder | Description | Example Output (`i=5`, `range=3..7`) |
| :--- | :--- | :--- |
| `{i}`, `{n}`, `{index}`, `{}` | Current iteration counter | `5` |
| `{i:0X}`, `{n:0X}` | Zero-padded counter to $X$ digits (e.g., `{i:03}`) | `005` |
| `{i0}`, `{n0}` | 0-based counter (`i - 1`) | `4` |
| `{start}` | Starting index of the current sequence | `3` |
| `{end}` | Ending index of the current sequence | `7` |
| `{total}`, `{count}` | Total iterations generated (`end - start + 1`) | `5` |

> [!TIP]
> Always wrap your `<text>` in double quotes (`"..."`) or single quotes (`'...'`) in the shell so that placeholders and special characters aren't interpreted prematurely by your shell.

---

## Examples

### 1. Basic Repetition

Append static separators or placeholder lines:

```bash
./rl.sh "----------------------------------------" 3 output.txt
```

**`output.txt`:**
```text
----------------------------------------
----------------------------------------
----------------------------------------
```

### 2. 1-Based Counter

Use `{i}`, `{n}`, `{index}`, or `{}`:

```bash
./rl.sh "Step {i}: Processing job {index}" 4 steps.log
```

**`steps.log`:**
```text
Step 1: Processing job 1
Step 2: Processing job 2
Step 3: Processing job 3
Step 4: Processing job 4
```

### 3. 0-Based Indexing

Useful for 0-indexed arrays, arrays in JSON, or programming lists:

```bash
./rl.sh "item[{i0}] = 'Value {i}'" 3 items.txt
```

**`items.txt`:**
```text
item[0] = 'Value 1'
item[1] = 'Value 2'
item[2] = 'Value 3'
```

### 4. Zero-Padded Numbers

Specify any width format with `{i:0X}` or `{n:0X}`:

```bash
./rl.sh "image_{i:04}.png" 4 gallery.txt
```

**`gallery.txt`:**
```text
image_0001.png
image_0002.png
image_0003.png
image_0004.png
```

### 5. Custom Ranges

Iterate over a specific slice without starting from 1:

**Using range syntax (`start..end`):**
```bash
./rl.sh "Worker #{} active" 8..11 workers.txt
```

**Using separate arguments (`start` `end`):**
```bash
./rl.sh "Worker #{} active" 8 11 workers.txt
```

**Both yield:**
```text
Worker #8 active
Worker #9 active
Worker #10 active
Worker #11 active
```

### 6. Combining Bounds and Total Count

Keep track of progress or metadata directly in the generated line:

```bash
./rl.sh "Node {i:02}/{end} (Processed {i}/{total} items)" 3 6 cluster.log
```

**`cluster.log`:**
```text
Node 03/6 (Processed 3/4 items)
Node 04/6 (Processed 4/4 items)
Node 05/6 (Processed 5/4 items)
Node 06/6 (Processed 6/4 items)
```

### 7. Real-World Scenarios

#### Generating Mock `/etc/hosts` or DNS Records
```bash
./rl.sh "192.168.1.{i}   kube-node-{i:02}.cluster.local" 1 10 hosts.txt
```

#### Creating Test CSV / Data Fixtures
```bash
./rl.sh "{i},user_{i:03}@example.com,active" 5 users.csv
```

#### Writing into Nested Directories
Parent directories are created automatically if they do not exist:
```bash
./rl.sh "cache_block_{i}" 3 build/tmp/cache/manifest.txt
```

---

## Error Handling

`rl` checks parameters before writing any data and exits with code `1` on error:

- **Invalid argument count**: Displays usage help.
- **Invalid count/range**: Rejects negative numbers, malformed ranges, or non-numeric values.
- **Inverted range bounds**: Rejects calls where `start > end` (e.g., `10..5` or `10 5`).
- **File & directory permissions**: Warns if parent directories cannot be created or target files cannot be appended to.

---

## Contributing

Contributions, issues, and feature requests are welcome! Feel free to open an issue or submit a pull request on GitHub.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

This project is open-source and available under the [MIT License](LICENSE).

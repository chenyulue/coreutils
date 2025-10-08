# Package

version = "0.1.0"
author = "chenyulue"
description = "A GNU coreutils implemented by nim, ported from C source."
license = "MIT"
srcDir = "src"
bin = @["true", "false", "echo"]
binDir = "bin"

# Dependencies

requires "nim >= 2.2.4"

requires "cligen >= 1.9.3"

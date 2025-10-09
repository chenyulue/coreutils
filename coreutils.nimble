# Package

version = "0.1.0"
author = "Chenyu Lue"
description = "A GNU coreutils implemented by nim, ported from C source."
license = "MIT"
srcDir = "src"
bin = @["true", "false", "echo"]
binDir = "bin"

switch("d", "Version=" & version)
switch("d", "Author=" & author)

# Dependencies

requires "nim >= 2.2.4"
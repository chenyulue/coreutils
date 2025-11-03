let buildDir = "build"

version = "0.1.0"
author = "Chenyu Lue"
description = "A GNU coreutils implemented by nim, ported from C source."
license = "MIT"
srcDir = "src"
bin = @["true", "false", "echo", "cat"]
binDir = buildDir & "/bin"

switch("d", "Version=" & version)
switch("d", "Author=" & author)

# Dependencies

requires "nim >= 2.2.4"
requires "therapist >= 0.3.0"
import std/[unittest, osproc, strutils]
import ../src/defs

suite "test the true command":
  setup:
    let exe = "./bin/true"

  test "true return 0":
    let (output, errCode) = execCmdEx(exe)
    check:
      errCode == QuitSuccess
      output == ""

  test "help argument gives help info":
    let (output, errCode) = execCmdEx(exe & " --help")
    check:
      errCode == QuitSuccess
      "success" in output

  test "version argument gives version info":
    let (output, errCode) = execCmdEx(exe & " --version")
    check:
      errCode == QuitSuccess
      Version in output

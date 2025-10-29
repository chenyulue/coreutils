import std/[unittest, osproc, strutils]
import ../src/defs

suite "test the false command":
  setup:
    let exe = "./build/bin/false"

  test "false return 1":
    let (output, errCode) = execCmdEx(exe)
    check:
      errCode == QuitFailure
      output == ""

  test "help argument gives help info":
    let (output, errCode) = execCmdEx(exe & " --help")
    check:
      errCode == QuitFailure
      "failure" in output

  test "version argument gives version info":
    let (output, errCode) = execCmdEx(exe & " --version")
    check:
      errCode == QuitFailure
      version in output

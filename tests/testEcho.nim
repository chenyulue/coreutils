import std/[unittest, osproc, strutils]
import ../src/defs

suite "test the echo command":
  setup:
    let exe = "./bin/echo"

  test "echo --help":
    let (output, errCode) = execCmdEx(exe & " --help")
    check:
      errCode == QuitSuccess
      "Echo the STRING(s) to standard output" in output

  test "echo --version":
    let (output, errCode) = execCmdEx(exe & " --version")
    check:
      errCode == QuitSuccess
      Version in output
  
  test "echo a normal   string":
    let (output, errCode) = execCmdEx(exe & " a normal   string")
    check:
      errCode == QuitSuccess
      output == "a normal string\n"
  
  test "echo hello\\nworld":
    let (output, errCode) = execCmdEx(exe & " hello\\nworld")
    check:
      errCode == QuitSuccess
      output == "hello\\nworld\n"

  test "echo -e hello\\nworld":
    let (output, errCode) = execCmdEx(exe & " -e hello\\nworld")
    check:
      errCode == QuitSuccess
      output == "hello\nworld\n"

  test "echo -e -E hello\\nworld":
    let (output, errCode) = execCmdEx(exe & " -e -E hello\\nworld")
    check:
      errCode == QuitSuccess
      output == "hello\\nworld\n"

  test "echo -n hello world":
    let (output, errCode) = execCmdEx(exe & " -n hello world")
    check:
      errCode == QuitSuccess
      output == "hello world\n"

  test "echo -e hell\\coworld":
    let (output, errCode) = execCmdEx(exe & " -e hell\\coworld")
    check:
      errCode == QuitSuccess
      output == "hell\n"

  test "echo -g -e hello\\nworld":
    let (output, errCode) = execCmdEx(exe & " -g -e hello\\nworld")
    check:
      errCode == QuitSuccess
      output == "-g -e hello\\nworld\n"

  test "echo -E -g -e hello\\nworld":
    let (output, errCode) = execCmdEx(exe & " -E -g -e hello\\nworld")
    check:
      errCode == QuitSuccess
      output == "-g -e hello\\nworld\n"

  test "echo -e \\":
    let (output, errCode) = execCmdEx(exe & " -e \\")
    check:
      errCode == QuitSuccess
      output == "\\\n"
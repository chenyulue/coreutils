import std/[cmdline, envvars, exitprocs, assertions, strutils]
import defs

# if true, interprete backslash escapes by default.
when not defined(DefaultEchoToXpg):
  const DefaultEchoToXpg = false
else:
  const DefaultEchoToXpg = true

const ProgramName = "echo"

proc usage(status: int) =
  assert status == QuitSuccess

  let usageMsg =
    """
Usage: $1 [SHORT-OPTION]... [STRING]...
   or: $1 LONG-OPTION"""
  echo usageMsg.format(programName)

  echo """
Echo the STRING(s) to standard output.
  
  -n             do not output the trailing newline"""
  let helpInfo =
    if DefaultEchoToXpg:
      """
  -e             enable interpretation of backslash escapes (default)
  -E             disable interpretation of backslash escapes"""
    else:
      """
  -e             enable interpretation of backslash escapes
  -E             disable interpretation of backslash escapes (default)"""
  echo helpInfo
  echo HelpOptionDescription
  echo VersionOptionDescription
  echo ""
  echo """
If -e is in effect, the following sequences are recognized:
  \\      backslash
  \a      alert (BEL)
  \b      backspace
  \c      produce no further output
  \e      escape
  \f      form feed
  \n      new line
  \r      carriage return
  \t      horizontal tab
  \v      vertical tab
  \0NNN   byte with octal value NNN (1 to 3 digits)
  \xHH    byte with hexadecimal value HH (1 to 2 digits)"""
  echo ""
  echo UsageBuiltinWarning.format(ProgramName)
  quit(status)

proc hextobin(c: char): int =
  case c
  of 'a', 'A':
    result = 10
  of 'b', 'B':
    result = 11
  of 'c', 'C':
    result = 12
  of 'd', 'D':
    result = 13
  of 'e', 'E':
    result = 14
  of 'f', 'F':
    result = 15
  else:
    result = ord(c) - ord('0')

proc main() =
  var displayReturn = true
  let posixlyCorrect = existsEnv("POSIXLY_CORRECT")
  var allowOptions =
    (not posixlyCorrect) or
    (not DefaultEchoToXpg and paramCount() > 0 and paramStr(1) == "-n")

  #[Sysstem V machines already have a /bin/sh with a v9 behavior. Use the
  identical behavior for these mechines so that the existing system shell
  scripts won't barf.]#
  var doV9 = DefaultEchoToXpg

  addExitProc(closeStdout)

  if allowOptions and paramCount() == 1:
    if paramStr(1) == "--help":
      usage(QuitSuccess)
    if paramStr(1) == "--version":
      echo versionStr.format(ProgramName, Version, Author)
      quit(QuitSuccess)

  var start: int = 1
  if allowOptions:
    for i in 1 .. paramCount():
      let param = paramStr(i)

      # Once the parameter is not the allowed "-e", "-E" and "-n", break
      # the loop and output the remaining parameters
      if param != "-e" and param != "-E" and param != "-n":
        start = i
        break

      if param == "-e":
        doV9 = true
      if param == "-E":
        doV9 = false
      if param == "-n":
        displayReturn = false

  for i in start .. paramCount():
    var param = paramStr(i)

    # if doV9 or posixlyCorrect:

    stdout.write(param)
    if i < paramCount():
      stdout.write(" ")

  if displayReturn:
    stdout.write("\n")

  quit(QuitSuccess)


when isMainModule:
  main()

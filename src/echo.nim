import std/[cmdline, envvars, strutils, os, parseopt]
import therapist
import defs

# if true, interprete backslash escapes by default.
const DefaultEchoToXpg {.booldefine.} = false

let
  defaultEscapeOn = if DefaultEchoToXpg: "(default)" else: ""
  defaultEscapeOff = if DefaultEchoToXpg: "" else: "(default)"

let
  programName = extractFilename(getAppFilename())
  versionInfo = createVersionInfo(authors, version, programName)
  prolog = "Echo the STRING(s) to standard output."
  epilog =
    """
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

let echoSpec = (
  newline: newFlagArg(@["-n"], help = "do not output the trailing newline"),
  escapeOn: newFlagArg(
    @["-e"], help = "enable interpretation of backslash escapes " & defaultEscapeOn
  ),
  escapeOff: newFlagArg(
    @["-E"], help = "disable interpretation of backslash escapes " & defaultEscapeOff
  ),
  args: newStringArg(
    @["<args>"], help = "strings to be printed", multi = true, optional = true
  ),
  help: newHelpArg(@["-h", "--help"], help = "display this help and exit"),
  version: newMessageArg(
    @["--version"], versionInfo, help = "output version information and exit"
  ),
)

type HexChar = range['0' .. '9'] | range['a' .. 'f'] | range['A' .. 'F']

proc hexToBin(c: HexChar): int =
  case c
  of 'a' .. 'f':
    result = ord(c) - ord('a') + 10
  of 'A' .. 'F':
    result = ord(c) - ord('A') + 10
  else:
    result = ord(c) - ord('0')

proc escapeStr(s: string): (bool, string) =
  var strEscaped = newStringOfCap(s.len)

  var i = 0
  while i < s.len:
    var c = s[i]
    if c == '\\' and i < s.len - 1:
      case s[i + 1]
      of 'a':
        c = '\a'
        inc i, 2
      of 'b':
        c = '\b'
        inc i, 2
      of 'c':
        # if \c is met, return immediately, and returned false means no further output for echo
        return (false, strEscaped)
      of 'e':
        c = '\x1B'
        inc i, 2
      of 'f':
        c = '\f'
        inc i, 2
      of 'n':
        c = '\n'
        inc i, 2
      of 'r':
        c = '\r'
        inc i, 2
      of 't':
        c = '\t'
        inc i, 2
      of 'v':
        c = '\v'
        inc i, 2
      of 'x':
        if i <= s.len - 3 and s[i + 2] in HexDigits:
          c = char(hexToBin(s[i + 2]))
          if i <= s.len - 4 and s[i + 3] in HexDigits:
            c = char(hexToBin(s[i + 2]) * 16 + hexToBin(s[i + 3]))
            inc i, 1
          inc i, 3
        else:
          inc i, 1
      of '0':
        c = char(0)
        if i <= s.len - 3 and s[i + 2] in ('0' .. '7'):
          c = char(hexToBin(s[i + 2]))
          if i <= s.len - 4 and s[i + 3] in ('0' .. '7'):
            c = char(ord(c) * 8 + hexToBin(s[i + 3]))
            if i <= s.len - 5 and s[i + 4] in ('0' .. '7'):
              c = char(ord(c) * 8 + hexToBin(s[i + 4]))
              inc i, 1
            inc i, 1
          inc i, 3
        else:
          inc i, 2
      of '\\':
        inc i, 2
      else:
        inc i, 1
    else:
      inc i, 1
    strEscaped.add(c)

  return (true, strEscaped)

proc main() =
  var displayReturn = true

  # If the `POSIXLY_CORRECT` environment variable is set, then when echo's first 
  # argument is not -n, it outputs option-like arguments instead of treating them 
  # as options.
  let posixlyCorrect = existsEnv("POSIXLY_CORRECT")
  var allowOptions =
    (not posixlyCorrect) or
    (not DefaultEchoToXpg and paramCount() > 0 and paramStr(1) == "-n")

  #[Sysstem V machines already have a /bin/sh with a v9 behavior. Use the
  identical behavior for these mechines so that the existing system shell
  scripts won't barf.]#
  var doV9 = DefaultEchoToXpg

  if allowOptions and paramCount() == 1:
    if paramStr(1) == "--help":
      echo renderHelp(echoSpec, prolog, epilog)
    if paramStr(1) == "--version":
      echo versionInfo
    quit(QuitSuccess)

  var start: int = 1
  if allowOptions:
    for i in 1 .. paramCount():
      let param = paramStr(i)

      # Once the parameter is not the allowed "-e", "-E" and "-n", break
      # the loop and output the remaining parameters
      if param != "-e" and param != "-E" and param != "-n":
        start = i - 1
        break

      if param == "-e":
        doV9 = true
      if param == "-E":
        doV9 = false
      if param == "-n":
        displayReturn = false

  let argsLeft = commandLineParams()[start .. ^1]

  # if the POSIXLY_CORRECT environment variable is set,
  # backslash escapes are always enabled
  if doV9 or posixlyCorrect:
    var outputStr = newSeqOfCap[string](argsLeft.len)
    for arg in argsLeft:
      let (outputNext, str) = escapeStr(arg)
      outputStr.add(str)
      if not outputNext:
        break
    stdout.write outputStr.join(" ")
  else:
    stdout.write argsLeft.join(" ")

  if displayReturn:
    stdout.write("\n")

  quit(QuitSuccess)

when isMainModule:
  main()

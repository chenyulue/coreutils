import std/[cmdline, envvars, strutils, os]
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

proc parseHexEscape(s: string, i: var int): char = 
  # initial value of i is the index of the '\'
  if i + 2 >= s.len or s[i+2] notin HexDigits:
    raise newException(ValueError, "Invalid hex escape sequence")

  if i + 3 < s.len and s[i+3] in HexDigits:
    result = char(parseHexInt(s[i+2 .. i+3]))
    inc i, 4
  else:
    result = char(parseHexInt(s[i+2 .. i+2]))
    inc i, 3

proc parseOctalEscape(s: string, i: var int): char = 
  # initial value of i is the index of the '\'
  var digits = 0
  while digits < 3 and (i+2+digits) < s.len and s[i+2+digits] in ('0' .. '7'):
    digits += 1

  if digits == 0:
    raise newException(ValueError, "Invalid octal escape sequence")

  result = char(parseOctInt(s[i+2 ..< i+2+digits]))
  inc i, digits+2

proc parseSimpleEscape(c: char, i: var int): char =
  case c
  of 'a': result = '\a'
  of 'b': result = '\b'
  of 'e': result = '\x1B'
  of 'f': result = '\f'
  of 'n': result = '\n'
  of 'r': result = '\r'
  of 't': result = '\t'
  of 'v': result = '\v'
  of '\\': result = '\\'
  else: 
    raise newException(ValueError, "Unknown escape sequence: \\" & $c)

  inc i, 2

proc escapeStr(s: string): (bool, string) =
  var strEscaped = newStringOfCap(s.len)

  var i = 0
  while i < s.len:
    var c = s[i]
    if c == '\\' and i < s.len - 1:
      case s[i + 1]
      of 'c':
        # if \c is met, return immediately, and returned false means no further output for echo
        return (false, strEscaped)
      of 'x':
        try:
          c = parseHexEscape(s, i)
        except ValueError:
          inc i
      of '0':
        try:
          c = parseOctalEscape(s, i)
        except ValueError:
          inc i, 2
          continue
      else:
        try:
          c = parseSimpleEscape(s[i+1], i)
        except ValueError:
          inc i
    else:
      inc i
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
      quit(QuitSuccess)
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
        start = i
        break

      if param == "-e":
        doV9 = true
      if param == "-E":
        doV9 = false
      if param == "-n":
        displayReturn = false

  var argsLeft = newSeqOfCap[string](paramCount() - start + 1)

  for i in start .. paramCount():
    # if the POSIXLY_CORRECT environment variable is set,
    # backslash escapes are always enabled
    if doV9 or posixlyCorrect:
      let (outputNext, str) = escapeStr(paramStr(i))
      argsLeft.add(str)
      if not outputNext:
        break
    else:
      argsLeft.add(paramStr(i))

  stdout.write(argsLeft.join(" "))

  if displayReturn:
    stdout.write("\n")

  quit(QuitSuccess)

when isMainModule:
  main()

import std/[strutils, cmdline, os]
import therapist
import defs

when not declared(ExitStatus):
  const ExitStatus = QuitSuccess

let 
  programName = extractFilename(getAppFilename())
  versionInfo = createVersionInfo(authors, version, programName)
  prolog =
    if ExitStatus == QuitSuccess:
      "Exit with a status code indicating success."
    else:
      "Exit with a status code indicating failure."
  epilog = 
    if ExitStatus == QuitSuccess:
      "Note: it is possible to cause true to exit with nonzero status: with the " &
       "--help or --version option, and with standard output already closed or " &
       "redirected to a file that evokes an I/O error."
    else:
      ""

let trueSpec = (
  help: newHelpArg(@["-h", "--help"], help="display this help and exit"),
  version: newMessageArg(@["--version"], versionInfo, help="output version information and exit")
)

proc main() =
  let (success, message) = parseOrMessage(trueSpec, prolog, epilog)
  # true ignores any options or arguments except --help and --version, 
  # and always exits with a status code indicating success.
  if not success:
    quit(ExitStatus)
  elif message.isSome:
    runWithIOErrorHandling:
      quit(message.get, ExitStatus)

  quit(ExitStatus)

when isMainModule:
  main()

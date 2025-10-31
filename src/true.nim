import std/[cmdline, os]
import therapist
import defs

when not declared(ExitStatus):
  const ExitStatus = QuitSuccess

let
  programName = extractFilename(getAppFilename())
  versionInfo = createVersionInfo(authors, version, programName)
  prolog =
    when ExitStatus == QuitSuccess:
      "Exit with a status code indicating success."
    else:
      "Exit with a status code indicating failure."
  epilog =
    when ExitStatus == QuitSuccess:
      "Note: it is possible to cause true to exit with nonzero status: with the " &
        "--help or --version option, and with standard output already closed or " &
        "redirected to a file that evokes an I/O error."
    else:
      ""

let trueSpec = (
  help: newHelpArg(@["-h", "--help"], help = "display this help and exit"),
  version: newMessageArg(
    @["--version"], versionInfo, help = "output version information and exit"
  ),
)

proc main() =
  # true ignores any options or arguments except --help and --version, 
  # and always exits with a status code indicating success.
  runWithIOErrorHandling:
    if paramCount() == 1:
      if paramStr(1) == "--help" or paramStr(1) == "-h":
        echo renderHelp(trueSpec, prolog, epilog)
        quit(ExitStatus)
      if paramStr(1) == "--version":
        echo versionInfo
        quit(ExitStatus)

  quit(ExitStatus)

when isMainModule:
  main()

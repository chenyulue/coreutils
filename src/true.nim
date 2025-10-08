import std/[strutils, cmdline, exitprocs]
import defs

when not declared(ExitStatus):
  const ExitStatus = QuitSuccess

when ExitStatus == QuitSuccess:
  const ProgramName = "true"
else:
  const ProgramName = "false"

proc usage(status: int) =
  let usageMsg =
    """
Usage: $1 [ignored command line arguments]
   or: $1 OPTION"""
  echo usageMsg.format(programName)

  let descrpt =
    if ExitStatus == QuitSuccess:
      "Exit with a status code indicating success.\n"
    else:
      "Exit with a status code indicating failure.\n"
  echo descrpt

  echo HelpOptionDescription
  echo VersionOptionDescription
  echo ""
  echo UsageBuiltinWarning.format(ProgramName)

  quit(status)

proc main() =
  if paramCount() == 1:
    addExitProc(closeStdout)

    if paramStr(1) == "--help":
      usage(ExitStatus)
    if paramStr(1) == "--version":
      echo versionStr.format(
        ProgramName, Version, Author
      )

  quit(ExitStatus)

when isMainModule:
  main()

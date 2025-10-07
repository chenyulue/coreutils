import std/[strutils, cmdline, exitprocs]
import defs

when not declared(ExitStatus):
  const ExitStatus = QuitSuccess

when ExitStatus == QuitSuccess:
  const ProgramName = "true"
else:
  const ProgramName = "false"

const
  Authors = "Chenyu Lue"
  Version = "0.1.0"

proc usage(status: int) =
  let usageMsg =
    """
Usage: $1 [ignored command line arguments]
   or: $1 OPTION
"""
  echo usageMsg.format(programName)

  let descrpt =
    if ExitStatus == QuitSuccess:
      "Exit with a status code indicating success."
    else:
      "Exit with a status code indicating failure."
  echo descrpt

  echo HelpOptionDescription
  echo VersionOptionDescription
  echo UsageBuiltinWarning.format(ProgramName)

  quit(status)

proc main() =
  if paramCount() == 1:
    addExitProc(closeStdout)

    if paramStr(1) == "--help":
      usage(ExitStatus)
    if paramStr(1) == "--version":
      echo "$1 ($2) by $3".format(ProgramName, Version, Authors)

  quit(ExitStatus)

when isMainModule:
  main()

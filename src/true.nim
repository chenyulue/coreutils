import std/[strutils, cmdline, os]
import defs

when not declared(ExitStatus):
  const ExitStatus = QuitSuccess

let programName = extractFilename(getAppFilename())

proc usage(status: int) =
  let usageMsg = """
Usage: 
  $1 
  $1 (--version | -h | --help)""".format(programName)

  let descrpt =
    if ExitStatus == QuitSuccess:
      "Exit with a status code indicating success."
    else:
      "Exit with a status code indicating failure."

  let optionMsg =
    """
Options:
  -h, --help     Show this help message
      --version  Print version information"""

  echo "$1\n\n$2\n\n$3".format(descrpt, usageMsg, optionMsg)

  quit(status)

proc main() =
  if paramCount() == 1:
    runWithIOErrorHandling:
      if paramStr(1) == "--help":
        usage(ExitStatus)
      if paramStr(1) == "--version":
        echo createVersionInfo(authors, version, programName)

  quit(ExitStatus)

when isMainModule:
  main()

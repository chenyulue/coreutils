import std/os

const
  HelpOptionDescription* = "      --help     display this help and exit"
  VersionOptionDescription* = "      --version  output version information and exit"
  UsageBuiltinWarning* =
    """
NOTE: your shell may have its own version of $1, which usually supersedes
the version described here.  Please refer to your shell's documentation
for details about the options it supports."""
  Author* {.strdefine.} = "unknown"
  Version* {.strdefine.} = "unknown"
  versionStr* = "$1 (Nim coreutils) $2 \n\nWritten by $3"

let programName* = getAppFilename()

proc c_exit(status: cint) {.importc: "_exit", header: "<unistd.h>", noreturn.}

proc closeStdout*() =
  try:
    stdout.flushFile()
    stdout.close()
  except IOError:
    stderr.writeLine "write error: ", osErrorMsg(osLastError())
    c_exit(QuitFailure)

const
  authors* = ["Chenyu Lue"]
  version* = "0.1.0"

template runWithIOErrorHandling*(body: untyped) =
  try:
    body
  except IOError as e:
    try:
      stderr.writeline "write error: ", e.msg
    except:
      discard
    quit(QuitFailure)

template createVersionInfo*(
    authors: openArray[string], version: string, programName: string
): string =
  let authorStr = authors.join(", ")
  let appName = programName.split('.')[0]

  """
$1 (GNU coreutils in Nim) $2
Copyright ©︎ 2025 $3.
License MIT: The MIT License <https://mit-license.org/>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Written by $3.""".format(
    appName, version, authorStr
  )

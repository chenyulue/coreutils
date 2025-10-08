import std/os

const
  HelpOptionDescription* = "      --help     display this help and exit"
  VersionOptionDescription* = "      --version  output version information and exit"
  UsageBuiltinWarning* =
    """
NOTE: your shell may have its own version of $1, which usually supersedes
the version described here.  Please refer to your shell's documentation
for details about the options it supports."""
  Author* = "Chenyu Lue"
  Version* = "0.1.0"
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

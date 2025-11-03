import std/[os, strutils]
import therapist
import defs

let
  programName = extractFilename(getAppFilename())
  versionInfo = createVersionInfo(authors, version, programName)
  prolog =
    """
Concatenate FILE(s) to standard output.

With no FILE, or when FILE is -, read standard input."""
  epilog = """
Examples:
  $1 f - g    Output f's contents, then standard input, then g's contents.
  $1          Copy standard input to standard output.""".format(
    programName
  )

let catSpec = (
  showAll: newFlagArg(@["-A", "--show-all"], help = "equivalent to -vET"),
  numNonBlank: newFlagArg(
    @["-b", "--number-nonblank"], help = "number nonempty output lines, overrides -n"
  ),
  ve: newFlagArg(@["-e"], help = "equivalent to -vE"),
  showEnds: newFlagArg(@["-E", "--show-ends"], help = "display $ at end of each line"),
  number: newFlagArg(@["-n", "--number"], help = "number all output  lines"),
  squeezeBlank: newFlagArg(
    @["-s", "--squeeze-blank"], help = "suppress repeated empty output lines"
  ),
  vt: newFlagArg(@["-t"], help = "equivalent to -vT"),
  showTabs: newFlagArg(@["-T", "--show-tabs"], help = "display TAB characters as ^I"),
  ignoreU: newFlagArg(@["-u"], help = "(ignored)"),
  showNonPrint: newFlagArg(
    @["-v", "--show-nonprinting"],
    help = "use ^ and M- notation, except for LFD and TAB",
  ),
  files: newStringArg(
    @["<FILE>"],
    help = "files to be concatenated, wherein - stands for standard input",
    multi = true,
    optional = true,
  ),
  help: newHelpArg(@["--help"], help = "display this help and exit"),
  version: newMessageArg(
    @["--version"], versionInfo, help = "output version information and exit"
  ),
)

let (success, msg) = parseOrMessage(catSpec, prolog, epilog)

if not success:
  echo msg.get
  quit(QuitFailure)
else:
  echo msg.get
  quit(QuitSuccess)

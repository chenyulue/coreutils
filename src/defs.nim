import std/[strutils, enumerate]

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

proc toAuthorStr(authors: openArray[string]): string =
  var authorSeq = newSeq[string](authors.len)
  for index, author in enumerate(authors):
    if index < authors.len - 2:
      authorSeq[index] = author & ", "
    elif index < authors.len - 1:
      authorSeq[index] = author & " and "
    else:
      authorSeq[index] = author
  result = authorSeq.join()

proc createVersionInfo*(
    authors: openArray[string], version: string, programName: string
): string {.inline.} =
  let authorStr = authors.toAuthorStr()
  let appName = programName.split('.')[0]

  result = """
$1 (GNU coreutils in Nim) $2
Copyright ©︎ 2025 Chenyu Lue.
License MIT: The MIT License <https://mit-license.org/>.

Written by $3.""".format(
    appName, version, authorStr
  )

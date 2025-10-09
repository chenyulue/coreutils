# begin Nimble config (version 2)
when withDir(thisDir(), system.fileExists("nimble.paths")):
  include "nimble.paths"
  switch("d", "Version=0.1.0")
  switch("d", "Author=Chenyu Lue")
# end Nimble config

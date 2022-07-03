# Replace Characters in Filename inside working Directory
Dir | Rename-Item –NewName { $_.name –replace " ","_" }
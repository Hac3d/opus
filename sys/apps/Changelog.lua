function readAll(file)
	local f = io.open(file, "rb")
	local content = f:read("*all")
	f:close()
	return content
end

shell.run("wget https://raw.githubusercontent.com/Hac3d/opus/develop-1.8/changelog changelog.txt")
shell.run("clear")
  
print(readAll("changelog.txt"))
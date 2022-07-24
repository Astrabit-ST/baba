require "mkmf"
include MakeMakefile["C++"]
require "rubygems"

$LDFLAGS.sub!(/\-s/, "") # Strip -s for the linker
$DLDFLAGS.sub!(/\-s/, "") # Strip -s for the linker
$CFLAGS.sub!(/-O\d/, "") # Strip -O3 for the compiler
$CXXFLAGS.sub!(/-O\d/, "") # Strip -O3 for the compiler
$CFLAGS += " -g"
$CXXFLAGS += " -g"

usr_dir = if Gem.win_platform? #* Treat windows like a special needs child
    `cygpath -w /usr`.gsub(/\n/, "").gsub(/\\/, "/") #? Strip newline and swap backslashes for forward slashes
  else
    "/usr"
  end

dir_config("flex", usr_dir)
unless flex_exe = find_executable("flex")
  if Gem.win_platform?
    puts "flex not found, attempting to install..."
    system("pacman -S flex --noconfirm")
    abort "Failed to install flex" unless flex_exe = find_executable("flex")
  else
    raise "flex not found, please install flex" # flex is standard on linux
  end
end
find_header("FlexLexer.h")
find_library("fl", nil)

unless bison_exe = find_executable("bison")
  abort "bison not found, please install bison" # bison is standard with msys2 and most linux distros
end

prev_dir = Dir.pwd
Dir.chdir(__dir__)
puts "Generating lexer"
`flex lexer.l`
puts "Generating parser"
`bison -d parser.y`
Dir.chdir(prev_dir)

create_header
create_makefile "baba_vm"

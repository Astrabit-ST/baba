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
  abort "flex not found"
end
find_header("FlexLexer.h")
find_library("fl", nil)

puts "Generating lexer.cpp"
File.open(File.join(__dir__, "lexer.cpp"), "w") do |f|
  f.write `#{flex_exe} -t #{__dir__}/lexer.l`
end

create_header
create_makefile "baba_vm"

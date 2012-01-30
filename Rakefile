require 'rubygems'
require 'hoe'
require 'erb'
require 'rake/extensiontask'
require './lib/fox16/version.rb'
load 'Rakefile.cross'

# Some constants we'll need
PKG_VERSION = Fox.fxrubyversion
FXSCINTILLA_INSTALL_DIR = Pathname( "build/builds/fxscintilla-#{LIBFXSCINTILLA_VERSION}" ).expand_path

hoe = Hoe.spec "fxruby" do
  # ... project specific data ...
  self.blog_categories = %w{FXRuby}
  self.clean_globs = [".config", "ext/fox16/Makefile", "ext/fox16/*.o", "ext/fox16/*.bundle", "ext/fox16/mkmf.log", "ext/fox16/conftest.dSYM", "ext/fox16/include/swigrubyrun.h"]
  developer("Lyle Johnson", "lyle@lylejohnson.name")
  self.extra_rdoc_files = ["rdoc-sources", File.join("rdoc-sources", "README.rdoc")]
  self.remote_rdoc_dir = "doc/api"
  self.spec_extras = {
    :description => "FXRuby is the Ruby binding to the FOX GUI toolkit.",
    :extensions => ["ext/fox16/extconf.rb"],
    :rdoc_options => ['--main', File.join('rdoc-sources', 'README.rdoc'), '--exclude', 'ext/fox16', '--exclude', %r{aliases|kwargs|missingdep|responder}.inspect],
    :require_paths => ['ext/fox16', 'lib'],
    :summary => "FXRuby is the Ruby binding to the FOX GUI toolkit."
  }
  self.test_globs = ["test/**/TC_*.rb"]
  self.version = PKG_VERSION

  # use interim gem name 'fxrubi'
  self.spec_extras[:name] = 'fxrubi'
end

# Make sure extension is built before tests are run
task :test => [:compile]

# The "docs" task created by Hoe assumes that we want to run RDoc
# over everything under the "lib" and "ext" subdirectories.
# We need to go back and tell it to skip the stuff under ext.
# rdoc_target = Rake::Task['docs'].prerequisites.first
# rdoc_files = Rake::Task[rdoc_target].prerequisites
# rdoc_files.reject! {|x| x == "ext/fox16" }

# Make sure that all of the package contents exist before we try to build the package
#Rake::Task['package'].prerequisites.unshift("swig:swig", "fxruby:setversions", "fxruby:generate_kwargs_lib")

# ... project specific tasks ...

Rake::ExtensionTask.new("fox16", hoe.spec) do |ext|
  ext.cross_compile = true
  ext.cross_platform = ['i386-mingw32']
  ext.cross_config_options += [
    "--with-fxscintilla-include=#{STATIC_INSTALLDIR}/include/fxscintilla",
    "--with-installed-dir=#{STATIC_INSTALLDIR}",
    "--enable-win32-static-build",
    "--with-fxscintilla",
  ]
end

# Make the compile task's list of dependencies begin with the :configure task
Rake::Task['compile'].prerequisites.unshift("fxruby:configure")

# Set environment variable SWIG_LIB to
# c:/ruby-1.8.6-p383-preview2/devkit/msys/1.0.11/usr/local/share/swig/1.3.22
# before running swig on MinGW.
namespace :swig do
  SWIG = (RUBY_PLATFORM =~ /mingw/) ? "swig-1.3.22.exe" : "swig-1.3.22"
  SWIGFLAGS = "-fcompact -noruntime -c++ -ruby -no_default -I../fox-includes"
  SWIG_LIB = `#{SWIG} -swiglib`.chomp
  SWIG_MODULES = {
    "core.i" => "core_wrap.cpp",
    "dcmodule.i" => "dc_wrap.cpp",
    "dialogs.i" => "dialogs_wrap.cpp",
    "framesmodule.i" => "frames_wrap.cpp",
    "iconlistmodule.i" => "iconlist_wrap.cpp",
    "icons.i" => "icons_wrap.cpp",
    "image.i" => "image_wrap.cpp",
    "labelmodule.i" => "label_wrap.cpp",
    "layout.i" => "layout_wrap.cpp",
    "listmodule.i" => "list_wrap.cpp",
    "mdi.i" => "mdi_wrap.cpp",
    "menumodule.i" => "menu_wrap.cpp",
    "fx3d.i" => "fx3d_wrap.cpp",
    "scintilla.i" => "scintilla_wrap.cpp",
    "table-module.i" => "table_wrap.cpp",
    "text-module.i" => "text_wrap.cpp",
    "treelist-module.i" => "treelist_wrap.cpp",
    "ui.i" => "ui_wrap.cpp"
  }

  def wrapper_src_file_path(wrapper_src_file_name)
    File.join("..", "ext", "fox16", wrapper_src_file_name)
  end

  def sed(wrapper_src_file_name)
    results = []
    IO.readlines(wrapper_src_file_name).each do |line|
      line.gsub!(/static VALUE mCore;/, "VALUE mCore;")
      line.gsub!(/mCore = rb_define_module\("Core"\)/, "mFox = rb_define_module(\"Fox\")")
      line.gsub!(/mCore/, "mFox")
      next if line =~ /static VALUE m(Dc|Dialogs|Frames|Iconlist|Icons|Image|Label|Layout|List|Mdi|Menu|Fx3d|Scintilla|Table|Text|Treelist|Ui);/
      next if line =~ /m(Dc|Dialogs|Frames|Iconlist|Icons|Image|Label|Layout|List|Mdi|Menu|Fx3d|Scintilla|Table|Text|Treelist|Ui) = rb_define_module/
      next if line =~ /rb_require/
      line.gsub!(/m(Dc|Dialogs|Frames|Iconlist|Icons|Image|Label|Layout|List|Mdi|Menu|Fx3d|Scintilla|Table|Text|Treelist|Ui),/, "mFox,")
      results << line
    end
    File.open(wrapper_src_file_name, "w") do |io|
      io.write(results.join)
    end
  end

  def swig(swig_interface_file_name, wrapper_src_file_name)
    system "#{SWIG} #{SWIGFLAGS} -o #{wrapper_src_file_path(wrapper_src_file_name)} #{swig_interface_file_name}"
    sed wrapper_src_file_path(wrapper_src_file_name)
  end

  task :swig_librb => ["ext/fox16/librb.c"]
  file "ext/fox16/librb.c" do
    Dir.chdir "swig-interfaces" do
      File.open(wrapper_src_file_path("librb.c"), "w") do |io|
        io.puts "#define SWIG_GLOBAL 1"
        io.write(IO.read(File.join(SWIG_LIB, "ruby", "precommon.swg")))
        io.write(IO.read(File.join(SWIG_LIB, "common.swg")))
        io.write(IO.read(File.join(SWIG_LIB, "ruby", "rubyhead.swg")))
        io.write(IO.read(File.join(SWIG_LIB, "ruby", "rubydef.swg")))
      end
    end
  end

  desc "Run SWIG to generate the wrapper files."
  task :swig => [:swig_librb] + SWIG_MODULES.map{|ifile, cppfile| File.join("ext/fox16", cppfile) }

  # add dependencies for compile *.i to *_wrap.cpp
  SWIG_MODULES.each do |ifile, cppfile|
    ifile_path = File.join("swig-interfaces", ifile)
    cppfile_path = File.join("ext/fox16", cppfile)

    file cppfile_path => [ifile_path] do
      Dir.chdir "swig-interfaces" do
        swig(ifile, cppfile)
      end
    end
  end
end


namespace :fxruby do

  desc "Update the web site."
  task :website => [:doap] do
    system %{scp -Cq examples/*.rb lyle@rubyforge.org:/var/www/gforge-projects/fxruby/1.6/examples}
    system %{scp -Cq web/index.html lyle@rubyforge.org:/var/www/gforge-projects/fxruby}
    system %{scp -Cq web/community.html lyle@rubyforge.org:/var/www/gforge-projects/fxruby}
    system %{scp -Cq web/documentation.html lyle@rubyforge.org:/var/www/gforge-projects/fxruby}
    system %{scp -Cq web/downloads.html lyle@rubyforge.org:/var/www/gforge-projects/fxruby}
    system %{scp -Cq web/images/* lyle@rubyforge.org:/var/www/gforge-projects/fxruby/images}
    system %{scp -Cq web/css/*.css lyle@rubyforge.org:/var/www/gforge-projects/fxruby/css}
  end

  desc "Upload the DOAP file to the Web site"
  task :doap => [:setversions] do
    system %{scp -Cq doap.rdf lyle@rubyforge.org:/var/www/gforge-projects/fxruby}
  end

  def setversions(filename)
    File.open(filename, "wb") do |out|
      template = ERB.new(File.open(filename + ".erb", "rb").read)
      out.write(template.result)
    end
  end

  desc "Set versions"
  task :setversions do
    setversions("doap.rdf")
  end

  def make_impl
    Dir.chdir "ext/fox16" do
      ruby "make_impl.rb"
    end
  end

  task :configure => [:scintilla, :setversions, :generate_kwargs_lib, 'ext/fox16/impl.cpp', 'ext/fox16/include/inlinestubs.h']

  rb_header_files = Dir['ext/include/*.h']
  file 'ext/fox16/include/inlinestubs.h' => rb_header_files do
    make_impl
  end
  file 'ext/fox16/impl.cpp' => rb_header_files do
    make_impl
  end

  file "ext/fox16/extconf.rb" => ["ext/fox16/librb.c"] + SWIG_MODULES.map{|ifile, cppfile| File.join("ext/fox16", cppfile) }

  task :scintilla => 'lib/fox16/scintilla.rb'
  file 'lib/fox16/scintilla.rb' => [FXSCINTILLA_INSTALL_DIR, 'scripts/iface.rb'] do
    ruby "scripts/iface.rb -i #{FXSCINTILLA_INSTALL_DIR}/include/Scintilla.iface -o lib/fox16/scintilla.rb"
  end

  task :generate_kwargs_lib => 'lib/fox16/kwargs.rb'
  file 'lib/fox16/kwargs.rb' => ['scripts/generate_kwargs_lib.rb'] + Dir.glob('rdoc-sources/*.rb') do
    ruby 'scripts/generate_kwargs_lib.rb'
  end
end

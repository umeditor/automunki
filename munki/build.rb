#!/usr/bin/ruby

if (ARGV.count < 1)
  puts "Need path to munki dmg"
  exit -1
end

dmg_path = ARGV[0]

# Mount disk image
mountpoint = `hdiutil attach -mountrandom /tmp -nobrowse "#{dmg_path}"`.lines.find {|l| l.match /Apple_HFS/}.split.last

# Define these so they are available after the Dir block
pkgs = ""
metapkg = ""

# Find metapackage and all underlying packages on the disk image
begin
  Dir.chdir(mountpoint) do
    metapkg = Dir.glob("*.mpkg").first
    pkgs = Dir.glob("*.mpkg/Contents/Packages/*.pkg")
  end
ensure
  system("hdiutil", "detach", mountpoint)
end

munki_version = metapkg.match(/-([[:digit:].]*).mpkg/)[1]

pkgs.each do |pkg|
  pkgname = File.basename(pkg)

  puts "Working on: #{pkgname}"

  # Add the overall Munki version to the plist name
  plist_name = pkgname.gsub(/^.*_/, "munkitools-#{munki_version}_").concat(".plist")
  system("makepkginfo -p \"#{pkg}\" \"#{dmg_path}\" > \"#{plist_name}\"")

  plist_path = File.expand_path(plist_name)

  # Fixups depending on which pkg we're dealing with
  case pkgname
  when /_app/
    system("/usr/bin/defaults", "write", plist_path, "display_name", "Managed Software Update")
    system("/usr/bin/defaults", "write", plist_path, "uninstallable", "-bool", "NO")
    system("/usr/bin/defaults", "write", plist_path, "requires", "-array", "munkitools_core")
    system("/usr/bin/defaults", "write", plist_path, "RestartAction", "RequireLogout")
  when /_admin/
    system("/usr/bin/defaults", "write", plist_path, "display_name", "Munki Admin Tools")
    system("/usr/bin/defaults", "write", plist_path, "uninstallable", "-bool", "NO")
    system("/usr/bin/defaults", "write", plist_path, "requires", "-array", "munkitools_core")
  when /_core/
    system("/usr/bin/defaults", "write", plist_path, "display_name", "Munki Core Components")
    system("/usr/bin/defaults", "write", plist_path, "uninstallable", "-bool", "NO")
    system("/usr/bin/defaults", "write", plist_path, "requires", "-array", "munkitools_launchd")
  when /_launchd/
    system("/usr/bin/defaults", "write", plist_path, "display_name", "Munki Services")
    system("/usr/bin/defaults", "write", plist_path, "uninstallable", "-bool", "NO")
    system("/usr/bin/defaults", "write", plist_path, "RestartAction", "RequireRestart")
  end

  system("/usr/bin/plutil", "-convert", "xml1", plist_path)
end


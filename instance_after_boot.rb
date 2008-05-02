require 'fileutils'

@dirs = ["/mnt/var/log", 
  "/mnt/var/log/mysql",
  "/mnt/var/log/news",
  "/mnt/var/log/nginx",
  "/mnt/var/log/sandbox",
  "/mnt/gentoo/distfiles",
  "/mnt/gentoo/log",
  "/mnt/gentoo/portage",
  "/mnt/gentoo/tmp",
  "/mnt/var/tmp",
  "/mnt/tmp"
]


@dirs.each do |dir|
  begin
    FileUtils.mkdir_p dir
    puts "Good, directory '#{dir}' created."
  rescue
    puts "There was an error."
    puts "Directory '#{dir}' not created."
  end
end

FileUtils.rm("/var/log", :force => true)
FileUtils.rm("/var/tmp", :force => true)

FileUtils.ln_s("/mnt/var/log", "/var/log", :force => true)
FileUtils.ln_s("/mnt/var/tmp", "/var/tmp", :force => true)

FileUtils.chown 'mysql', 'mysql', '/mnt/var/log/mysql'
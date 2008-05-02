require 'fileutils'

@dirs = ["/mnt/gentoo/distfiles",
  "/mnt/gentoo/log",
  "/mnt/gentoo/portage",
  "/mnt/gentoo/tmp",
  "/mnt/app"
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


FileUtils.ln_s("/mnt/apps", "/var/www/apps", :force => true)
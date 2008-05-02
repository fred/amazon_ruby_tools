#######################################
#### WRITEN by Frederico de Souza #####
#### fred.the.master@gmail.com    #####
#### Free to use as in free beer  #####
#######################################

# This program will upload a Gentoo portage to S3


require 'rubygems'
require 'aws/s3'
require 'fastthread'
require 'pathname'
require 'ftools'


#########################
##   SCRIPT SETTINGS   ##
#########################

@unattended_mode = true
@access_key_id = ENV['AMAZON_ACCESS_KEY_ID']
@secret_access_key = ENV['AMAZON_SECRET_ACCESS_KEY']

@time = Time.now
@bucket_name = "gentoo_portage"
## FOLDERS Information ##
# Local Folder to dump the SQL data
@filename = "#{@time.year}.#{@time.month}.#{@time.day}__#{@time.hour}.#{@time.min}.#{@time.sec}"
@data_dir = "/mnt/backup/gentoo_portage/"

# Username / Password to access DB
# it's good to create a user with READ only access to all databases.
# for example: GRANT SELECT ON *.* TO 'fred'@'localhost' IDENTIFIED by 'fred'
if ENV['DB_USERNAME']
  @db_username = ENV['DB_USERNAME']
else
  @db_username = "root"
end
if ENV['DB_PASSWORD']
  @db_password = ENV['DB_PASSWORD']
else
  @db_password = ""
end

@lines = "\n----------------------------------------------------------"

if @unattended_mode == false
  puts "Welcome!"
  puts "--------"
  puts "Program Variables:"
  puts "------------------" 
  puts "- Server Username:    #{@server_username}"
  puts "- Bucket:             #{@bucket_name}"
  puts "- Local Dump Dir:     #{@data_dir}"
  puts "- Local Time of Dump: #{@time}"
  puts "- Unattended mode:    #{@unattended_mode}"
  puts @lines
  puts "Is this Information correct?"
end
  
def check_answer
  if @unattended_mode == false
    puts "Press Y to Continue or N no Cancel."
    yes_no = gets
    yes_no.chomp!
    case yes_no
      when "Y","y","Yes","yes"
        puts "Continuing"
      when "N", "n", "No", "no"
        puts "You chose to CANCEL, bye bye."
        exit
      when 'q', 'quit'
        puts "You chose to QUIT, bye bye."
        exit
      else
        puts "Invalid Answer."
        check_answer
    end
  else
    return true
  end
end

def check_settings
  if !ENV['AMAZON_ACCESS_KEY_ID']
    puts "FATAL: AMAZON_ACCESS_KEY_ID not set, quiting now."
    exit
  end
  if !ENV['AMAZON_SECRET_ACCESS_KEY']
    puts "FATAL: AMAZON_SECRET_ACCESS_KEY not set, quiting now."
    exit
  end  
end


# Function to make the Database Dumps
def tar_portage
  puts "starting to copy portage"
    Thread.new do
      IO.popen(" cd /mnt/gentoo/ && rm -rf /mnt/portage.tar.gz && tar -czpf /mnt/portage.tar.gz portage")
    end
    sleep 40
end

# Function to stablish connection
def stablish_connection
  begin
    AWS::S3::Base.establish_connection!(
      :access_key_id     => @access_key_id,
      :secret_access_key => @secret_access_key
    )
  rescue => exception
    puts @lines
    puts "There was an error: "
    puts exception.to_s
    exit
  end
  puts "Good, Connection Stablished."
  return "ok"
end


# Function to find or create a bucket
def find_or_create_bucket
  begin
    AWS::S3::Bucket.find(@bucket_name)
  rescue
    puts "Bucket #{@bucket_name} not found."
    puts 'Creating the bucket now.'
    AWS::S3::Bucket.create(@bucket_name)
    retry
  end
  puts "Good, bucket #{@bucket_name} found."
end


# Function to send data to bucket
def send_data
  AWS::S3::S3Object.store("portage.tar.gz", "/mnt/portage.tar.gz"), @bucket_name)
  @data_transferred = File.size("/mnt/portage.tar.gz")
  puts "Data Transfered: #{to_file_size(@data_transferred)}"
  puts "done!"
end

def to_file_size(num)
  case num
  when 0 
    return "0 byte"
  when 1..1024
    return "1K"
  when 1025..1048576
    kb = num/1024
    return "#{kb} Kb"
  when 1024577..1049165824
    kb = num/1024
    mb = kb / 1024
    return "#{mb} Mb"
  else
    kb = num/1024
    mb = kb / 1024
    gb = mb / 1024
    return "#{gb} Gb"
  end
end


#############
##  START  ##
#############

## Execution Start here ##
def main_program  
  check_answer

  # Check if destination directory at local exists
  begin
    puts "INFO: Creating Directory '#{@data_dir}' with mode 700"
    FileUtils.mkdir_p @data_dir, :mode => 0700 
  rescue
    puts "WARNING: directory '#{@data_dir}' could not be created, check your permissions."
    puts "Going to use '/tmp' folder instead."
    @data_dir = "/tmp/#{@data_dir}"
  end
  
  # make the actual dump
  puts @lines
  puts "Starting tar of portage"
  check_answer
  tar_portage
  
  puts @lines
  puts "Stablishing Connection to S3 account."
  stablish_connection
  
  find_or_create_bucket
  
  puts @lines
  puts "Now Going to copy Data to S3 bucket #{@bucket_name}."
  send_data
end

main_program

puts @lines
puts "#{@time} -- DONE"
puts @lines
puts @lines
puts @lines


# END of program #


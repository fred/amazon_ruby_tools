#######################################
#### WRITEN by Frederico de Souza #####
#### fred.the.master@gmail.com    #####
#### Free to use as in free beer  #####
#######################################

# This program will Upload a Gentoo portage from S3
# gentoo portage must be in /mnt/gentoo/portage

require 'aws/s3'

@time = Time.now
@date_format = "#{@time.year}.#{@time.month}.#{@time.day}"
@portage_name = "#{@date_format}_portage.tar.gz"
@local_portage = "/mnt/portage.tar.gz"

@access_key_id = ENV['AMAZON_ACCESS_KEY_ID']
@secret_access_key = ENV['AMAZON_SECRET_ACCESS_KEY']
@bucket_name = ENV['AMAZON_BUCKET_NAME']

def download_portage
  AWS::S3::Base.establish_connection!( :access_key_id => @access_key_id, :secret_access_key => @secret_access_key)
  bucket =  AWS::S3::Bucket.find(@bucket_name)
  puts "Removing old portage"
  FileUtils.rm(@local_portage, :force => true)
  puts "Downloading new portage"
  open(@local_portage, 'w') do |file|
    AWS::S3::S3Object.stream(@portage_name, @bucket_name) do |chunk|
      file.write chunk
    end
  end
end

def untar_portage
  FileUtils.rm("/mnt/gentoo/portage", :force => true)
  puts "Starting to untar file to local portage. Wait 2 minutes"
  puts "cd /mnt/gentoo/ && tar -xzpf #{@local_portage}"
  IO.popen("cd /mnt/gentoo/ && rm -rf portage && tar -xzpf #{@local_portage}")
end

def update_portage
  puts "Updating portage via EIX"
  IO.popen("eix-sync")
end

download_portage
untar_portage
update_portage

#######################################
#### WRITEN by Frederico de Souza #####
#### fred.the.master@gmail.com    #####
#### Free to use as in free beer  #####
#######################################

# This program will Download a Gentoo portage from S3
# and put it in /mnt/gentoo

require 'aws/s3'

@time = Time.now
@date_format = "#{@time.year}.#{@time.month}.#{@time.day}"
@lines = "\n----------------------------------------------------------"
@portage_name = "#{@date_format}_portage.tar.gz"

@local_portage = "/mnt/portage.tar.gz"

@access_key_id = ENV['AMAZON_ACCESS_KEY_ID']
@secret_access_key = ENV['AMAZON_SECRET_ACCESS_KEY']
@bucket_name = ENV['AMAZON_BUCKET_NAME']

def update_portage
  puts "Updating portage via EIX"
  puts "Wait 2 minutes"
  IO.popen("eix-sync")
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
end


# Function to find or create a bucket
def find_or_create_bucket
  begin
    AWS::S3::Bucket.find(@bucket_name)
  rescue
    puts "Bucket #{@bucket_name} not found."
    puts 'Creating the bucket now.'
    AWS::S3::Bucket.create(@bucket_name)
    puts "Good, bucket #{@bucket_name} created."
  end
  puts "Good, bucket #{@bucket_name} found."
end

def tar_portage
  puts "Starting to make tar file of local portage. Wait 2 minutes"
  puts "cd /mnt/gentoo/ && rm -rf #{@local_portage} && tar -czpf #{@local_portage} portage"
  IO.popen("cd /mnt/gentoo/ && rm -rf #{@local_portage} && tar -czpf #{@local_portage} portage")
  sleep 120
end


# Function to send data to bucket
def send_data
  # Store it
  puts "Starting data Transfer"
  AWS::S3::S3Object.store(@portage_name, open(@local_portage), @bucket_name)
  @data_transferred = File.size(@local_portage)
  puts "Data Transfered: #{to_file_size(@data_transferred)}"
  puts "done!"
end

# to print it nicely the data send
def to_file_size(num)
  case num
  when 0 
    return "0 byte"
  when 1..1024
    return "1K"
  when 1025..1048576
    kb = num/1024.0
    return "#{f_to_dec(kb)} Kb"
  when 1024577..1049165824
    kb = num/1024.0
    mb = kb / 1024.0
    return "#{f_to_dec(mb)} Mb"
  else
    kb = num/1024.0
    mb = kb / 1024.0
    gb = mb / 1024.0
    return "#{f_to_dec(gb)} Gb"
  end
end

def f_to_dec(f, prec=2,sep='.')
  num = f.to_i.to_s
  dig = ((prec-(post=((f*(10**prec)).to_i%(10**prec)).to_s).size).times do post='0'+post end; post)
  return num+sep+dig
end

update_portage
stablish_connection
find_or_create_bucket
tar_portage
send_data

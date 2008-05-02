require 'rubygems'
require 'aws/s3'


@access_key_id = ENV['AMAZON_ACCESS_KEY_ID']
@secret_access_key = ENV['AMAZON_SECRET_ACCESS_KEY']

if ARGV[0]
  @bucket_name = ARGV[0]
else
  puts "You must specify bucket_name."
  puts "Usage: $ruby create_bucket.rb bucket_name"
  exit
end

@lines = "\n----------------------------------------------------------"

def check_settings
  unless ENV['AMAZON_ACCESS_KEY_ID']
    puts "FATAL: AMAZON_ACCESS_KEY_ID not set, quiting now."
    puts "you should set AMAZON_ACCESS_KEY_ID ($export AMAZON_ACCESS_KEY_ID=....)"
    exit
  end
  unless ENV['AMAZON_SECRET_ACCESS_KEY']
    puts "FATAL: AMAZON_SECRET_ACCESS_KEY not set, quiting now."
    puts "you should set AMAZON_SECRET_ACCESS_KEY ($export AMAZON_SECRET_ACCESS_KEY=....)"
    exit
  end  
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
  sleep 1
  if AWS::S3::Bucket.find(@bucket_name)
    puts "Bucket #{@bucket_name} found."
  else
    puts "The bucket #{@bucket_name} could not be found"
  end
end

check_settings

stablish_connection

find_or_create_bucket

require 'rubygems'
require 'aws/s3'


@access_key_id = ENV['AMAZON_ACCESS_KEY_ID']
@secret_access_key = ENV['AMAZON_SECRET_ACCESS_KEY']


@lines = "----------------------------------------------------------"

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

def list_buckets
  puts "Current buckets:"
  buckets = AWS::S3::Bucket.list
  buckets.each do |t|
    puts @lines
    puts "Name: #{t.name}"
    puts "Date: #{t.creation_date}"
    puts @lines
    puts "\n"
  end
end

# Function to find or create a bucket
def find_bucket(bucket_name)
  if bucket = AWS::S3::Bucket.find(bucket_name)
    puts "Bucket #{bucket_name} found."
    bucket
  else
    puts "The bucket #{bucket_name} could not be found"
    nil
  end
end


# Function to find or create a bucket
def create_bucket(bucket_name)
  return if find_bucket(bucket_name)

  begin
    puts 'Creating the bucket now.'
    AWS::S3::Bucket.create(bucket_name)
  rescue 
    puts "The bucket #{bucket_name} could not be created"
    return
  end
  
  sleep 1
  if find_bucket(bucket_name)
    puts "Good, bucket #{bucket_name} created."
  end
end


check_settings
stablish_connection
list_buckets


require 'rubygems'
require 'aws/s3'


@access_key_id = ENV['AMAZON_ACCESS_KEY_ID']
@secret_access_key = ENV['AMAZON_SECRET_ACCESS_KEY']


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

def list_buckets
  puts "All buckets"
  buckets = AWS::S3::Bucket.list
  buckets.each do |t|
    puts "Name: #{t.name}"
    puts "Date: #{t.creation_date}"
    puts "-----------------------"
  end
end


check_settings

stablish_connection
list_buckets


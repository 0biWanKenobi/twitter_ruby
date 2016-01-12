require 'twitter'

::Twitter_client = Twitter::REST::Client.new do |config|
  #app auth allows for more requests every 15 minutes, possibly remove user key and secret
  config.consumer_key        = "bw6Ibw6DvDWZYTZJDgsIn12II"
  config.consumer_secret     = "lShJQA17tg93RVUCNhHRqAuHOOfSPvYqAJHihKbxT753GukKuJ"
  #config.access_token        = "4644992487-ZGV2FSbwYDCBgVyjMoAaoR3rXlUdnAwaCl9SYVE"
  #config.access_token_secret = "zbU5FfiibtontJiykO3ZInO4yzUDscByi9HjkOAGKy64G"
end
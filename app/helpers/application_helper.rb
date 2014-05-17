module ApplicationHelper
  def last_answered_tweet=(tweet_id)
    @last_answered_tweet = tweet_id
  end
  
  def last_answered_tweet
    @last_answered_tweet
  end
end

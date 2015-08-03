class ScrapeYelpRecord
  include Sidekiq::Worker
  sidekiq_options retry: 3, :backtrace => true

  def perform(id)
    user_record = UserRecord.find(id)
    puts "Process for #{id}================="
    user_record.extract_yelp_record
  end
end

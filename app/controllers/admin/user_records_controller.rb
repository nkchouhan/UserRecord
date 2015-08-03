class Admin::UserRecordsController < ApplicationController
  before_action :authenticate_user!
  
  def home
    @user_record = UserRecord.new
    @in_progress = UserRecord.where(status: false).pluck(:process_id).uniq
    @all_process = UserRecord.pluck(:process_id).uniq
  end

  def upload
    file = params["user_record"]["files"]
    @result = UserRecord.extract_data(file)
    @result[:urls].select!{|a| a.include? 'yelp.com'}
    process_id = (UserRecord.last.present? ? (UserRecord.last.process_id.to_i + 1) : 1000)

    @result[:urls].each do |url|
      user_record = UserRecord.create(url: url, process_id: process_id)
      ScrapeYelpRecord.perform_at(5.seconds.from_now, user_record.id)
    end
  end

  def download
    if params["download"].include? "all"
      @user_record = UserRecord.all.active
    else
      @user_record = UserRecord.where('process_id in (?) and status = ?', params['download'], true)
    end
    response.headers['Content-Type'] = 'text/csv'
    response.headers['Content-Disposition'] = 'attachment; filename=user_record.csv'
    response.headers['CSV-Delimiter'] = '|'
    render layout: false
  end

end

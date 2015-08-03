class UserRecord < ActiveRecord::Base
  mount_uploader :avatar, AvatarUploader

  scope :active, -> { where(status: true) }

  def self.extract_data(file)
    extension = File.extname(file.original_filename)
    errors = []
    urls = []
    if ['.csv'].include? extension
      spreadsheet = Roo::Spreadsheet.open(file.path, extension: extension)
      (1..spreadsheet.last_row).each do |i|
        row = spreadsheet.row(i)
        next if row.blank?
        urls << row.first
      end
    else
      errors << "Invalid file format, accepted format is csv"
    end
    { errors: errors.flatten, urls: urls.flatten }
  end

  def extract_yelp_record
    puts "inside extract_yelp_record====for id #{self.id}==========="
    @user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_0) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/15.0.854.0 Safari/535.2"
    @html = Nokogiri::HTML(open(url, 'User-Agent' => @user_agent))

    review_count = profile_review_count
    @is_owner_reply = is_owner_reply?
    puts "=========@is_owner_reply :: #{@is_owner_reply}======#{!@is_owner_reply and (review_count >= 40)}==="
    if !@is_owner_reply and (review_count >= 40)
      review_count -= 40
      count ||= 1
      loop do
        url = url.split("?").first + "?start=#{40*count}"
        puts "======================================"
        puts "page num #{count}"
        puts "paginate url #{url}"
        puts "======================================"
        @html = Nokogiri::HTML(open(url, 'User-Agent' => @user_agent))
        @is_owner_reply = is_owner_reply? unless @is_owner_reply
        review_count -= 40
        count += 1
        break if (review_count <= 0 or @is_owner_reply)
      end
    end

    if @is_owner_reply
      info = extract_owner_information
      puts "Inside if loop #{info} and business_name #{info[:business_name]}"
      self.business_name = info[:business_name]
      self.phone_number = info[:phone_number]
      self.status = true
      self.save
    else
      self.destroy
    end
  end

  def profile_review_count
    @html.xpath("//div[contains(@class, 'rating-info')]/div[contains(@class, 'biz-rating')]/span[contains(@class, 'review-count')]/span").text.to_i
  end

  def is_owner_reply?
    @html.css('.media-block.biz-owner-reply-header').present?
  end

  def extract_owner_information
    business_name = @html.css('.biz-page-header .biz-page-title').text.strip!
    phone_num = @html.css('.biz-phone').text.strip!
    {business_name: business_name, phone_number: phone_num}
  end

end

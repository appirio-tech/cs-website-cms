xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Challenges"
    xml.description ""
    xml.link challenges_url(filters: params[:filters])

    @challenges.each do |challenge|
      xml.item do
        xml.title challenge.name
        xml.description challenge.description.html_safe
        xml.prize number_to_currency(challenge.total_prize_money, :precision => 0)
        xml.pubDate challenge.start_date.to_s(:rfc822)
        xml.link challenge_url(challenge)
        xml.guid challenge_url(challenge)
      end
    end
  end
end

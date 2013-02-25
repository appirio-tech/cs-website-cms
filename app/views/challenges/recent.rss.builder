xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Recently Completed Challenges"
    xml.description "List of recently completed CloudSpokes challenges."
    xml.link challenges_recent_url

    @challenges.each do |challenge|
      xml.item do
        xml.title challenge.name
        xml.description challenge.description.html_safe
        xml.pubDate challenge.end_date.to_s(:rfc822)
        xml.link challenge_url(challenge)
        xml.guid challenge_url(challenge)
      end
    end
  end
end

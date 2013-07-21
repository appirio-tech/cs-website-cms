require 'zip/zip'

class SubmissionZipper
  
  @queue = :submission_zipper
  def self.perform(challenge_id, email)
    zipper = self.new(challenge_id, email)
    zipper.zip_submissions
    zipper.notify_to_requestor
  end

  def self.clear(challenge_ids)
    Array(challenge_ids).each do |cid|
      puts "Removing zipfile for Challenge #{cid}..."
      zipper = new(cid)
      zipper.remove_zipfile
    end
  end


  def initialize(challenge_id, email = nil)
    @challenge_id = challenge_id
    @requestor_email = email
  end

  def zip_submissions
    return if zipfile_created_before?

    create_zipfile 
    upload_zipfile

  rescue Exception => e
    puts "Failed to do zipping submissions : Reason = #{e}"
  ensure
    cleanup
  end

  def notify_to_requestor
    return if @requestor_email.nil?

    puts "Sending Email to #{@requestor_email} with #{s3_zipfile.public_url}...."
    SubmissionZipperMailer.notify(@requestor_email, @challenge_id, s3_zipfile.public_url).deliver
  end

  def remove_zipfile
    s3_zipfile.try(:destroy)
  end

  private

  def cleanup
    FileUtils.rm_rf @tmpdir if @tmpdir
  end


  def create_zipfile
    @tmpdir = Dir.mktmpdir
    @zip_path = File.join(@tmpdir, "#{@challenge_id}.zip")
    puts "Creating Zipfile for Challenge #{@challenge_id}" 

    Zip::ZipOutputStream.open(@zip_path) do |zos|
      challenge.participants.each do |participant| 
        participant.current_submissions(@challenge_id).each do |submission|
          if %w(Code File Video).include?(submission.type)
            filename = File.basename(submission.url)
            path = File.join("cs#{@challenge_id}", participant.member.name, filename)
            resp = HTTParty.get(submission.url)
            zos.put_next_entry(path)
            zos.write resp.body
          end
        end
      end
    end        
  end

  def upload_zipfile
    puts "Uploading Zipfile to S3..." 
    File.open(@zip_path, "rb") do |file|
      @s3_zipfile = storage.files.create(
        :key    => s3_zipfile_key,
        :body   => file.read,
        :public => true
      )
      puts " => Success : zipfile url = #{s3_zipfile.public_url}"
    end
  end


  def storage
    @storage ||= begin
      fog = Fog::Storage.new(
        :provider                 => 'AWS',
        :aws_secret_access_key    => ENV['AWS_SECRET'],
        :aws_access_key_id        => ENV['AWS_KEY']
      )
      fog.directories.get(ENV['AWS_BUCKET'])
    end
  end  

  def s3_zipfile_key
    @s3_zipfile_key ||= "challenges/#{@challenge_id}/cs#{@challenge_id}.zip"
  end

  def s3_zipfile
    @s3_zipfile ||= storage.files.get(s3_zipfile_key)
  end

  def zipfile_created_before?
    s3_zipfile.present?
  end

  def challenge
    @challenge ||= Challenge.find(@challenge_id)
  end
end
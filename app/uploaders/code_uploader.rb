# encoding: utf-8

class CodeUploader < CarrierWave::Uploader::Base
  include CarrierWaveDirect::Uploader

  def set_dir_vars(challenge_id, membername)
  	@challenge_id = challenge_id
  	@membername = membername
  end

  def store_dir
    "challenges/#{@challenge_id}/#{@membername}"
  end

end

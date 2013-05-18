class CodeUpload < ActiveRecord::Base
  mount_uploader :code, CodeUploader
end

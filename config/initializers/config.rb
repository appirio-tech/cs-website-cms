begin
  APP_CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]
rescue Errno::ENOENT => e
  puts 'IMPORTANT!! config/config.yml not found, you should copy config/config.example.yml to config/config.yml or else the api endpoints will not be properly setup.'
end

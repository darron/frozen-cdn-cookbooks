current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "darron"
client_key               "#{current_dir}/darron.pem"
validation_client_name   "frozencdn-validator"
validation_key           "#{current_dir}/frozencdn-validator.pem"
chef_server_url          "https://api.opscode.com/organizations/frozencdn"
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path            ["#{current_dir}/../cookbooks"]

# Rackspace:
knife[:rackspace_api_key]      = ""
knife[:rackspace_api_username] = ""

# EC2:
# http://uec-images.ubuntu.com/lucid/current/
knife[:aws_access_key_id]     = "NOPE-NOT-PUTTING-IT-HERE"
knife[:aws_secret_access_key] = "NOPE-NOT-PUTTING-IT-HERE-EITHER"

cookbook_copyright "Darron Froese"
cookbook_license   "apachev2"
cookbook_email     "darron@froese.org"
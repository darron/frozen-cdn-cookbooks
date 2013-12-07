maintainer        "nonfiction studios inc."
maintainer_email  "darron@nonfiction.ca"
license           "Apache 2.0"
description       "Installs UFW and Configures Basic Setup"
version           "0.7"

%w{ubuntu debian}.each do |os|
  supports os
end

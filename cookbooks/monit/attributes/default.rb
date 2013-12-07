default[:monit][:notify_email]          = "darron@froese.org"

default[:monit][:poll_period]           = 60
default[:monit][:poll_start_delay]      = 30

default[:monit][:mail_format][:subject] = "$SERVICE $EVENT"
default[:monit][:mail_format][:from]    = "monit@" + node.name
default[:monit][:mail_format][:message]    = <<-EOS
Monit $ACTION $SERVICE at $DATE on $HOST: $DESCRIPTION.
Yours sincerely,
monit
EOS


Paperclip::Attachment.default_options[:url] = nil
Paperclip::Attachment.default_options[:path] = '/:class/:attachment/:id_partition/:style/:filename'

Paperclip::Attachment.default_options[:s3_host_name] = 's3-us-east-2.amazonaws.com'
Paperclip::Attachment.default_options[:s3_protocol] = 'https'

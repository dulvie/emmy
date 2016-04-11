# Allow ".SE" as an extension for files with the MIME type "text/plain".
Paperclip.options[:content_type_mappings] = {
    se: 'text/plain',
    SE: 'text/plain'
}
# Do not trust the browser, it will send .se -files with content_type=application/octet-stream :(
Paperclip::UploadedFileAdapter.content_type_detector = Paperclip::ContentTypeDetector

puts "paper clip options: #{Paperclip.options[:content_type_mappings].inspect}"

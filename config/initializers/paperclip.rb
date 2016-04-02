# Allow ".SE" as an extension for files with the MIME type "text/plain".
Paperclip.options[:content_type_mappings] = {
    SE: 'text/plain'
}

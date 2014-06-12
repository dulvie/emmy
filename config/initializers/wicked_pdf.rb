# PDF mimetype is already specified in action_dispatch
# Mime::Type.register "application/pdf", :pdf
WickedPdf.config = {
  wkhtmltopdf: Rails.root.join('bin', 'wkhtmltopdf-local').to_s,
  exe_path: "bundle exec #{Rails.root.join('bin', 'wkhtmltopdf-local')}",
}

Mime::Type.register "application/pdf", :pdf
if Rails.env.test? or Rails.env.development?
  WickedPdf.config = {
    wkhtmltopdf: Rails.root.join('bin', 'wkhtmltopdf-local').to_s,
    exe_path: "bundle exec #{Rails.root.join('bin', 'wkhtmltopdf-local')}",
  }
else
  raise RuntimeException, "production need special care for wkhtmltopdf"
end

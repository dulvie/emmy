def user_valid_form_data
  puts page.body
  fill_in "user_email", with: "test@example.com"
  fill_in "user_password", with: "abc123"
  fill_in "user_password_confirmation", with: "abc123"
end

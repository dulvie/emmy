namespace :user do
  desc "set new password for user"
  task new_password: :environment do |args|
    puts "set a new password based on user email"

    print "user email: "
    email = STDIN.gets.chomp
    puts ""
    puts "will User.find_by_email(#{email})"
    user = User.find_by_email email
    abort "No user with that email found" unless user

    puts ""
    print "type in a new password: "
    pass = STDIN.gets.chomp
    puts ""
    puts "will set new password: #{pass}"
    user.password = pass
    user.save!
  end
end

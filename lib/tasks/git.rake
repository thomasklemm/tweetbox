namespace :git do
  desc 'Remove assets that have been deleted from Git.'
  task :rm do
    puts 'Adding files...'
    system "git add ."

    puts 'Removing deleted files...'
    system "for i in `git status | grep deleted | awk '{print $3}'`; do git rm $i; done"

    system "git status"
    puts 'Deleted files have been removed.'
  end
end

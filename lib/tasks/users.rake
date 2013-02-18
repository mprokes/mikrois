namespace :users do
  task :email => :environment do
    Notifier.welcome(User.find_all_by_email('michal@kropes.cz')).deliver
  end
end

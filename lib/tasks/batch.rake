namespace :batch do
  task :watchdog => :environment do
    Auditor::User.current_user = User.find_by_email('anonymous@mikrois.cz')

    AresRegistration.where('downloaded_at < ?', DateTime.current.advance(:hours => -24)).each do |ares|
      puts "Nalezen stary ARES zaznam pro "+ares.ic.to_s+" "+ares.name
      ares.updateFromNet
      ares.save
    end

    AdisRegistration.where('downloaded_at < ?', DateTime.current.advance(:hours => -24)).each do |adis|
      puts "Nalezen stary ADIS zaznam pro "+adis.dic.to_s
      adis.updateFromNet
      adis.save
    end

  end
end

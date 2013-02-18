namespace :batch do
  task :watchdog => :environment do
    AresRegistration.where('downloaded_at < ?', DateTime.current.advance(:hours => +1)).each do |ares|
      puts "nalezen stary ares zaznam pro "+ares.ic.to_s+" "+ares.name
      ares.updateFromNet
      ares.save
    end

    AdisRegistration.where('downloaded_at < ?', DateTime.current.advance(:hours => -24)).each do |adis|
      puts "nalezen stary adis zaznam pro "+adis.dic.to_s
      adis.updateFromNet
      adis.save
    end

  end
end

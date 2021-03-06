# encoding: UTF-8
class AdisRegistration < ActiveRecord::Base
  attr_accessible :dic, :downloaded_at, :listed_at, :published_at, :listed_unreliable_status, :actual_at

  after_initialize :init

  CACHE_ENABLED = false

  XML_PATH = 'db/xml/adis'
  ADIS_URI = 'http://adisreg.mfcr.cz/cgi-bin/adis/idph/int_dp_prij.cgi?id=1&pocet=1&fu=&OK=+Search+&ZPRAC=RDPHI1&dic='

  def init
    if downloaded_at.nil?
      update_from_net
      save
    end
  end

  def update_from_net
    parse_html download_html
  end

  def download_html
    filename = XML_PATH+'/CZ'+dic.to_s+'.html'

    unless CACHE_ENABLED and File.exists?(filename)
      puts "Downloading dic "+dic.to_s+" from ADIS registr"
      File.open(filename, 'w') do |f|
        uri = URI(ADIS_URI+dic.to_s)
        data = Net::HTTP.get(uri).force_encoding('iso-8859-2')
        coder = HTMLEntities.new
        data = coder.decode(data)
        f.write(data)
        self.downloaded_at = DateTime.current
      end
    end

    Nokogiri::HTML(File.open(filename),nil,'utf-8') if File.exists?(filename)
  end

  def parse_html(doc)
    if m = /Nespolehlivý plátce:(.*)od:(.*)datum zveřejnění:([^\n]*)/mi.match(doc.text)
      self.listed_unreliable_status = m[1].strip!
      self.listed_at = m[2].strip!
      self.published_at = m[3].strip!
    end

    if m = /Záznam zobrazuje informace evidované finančním úřadem ke\s+dni\s+([^\n]*)/mi.match(doc.text)
      self.actual_at = m[1].strip!
    end

  end


end

class AresRegistration < ActiveRecord::Base
  attr_accessible :cz_payer, :name, :vat_number, :ic, :downloaded_at, :actual_at, :reg_insolv, :reg_upadce
  after_initialize :init

  CACHE_ENABLED = false

  XML_PATH = 'db/xml/ares'

  ARES_VERSION="1.0.3"
  ARES_URI_BASIC = 'http://wwwinfo.mfcr.cz/cgi-bin/ares/darv_bas.cgi'
  ARE_XMLNS  = 'http://wwwinfo.mfcr.cz/ares/xml_doc/schemas/ares/ares_answer_basic/v_'+ARES_VERSION
  DTT_XMLNS = 'http://wwwinfo.mfcr.cz/ares/xml_doc/schemas/ares/ares_datatypes/v_'+ARES_VERSION

  ZKR_VYPIS_BASIC = 'VBAS'
  ZKR_AKTUALIZACE_DB = 'ADB'
  ZKR_PRIZNAKY_SUBJEKTU = 'PSU'
  ZKR_PRAVNI_FORMA="PF"
  ZKR_NAZEV_PF="NPF"
  ZKR_OBCHODNI_FIRMA="OF"
  ZKR_ADRESA_ARES='AA'
  ZKR_NAZEV_ULICE='NU'

  def init
    if self.downloaded_at.nil?
      parseXml(downloadXml)
    end
  end

  def cz_payer?
    cz_payer.match(/^(A|S)$/)!=nil
  end

  def reg_adis
    cz_payer? ? AdisRegistration.find_by_dic(dic) : nil
  end

  def updateFromNet
    parseXml(downloadXml)
  end


  def downloadXml

    filename = XML_PATH+'/basic_'+ic.to_s+".xml"

    # TODO: Uplne pryc cache, ale hlidat limity
    unless CACHE_ENABLED and File.exists?(filename)
      puts "Downloading ic #{ic.to_s} from ARES registr"
      File.open(filename, 'w') do |f|
        uri = URI("#{ARES_URI_BASIC}?ver=#{ARES_VERSION}&ico=#{ic.to_s}")
        data = Net::HTTP.get(uri).force_encoding('utf-8')
        coder = HTMLEntities.new
        data = coder.decode(data)
        f.write(data)
        self.downloaded_at = DateTime.current
      end
    end

    Nokogiri::XML(File.open(filename)) if File.exists?(filename)
  end

  def parseXml(doc)
    doc.xpath("/are:Ares_odpovedi/are:Odpoved/D:"+ZKR_VYPIS_BASIC, 'are'=>ARE_XMLNS, "D"=>DTT_XMLNS).each do |answer|
      logger.debug('answer '+answer.xpath("D:ICO").first.content)

      if answer.xpath("D:ICO").first.content.to_i == self.ic.to_i
        self.actual_at = answer.xpath("//D:"+ZKR_AKTUALIZACE_DB).first.content
        self.name = answer.xpath("D:"+ZKR_OBCHODNI_FIRMA).first.content
        at = answer.xpath("D:"+ZKR_PRIZNAKY_SUBJEKTU).first.content
        registers = { :OR => at[1], :RZP => at[3], :DPH=>at[5], :UPADCE=>(at[8]=="A" or at[9]=="A"), :INSOLV=>at[21] }
        logger.debug(registers)
        self.cz_payer = registers[:DPH]

        self.dic = answer.xpath("D:DIC").first.content.match(/^(CZ)([0-9]+)$/)[2].to_i rescue nil if registers[:DPH]=='A'
        if registers[:INSOLV]=='E' or registers[:INSOLV]=='F'
          self.reg_insolv = true
        end
        self.reg_upadce = registers[:UPADCE]

      end
    end

  end

end

class AresRegistration < ActiveRecord::Base
  audit!(:create, :update, :only => [:cz_payer, :name, :vat_number, :dic, :reg_insolv, :reg_upadce] ) { |model, user, action| "Ares modified by #{ user.email rescue 'anonymous@mikrois.cz' }" }

  attr_accessible :cz_payer, :name, :vat_number, :ic, :downloaded_at, :actual_at, :reg_insolv, :reg_upadce
  validates :ic, :presence => true, :uniqueness => true

  after_initialize :init
  before_save :before_save

  scope :recent, where("actual_at IS NOT NULL").order("reg_insolv DESC, reg_upadce DESC, updated_at DESC")

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
    if downloaded_at.nil?
      parse_xml download_xml
    end
  end

  def before_save

    # if not listed in ARES, dont try redownload before 1 month
    if self.name.nil?
      self.downloaded_at.advance(:month => +1)
    end

  end

  def cz_payer?
    return nil unless cz_payer
    cz_payer.match(/^(A|S)$/)!=nil
  end

  def reg_adis
    cz_payer? ? AdisRegistration.find_by_dic(dic) : nil
  end

  def update_from_net
    parse_xml download_xml if self.downloaded_at.nil?
  end


  def download_xml
    filename = XML_PATH+'/basic_'+ic.to_s+".xml"

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

  def parse_xml(doc)
    doc.xpath("/are:Ares_odpovedi/are:Odpoved/D:"+ZKR_VYPIS_BASIC, 'are'=>ARE_XMLNS, "D"=>DTT_XMLNS).each do |answer|
      logger.debug('answer '+answer.xpath("D:ICO").first.content)

      if answer.xpath("D:ICO").first.content.to_i == self.ic.to_i
        self.actual_at = answer.xpath("//D:"+ZKR_AKTUALIZACE_DB).first.content
        self.name = answer.xpath("D:"+ZKR_OBCHODNI_FIRMA).first.content
        at = answer.xpath("D:"+ZKR_PRIZNAKY_SUBJEKTU).first.content
        registers = { :OR => at[1], :RZP => at[3], :DPH=>at[5], :UPADCE=>(at[8]=="A" or at[9]=="A"), :INSOLV=>at[21] }
        logger.debug(registers)
        self.cz_payer = registers[:DPH]

        if registers[:DPH]=='A'
          self.dic = answer.xpath("D:DIC").first.content.match(/^(CZ)([0-9]+)$/)[2].to_i rescue nil
        end
        if registers[:INSOLV]=='E' or registers[:INSOLV]=='F'
          self.reg_insolv = true
        end
        self.reg_upadce = registers[:UPADCE]

      end
    end

  end

  def changelog
    audits.last.audited_changes
  end

end

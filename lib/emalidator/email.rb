module Emalidator
  class Email
    @columns = []
    @send_as = 'tbarter.mailer@gmail.com'

    class << self
      attr_accessor :columns
      attr_accessor :disposable_domains
      attr_accessor :send_as
    end

    attr_accessor :emalidator_mxers
    attr_accessor :emalidator_valid
    attr_accessor :emalidator_errors

    def initialize(values)
      values.each_with_index do |value, index|
        next unless Email.columns[index]
        send "#{Email.columns[index]}=", value
      end

      cleanup_email
      self.emalidator_valid = false # assume false by default
      self.emalidator_errors = []
    end

    def to_csv
      fields = Email.columns.map do |field_name|
        send field_name
      end

      return fields.join ',' unless @emalidator_errors.any?
      (fields + [@emalidator_errors.first]).join ','
    end

    def cleanup_email
      self.email = email.strip.downcase
    end

    def domain
      self.email.split('@').last
    end

    def validity
      emalidator_valid ? 'valid' : "invalid (#{emalidator_errors.first})"
    end

    def validate
      unless valid_syntax?
        self.emalidator_errors.push 'Bad syntax'
        self.emalidator_valid = false
        return
      end

      if disposable?
        self.emalidator_errors.push 'Disposable'
        self.emalidator_valid = false
        return
      end

      unless find_mxers
        self.emalidator_errors.push 'No MX host found'
        self.emalidator_valid = false
        return
      end

      unless server_says_its_ok?
        self.emalidator_errors.push 'Server said nope'
        self.emalidator_valid = false
        return
      end

      self.emalidator_valid = true
    end

    def find_mxers
      self.emalidator_mxers = Resolv::DNS.open do |dns|
        ress = dns.getresources(domain, Resolv::DNS::Resource::IN::MX)
        ress.map { |r| { priority: r.preference, address: r.exchange.to_s } }
      end

      self.emalidator_mxers.sort_by! { |mx| mx[:priority] }
    rescue
      self.emalidator_mxers = []
    ensure
      self.emalidator_mxers.any?
    end

    def server_says_its_ok?
      emalidator_mxers.each do |mx_server|
        begin
          result = check_in_server mx_server
          return true if result
        rescue => e
          byebug
        end
      end
    rescue => e
      byebug
      return false
    end

    def check_in_server(mx_server)
      Net::SMTP.start(mx_server[:address], 25) do |smtp|
        response = smtp.helo 'hi'
        return false unless response.success?
        response = smtp.starttls
        return false unless response.success?
        response = smtp.mailfrom Email.send_as
        return false unless response.success?
        response = smtp.rcptto email
        byebug
        return response.success?
      end
    rescue => e
      puts e.message
      return false
    end

    def disposable?
      Email.disposable_domains.include? domain
    end

    def valid_syntax?
      self.email =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    end

    def self.safe_column_name(string)
      return unless string and string.length > 0
      name = string.downcase.strip.gsub(' ', '_').gsub(/[?]/, '')
      name.length > 0 ? name : nil
    end

    def self.columns_csv(include_error: false)
      return self.columns.join ',' unless include_error
      (self.columns + ['error']).join ','
    end

    def self.columns=(columns)
      columns.each do |column|
        column_name = safe_column_name column
        self.columns.push column_name
        next unless column_name
        class_eval { attr_accessor column_name }
      end
    end

    def self.columns?
      self.columns.any?
    end

    def self.load_disposable_domains
      self.disposable_domains = JSON.parse(File.read 'lib/emalidator/disposable_domains.json')['domains']
    end
  end
end

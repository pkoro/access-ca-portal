# ValidatesAsCertificateRequest

module ActiveRecord
  module Validations
    module ClassMethods
      def validates_as_certificate_request(*attr_names)
        configuration = {
          :message   => 'is an invalid certificate_request',
          :with      => nil,
          :allow_nil => false }
        configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

        validates_each(attr_names, configuration) do |record, attr_name, value|
          if value !~ /SPKAC/
            begin
              vv = OpenSSL::X509::Request.new(value)
              record.errors.add(attr_name, configuration[:message]) unless vv.public_key.public_key.to_text.match(/\d+/)[0].to_i >= 1024
            rescue
              record.errors.add(attr_name, configuration[:message])
            end
          else
            begin
              info, spkac = value.split(/SPKAC=/)
              vv = OpenSSL::Netscape::SPKI.new(spkac)
              record.errors.add(attr_name, configuration[:message]) unless vv.public_key.public_key.to_text.match(/\d+/)[0].to_i >= 1024
            rescue
             record.errors.add(attr_name, configuration[:message])
            end
          end
        end      
      end
    end
  end
end
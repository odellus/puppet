require 'puppet/indirector/file'
require 'puppet/ssl/key'

class Puppet::SSL::Key::File < Puppet::Indirector::File
    desc "Manage SSL private and public keys on disk."

    # Is this key a CA key?
    def ca_key?(key)
        key.name == :ca
    end

    def path(name)
        if name == :ca
            Puppet.settings[:cakey]
        else
            File.join(Puppet.settings[:privatekeydir], name.to_s + ".pem")
        end
    end

    def public_key_path(name)
        if name == :ca
            Puppet.settings[:capub]
        else
            File.join(Puppet.settings[:publickeydir], name.to_s + ".pem")
        end
    end

    def save(key)
        return save_ca_key(key) if ca_key?(key)

        # Save the private key
        File.open(path(key.name), "w") { |f| f.print key.to_pem }

        # Now save the public key
        File.open(public_key_path(name), "w") { |f| f.print key.to_pem }
    end

    def find(name)
        return find_ca_key(key) if ca_key?(key)

        return nil unless FileTest.exist?(path(name))
        OpenSSL::PKey::RSA.new(File.read(path(name)))
    end

    def destroy(name)
        return find_ca_key(key) if ca_key?(key)

        return nil unless FileTest.exist?(path(name))
        File.unlink(path(name)) and true
    end
end

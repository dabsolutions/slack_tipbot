module Komodo
  class Client2
    def self.local
      return Komodo::Client2.new(ENV['RPC_USER2'], ENV['RPC_PASSWORD2'],
        { host: '127.0.0.1', port: 7771, ssl: false} )
    end
  end
end

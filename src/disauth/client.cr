require "json"
require "http/client"
require "openssl/ssl/context"

module Discord

  class Client
    SSL_CONTEXT = OpenSSL::SSL::Context::Client.new
    USER_AGENT  = "gyulabot"
    API_BASE    = "https://discordapp.com/api"

    def request(method : String, path : String, headers : HTTP::Headers, body : String?)
      headers["User-Agent"] = USER_AGENT
      response = HTTP::Client.exec(method: method, url: API_BASE + path, headers: headers, body: body, tls: SSL_CONTEXT)
      return {"status" => response.status_code, "data" => JSON.parse(response.body)}.to_json
    end

    def getToken(code : String?, type : String)
      params = HTTP::Params.build do |form|
        form.add "client_id", @client_id.to_s
        form.add "client_secret", @client_secret
        form.add "grant_type", type
        if !code.nil? # refresh_token
          form.add "code", code
        end
        form.add "redirect_uri", @redirect_uri
        form.add "scope", "identify email"
      end
    
      headers = HTTP::Headers.new
      headers.add("content-type", "application/x-www-form-urlencoded")
      return request("POST", "/oauth2/token", headers, params)
      
    end

    def getUser(token)
      headers = HTTP::Headers.new
      headers["Authorization"] = "Bearer #{token}"
      return request("GET","/users/@me", headers, nil)
    end

    def initialize(@client_id : UInt64, @client_secret : String, @redirect_uri : String)
      puts "hello friend."
    end
  end
end
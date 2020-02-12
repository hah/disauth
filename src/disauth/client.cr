require "json"
require "http/client"
require "openssl/ssl/context"
require "base64"

module Discord

  class Client
    SSL_CONTEXT = OpenSSL::SSL::Context::Client.new
    USER_AGENT  = "gyulabot"
    API_BASE    = "https://discordapp.com/api"

    def request(method : String, path : String, headers : HTTP::Headers, body : String?)
      headers.add("user-agent", USER_AGENT)
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

    def revokeToken(token : String)
      params = HTTP::Params.build do |form|
        form.add "token", token
      end
      headers = HTTP::Headers.new
      # Base64.encode inserts a new line after every 60 characters
      # gsub to replace all occurances to get a one-liner for auth
      authkey = Base64.encode("#{@client_id}:#{@client_secret}").gsub("\n","") 
      headers.add("authorization", "Basic #{authkey}")
      headers.add("content-type", "application/x-www-form-urlencoded")
      return request("POST", "/oauth2/token/revoke", headers, params)
    end

    def getUser(token : String)
      headers = HTTP::Headers.new
      headers.add("authorization", "Bearer #{token}")
      return request("GET","/users/@me", headers, nil)
    end

    def initialize(@client_id : UInt64, @client_secret : String, @redirect_uri : String)
      puts "hello friend."
    end
  end
end
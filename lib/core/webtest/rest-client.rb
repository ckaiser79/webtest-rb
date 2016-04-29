require 'sz/hash_utils'
require 'rest-client'
require 'json'
require 'decorator'
require 'base64'
require 'nokogiri' # xml parser

module Webtest

  module XmlRpc

    class Response

      def initialize xmlDoc
        @xml = xmlDoc
      end

      def fault
        n = @xml.xpath('/methodResponse/fault')
        if n.length == 0
          return nil
        else
          return n
        end
      end

    end

  end

  module RestClientFascade

    class RestClientResponseDecorator

      include Decorator

      def body_json(dropRootKey = true)
        jsonHash = JSON.parse(@decorated.body)
        return SZ::HashDecorator.new(jsonHash, dropRootKey)
      end

      def body_xml()
        doc = Nokogiri::XML(@decorated.body)
        doc.remove_namespaces!
        return doc
      end

    end

    #
    # implementation based on rest-client:
    # http://rubydoc.info/gems/rest-client/frames
    #
    class Instance

      attr_writer :endpointPrefix
      attr_writer :defaultHeaders
      attr_accessor :honorSsl

      def initialize
        configureRestClient
        @endpointPrefix = ''
        @defaultHeaders = {}
        @honorSsl = false
      end

      def get(endpoint, headers = {}, dumpFileSuffix = nil)
        fullEndpoint = getFullQualifiedUrl(endpoint)
        headers = evaluateHeaders(headers)

        responseLogfile = createLogfile('get', dumpFileSuffix)
        logRequest(responseLogfile, fullEndpoint, headers)

        response = RestClient::Resource.new(fullEndpoint, :verify_ssl => @honorSsl).get headers

        logResponse(responseLogfile, response)
        responseLogfile.close

        decoratedResponse = RestClientResponseDecorator.new(response)
        return decoratedResponse
      end

      def post(endpoint, payload, headers = {}, dumpFileSuffix = nil)
        fullEndpoint = getFullQualifiedUrl(endpoint)
        headers = evaluateHeaders(headers)

        responseLogfile = createLogfile('post', dumpFileSuffix)
        logRequest(responseLogfile, fullEndpoint, headers, payload)

        response = RestClient::Resource.new(fullEndpoint, :verify_ssl => @honorSsl).post payload, headers

        logResponse(responseLogfile, response)
        responseLogfile.close

        decoratedResponse = RestClientResponseDecorator.new(response)
        return decoratedResponse
      end

      def put(endpoint, payload, headers = {}, dumpFileSuffix = nil)
        fullEndpoint = getFullQualifiedUrl(endpoint)
        headers = evaluateHeaders(headers)

        responseLogfile = createLogfile('put', dumpFileSuffix)
        logRequest(responseLogfile, fullEndpoint, headers, payload)

        response = RestClient::Resource.new(fullEndpoint, :verify_ssl => @honorSsl).put payload, headers

        logResponse(responseLogfile, response)
        responseLogfile.close

        decoratedResponse = RestClientResponseDecorator.new(response)
        return decoratedResponse
      end

      def options(endpoint, headers = {}, dumpFileSuffix = nil)
        fullEndpoint = getFullQualifiedUrl(endpoint)
        headers = evaluateHeaders(headers)

        responseLogfile = createLogfile('options', dumpFileSuffix)
        logRequest(responseLogfile, fullEndpoint, headers)

        response = RestClient::Resource.new(fullEndpoint, :verify_ssl => @honorSsl).options headers

        logResponse(responseLogfile, response)
        responseLogfile.close

        decoratedResponse = RestClientResponseDecorator.new(response)
        return decoratedResponse
      end

      def head(endpoint, headers = {}, dumpFileSuffix = nil)
        fullEndpoint = getFullQualifiedUrl(endpoint)
        headers = evaluateHeaders(headers)

        responseLogfile = createLogfile('head', dumpFileSuffix)
        logRequest(responseLogfile, fullEndpoint, headers)

        response = RestClient::Resource.new(fullEndpoint, :verify_ssl => @honorSsl).head headers

        logResponse(responseLogfile, response)
        responseLogfile.close

        decoratedResponse = RestClientResponseDecorator.new(response)
        return decoratedResponse
      end

      def delete(endpoint, headers = {}, dumpFileSuffix = nil)
        fullEndpoint = getFullQualifiedUrl(endpoint)
        headers = evaluateHeaders(headers)

        responseLogfile = createLogfile('delete', dumpFileSuffix)
        logRequest(responseLogfile, fullEndpoint, headers)

        response = RestClient::Resource.new(fullEndpoint, :verify_ssl => @honorSsl).delete headers

        logResponse(responseLogfile, response)
        responseLogfile.close

        decoratedResponse = RestClientResponseDecorator.new(response)
        return decoratedResponse
      end

      private

      def configureRestClient
        proxyUrl = WTAC.instance.config.read "rest-client:proxy-url"
        if proxyUrl == 'none'
          RestClient.proxy = ''
        else
          RestClient.proxy = proxyUrl
        end
      end

      def getFullQualifiedUrl(endpoint)
        WTAC.instance.log.info "getFullQualifiedUrl: << " + @endpointPrefix + endpoint
        return @endpointPrefix + endpoint
      end

      def createLogfile(method, dumpFileSuffix)
        if dumpFileSuffix != nil
          suffix = method.to_s + '-' + dumpFileSuffix.to_s
        else
          suffix = method.to_s
        end

        fileName = SZ::NumericPrefixGenerateService.instance.nextFile "txt", "rest-" + suffix
        responseLogfile = Webtest::Files.autoClose fileName
        return responseLogfile
      end

      def logRequest(responseLogfile, fullEndpoint, headers, payload = nil)
        responseLogfile.puts '== REQUEST =='
        responseLogfile.puts 'ENDPOINT: ' + fullEndpoint
        responseLogfile.puts 'HEADERS: ' + headers.to_s
        responseLogfile.puts ''
        responseLogfile.puts 'payload' if payload != nil
      end

      def logResponse(responseLogfile, response)
        responseLogfile.puts '== RESPONSE =='
        responseLogfile.puts response.to_s
        responseLogfile.puts ''
      end

      def evaluateHeaders(headers)
        newHeaders = @defaultHeaders.merge(headers) { |key, first, second| second }

        setHttpBasicAuthorization(newHeaders)
        newHeaders.delete(:webtest)

        return newHeaders
      end

      def setHttpBasicAuthorization(headers)
        value = headers[:webtest]
        if value != nil && value[:username] != nil
          usernamePassword = Base64.strict_encode64(value[:username] + ':' + value[:password])
          headers[:authorization] = 'Basic ' + usernamePassword
        end
      end
    end

  end
end
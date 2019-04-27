require "multi_xml"
require "omniauth-oauth"
require "oauth/signature/plaintext"

module OmniAuth
  module Strategies
    class FreshBooksClassic < OmniAuth::Strategies::OAuth
      option :client_options, {
        access_token_path: "/oauth/oauth_access.php",
        authorize_path: "/oauth/oauth_authorize.php",
        request_token_path: "/oauth/oauth_request.php",
        signature_method: "PLAINTEXT"
      }

      uid { options.client_options.site + "/" + raw_info["staff_id"] }

      info do
        {
          name: [raw_info["first_name"], raw_info["last_name"]].compact.join(" "),
          first_name: raw_info["first_name"],
          last_name: raw_info["last_name"],
          email: raw_info["email"],
          nickname: raw_info["username"],
          location: [raw_info["city"], raw_info["state"], raw_info["country"]].compact.join(", "),
          phone: raw_info["business_phone"],
          urls: {
            "FreshBooks" => options.client_options.site
          }
        }
      end

      extra do
        { raw_info: raw_info }
      end

      def redirect(*args)
        session["oauth"] ||= {}
        session["oauth"][name.to_s] ||= {}
        session["oauth"][name.to_s].merge!({
          "site" => options.client_options.site
        })
        super
      end

      def request_phase
        options.client_options.site = options.site.presence || session["omniauth.params"]["site"].presence

        unless options.client_options.site
          OmniAuth::Form.build(title: (options.title.presence || "FreshBooks Authentication")) do |form|
            form.text_field "URL", "site"
          end.to_response
        else
          super
        end
      rescue ::OAuth::Unauthorized => e
        return fail(e) if e.message != '404 Not Found'

        fail!(:site_not_found)
      rescue URI::InvalidURIError
        fail!(:invalid_site)
      rescue Net::HTTPRetriableError
        fail!(:invalid_site)
      end

      def callback_phase
        options.client_options.site = session["oauth"][name.to_s]["site"] if session["oauth"].present?
        super
      end

      def raw_info
        @raw_info ||= MultiXml.parse(access_token.post("/api/2.1/xml-in", '<?xml version="1.0" encoding="utf-8"?><request method="staff.current"></request>').body).fetch("response").fetch("staff")
      end
    end
  end
end

OmniAuth.config.add_camelization "freshbooks_classic", "FreshBooksClassic"

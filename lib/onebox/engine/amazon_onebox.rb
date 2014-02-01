module Onebox
  module Engine
    class AmazonOnebox
      include Engine
      include LayoutSupport
      include HTML

      matches do
        http
        maybe("www.")
        domain("amazon")
        has(".").either("com.br","com", "ca", "cn", "fr", "de", "es", "it", "co.jp", "co.uk").maybe("/")
      end

      def url 
        return "http://" + URI::encode(match[:domain]) + "/gp/aw/d/" + URI::encode(match[:id]) if match && match[:id]
        @url
      end

      def http_params
        {'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 5_0_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A405 Safari/7534.48.3'}
      end

      private

      def match
        @match ||= @url.match(/(?:domain(com.br|com|ca|cn|fr|de|es|it|co.jp|co.uk))(?:d|g)p\/(?:product\/)?(?<id>[^\/]+)(?:\/|$)/mi)
      end
      
      def image
        case
        when raw.css("#main-image").any?
          raw.css("#main-image").first["src"]
        when raw.css("#landingImage").any?
          raw.css("#landingImage").first["src"]
        end
      end

      def data
        result = { link: link,
                   title: raw.css("h1").inner_text,
                   image: image,
                   price: raw.css(".priceLarge").inner_text }

        result[:by_info] = raw.at("#by-line")
        result[:by_info] = Onebox::Helpers.clean(result[:by_info].inner_html) if result[:by_info]

        summary = raw.at("#about-item span")
        result[:description] = summary.inner_html if summary
        result
      end
    end
  end
end

module Discourse
  module Oneboxer
    class AmazonOnebox < HandlebarsOnebox

      matcher /^https?:\/\/(?:www\.)?amazon.(com|ca)\/.*$/
      favicon 'amazon.png'

      def template
        template_path("simple_onebox")
      end

      # Use the mobile version of the site
      def translate_url

        # If we're already mobile don't translate the url
        return @url if @url =~ /https?:\/\/www\.amazon\.com\/gp\/aw\/d\//

        m = @url.match(/(?:d|g)p\/(?:product\/)?(?<id>[^\/]+)(?:\/|$)/mi)
        return "http://www.amazon.com/gp/aw/d/#{URI::encode(m[:id])}" if m.to_a.any?
        @url
      end

      def parse(data)
        html_doc = Nokogiri::HTML(data)

        result = {}
        result[:title] = html_doc.at("h1")
        result[:title] = result[:title].inner_html unless result[:title].nil?

        image = html_doc.at(".main-image img")
        result[:image] = image['src'] if image

        result[:by_info] = html_doc.at("#by-line")

        unless result[:by_info].nil?
          result[:by_info] = BaseOnebox.remove_whitespace(BaseOnebox.replace_tags_with_spaces(result[:by_info].inner_html))
        end

        summary = html_doc.at("#description-and-details-content")
        result[:text] = summary.inner_html unless summary.nil?

        result
      end

    end
  end
end

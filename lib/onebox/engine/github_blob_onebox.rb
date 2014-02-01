module Onebox
  module Engine
    class GithubBlobOnebox
      include Engine
      include LayoutSupport

      matches do
        http
        maybe("www")
        domain("github")
        tld("com")
        anything
        with("/blob/")
      end

      private

      def raw
        return @raw if @raw
        m = @url.match(/github\.com\/(?<user>[^\/]+)\/(?<repo>[^\/]+)\/blob\/(?<sha1>[^\/]+)\/(?<file>[^#]+)(#(L(?<from>[^-]*)(-L(?<to>.*))?))?/mi)
        if m
          from = (m[:from] || -1).to_i
          to = (m[:to] || -1).to_i
          @file = m[:file]
          contents = open("https://raw.github.com/#{m[:user]}/#{m[:repo]}/#{m[:sha1]}/#{m[:file]}", read_timeout: timeout).read
          if from > 0
            if to < 0
              from = from - 10
              to = from + 20
            end
            if to > from
              contents = contents.split("\n")[from..to].join("\n")
            end
          end
          if contents.length > 5000
            contents = contents[0..5000]
            @truncated = true
          end
          @raw = contents
        end
      end

      def data
        @data ||= {title: link, link: link, content: raw, truncated: @truncated} 
      end
    end
  end
end

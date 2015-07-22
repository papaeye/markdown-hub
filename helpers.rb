require 'html/pipeline'

# copied html/pipeline/syntax_highlight_filter.rb and
# removed github-linguist dependency.
module MarkdownHub
  # HTML Filter that syntax highlights code blocks wrapped
  # in <pre lang="...">.
  class SyntaxHighlightFilter < HTML::Pipeline::Filter
    def call
      doc.search('pre').each do |node|
        default = context[:highlight] && context[:highlight].to_s
        next unless lang = node['lang'] || default
        next unless lexer = lexer_for(lang)
        text = node.inner_text

        html = highlight_with_timeout_handling(lexer, text)
        next if html.nil?

        if (node = node.replace(html).first)
          klass = node["class"]
          klass = [klass, "highlight-#{lang}"].compact.join " "

          node["class"] = klass
        end
      end
      doc
    end

    def highlight_with_timeout_handling(lexer, text)
      lexer.highlight(text)
    rescue Timeout::Error
      nil
    end

    def lexer_for(lang)
      Pygments::Lexer[lang]
    end
  end
end

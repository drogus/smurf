if Rails.version =~ /^2\.2\./
  # Support for Rails >= 2.2.x
  module Smurf
    def self.minify_assets(type, content)
      tmp = File.join(RAILS_ROOT, "tmp/minified.#{type}")
      compressor = File.join(RAILS_ROOT, 'vendor/plugins/smurf/bin/yuicompressor.jar')
      file = File.open(tmp, "w")
      file.write(content)
      file.close
      output = `java -jar #{compressor} #{tmp}`
      File.unlink(tmp)
      output
    end

    module JavaScriptSources
    private
      def joined_contents
        Smurf.minify_assets('js', super)
      end
    end # JavaScriptSources

    module StylesheetSources
    private
      def joined_contents
        Smurf.minify_assets('css', super)
      end
    end # StylesheetSources

  end # ActionView::Helpers::AssetTagHelper::AssetTag
  ActionView::Helpers::AssetTagHelper::JavaScriptSources.send(
    :include, Smurf::JavaScriptSources)
  ActionView::Helpers::AssetTagHelper::StylesheetSources.send(
    :include, Smurf::StylesheetSources)
else
  # Support for Rails <= 2.1.x
  module ActionView::Helpers::AssetTagHelper
  private
    def join_asset_file_contents_with_minification(files)
      content = join_asset_file_contents_without_minification(files)
      if !files.grep(%r[/javascripts]).empty?
        Smurf.minify_assets('js', content)
      elsif !files.grep(%r[/stylesheets]).empty?
        Smurf.minify_assets('css', content)
      end
      content
    end
    alias_method_chain :join_asset_file_contents, :minification
  end # ActionView::Helpers::AssetTagHelper
end

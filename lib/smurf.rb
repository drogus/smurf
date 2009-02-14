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

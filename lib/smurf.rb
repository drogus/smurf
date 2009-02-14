module Smurf
  def self.minify_assets(filename)
    compressor = File.join(RAILS_ROOT, 'vendor/plugins/smurf/bin/yuicompressor.jar')
    `java -jar #{compressor} #{filename} -o #{filename}`
  end
end

module ActionView::Helpers::AssetTagHelper
  def write_asset_file_contents_with_packaging(joined_asset_path, asset_paths)
    write_asset_file_contents_without_packaging(joined_asset_path, asset_paths)
    Smurf.minify_assets(joined_asset_path)
  end

  alias_method_chain :write_asset_file_contents, :packaging
end

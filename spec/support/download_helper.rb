# frozen_string_literal: true

module FileDownloadHelper
  PATH = ENV['RSPEC_DOWNLOAD_PATH']
  BROWSER_PATH = ENV['RSPEC_BROWSER_DOWNLOAD_PATH']
  TIMEOUT = 10

  class << self
    def wait_for_download
      Timeout.timeout(TIMEOUT) do
        sleep(0.5) until downloaded?
      end
    end

    def download_path(path: nil)
      convert_path_separator(File.join(path || PATH, Thread.current.object_id.to_s))
    end

    def browser_download_path
      download_path(path: BROWSER_PATH)
    end

    def convert_path_separator(path)
      path.tap do |p|
        p.gsub!(%r{/}, '\\') if p.include?('\\')
      end
    end

    def downloads(pattern: '*')
      Dir.glob(File.join(download_path, pattern))
    end

    def downloaded?
      !downloading? && downloads.any?
    end

    def downloading?
      downloads.grep(/\.crdownload\z/).any?
    end

    def clear_downloads
      FileUtils.rm_rf(downloads)
    end
  end
end

RSpec.configure do |config|
  # config.include FileDownloadHelper, type: :system

  config.before :all, type: :system do
    FileUtils.mkdir_p(FileDownloadHelper.download_path)
  end

  config.after :all, type: :system do
    FileUtils.rm_rf(FileDownloadHelper.download_path)
  end

  config.before do
    FileDownloadHelper.clear_downloads
  end
end

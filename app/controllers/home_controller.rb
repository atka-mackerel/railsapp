class HomeController < ApplicationController
  skip_before_action :store_location
  skip_before_action :login_required

  def index
    @services = [].tap do |s|
      s << { image_path: 'ytsearch.svg', title: t('.services.ytsearch.name'), description: '.services.ytsearch.description_html', link: ytsearch_path }
      s << { image_path: 'cloudmemo.svg', title: t('.services.cloudmemo.name'), description: '.services.cloudmemo.description_html', link: memos_path }
    end

    @envs = t('.environments')
  end
end

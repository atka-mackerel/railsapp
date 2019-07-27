class HomeController < ApplicationController
  skip_before_action :store_location
  skip_before_action :login_required

  def index
    @services = [].tap do |s|
      s << { image_path: 'ytsearch.svg', title: t('.services.ytsearch.name'), description: '.services.ytsearch.description_html', link: ytsearch_path }
      s << { image_path: 'cloudmemo.svg', title: t('.services.cloudmemo.name'), description: '.services.cloudmemo.description_html', link: memos_path }
    end

    @envs = [].tap do |e|
      e << { title: t('.env_languages')[:title], data: t('.env_languages')[:data] }
      e << { title: t('.env_frameworks')[:title], data: t('.env_frameworks')[:data] }
      e << { title: t('.env_databases')[:title], data: t('.env_databases')[:data] }
      e << { title: t('.env_servers')[:title], data: t('.env_servers')[:data] }
      e << { title: t('.env_webservers')[:title], data: t('.env_webservers')[:data] }
      e << { title: t('.env_source_management')[:title], data: t('.env_source_management')[:data] }
    end
  end
end

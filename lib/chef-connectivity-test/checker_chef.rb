module Training
    # Chef connectivity tests
  #
  # @author Seth Vargo <sethvargo@gmail.com>
  class Chef < Checker
    require 'chef/api_client'
    require 'chef/cookbook_loader'
    require 'chef/cookbook_uploader'
    require 'chef/knife'
    require 'chef/knife/cookbook_create'
    require 'chef/rest'
    require 'chef/search/query'

    pre do
      ::Chef::Knife.new.configure_chef
    end

    banner 'EDITOR set'
    def editor_set
      !!ENV['editor'] || !!ENV['EDITOR']
    end

    banner 'Listing clients'
    def client_list
      !::Chef::ApiClient.list.empty?
    end

    banner 'Adding a client'
    def client_add
      client = ::Chef::ApiClient.new
      client.name('training-test')
      client.save

      ::Chef::ApiClient.list.any? { |_, client| client =~ /training\-test$/ }
    end

    banner 'Showing a client'
    def client_show
      client = ::Chef::ApiClient.load('training-test')
      true
    end

    banner 'Updating a client'
    def client_update
      client = ::Chef::ApiClient.load('training-test')
      client.public_key(OpenSSL::PKey::RSA.new(2048).public_key.to_pem)
      client.save

      true
    end

    banner 'Deleting a client'
    def client_delete
      client = ::Chef::ApiClient.load('training-test')
      client.destroy

      !::Chef::ApiClient.list.any? { |_, client| client =~ /training\-test$/ }
    end

    banner 'Creating a cookbook'
    def cookbook_create
      silence do
        generator = ::Chef::Knife::CookbookCreate.new
        generator.create_cookbook(Dir.pwd, 'training-test', 'default', 'apachev2')
        generator.create_changelog(Dir.pwd, 'training-test')
        generator.create_readme(Dir.pwd, 'training-test', 'md')
        generator.create_metadata(Dir.pwd, 'training-test', 'apachev2', 'default', 'default', 'md')
      end

      ::File.directory?('training-test')
    end

    banner 'Uploading a cookbook'
    def cookbook_upload
      cookbook = ::Chef::CookbookLoader.new(Dir.pwd).load_cookbook('training-test')
      !!::Chef::CookbookUploader.new(cookbook, Dir.pwd).upload_cookbooks
    end

    banner 'Listing cookbooks'
    def cookbook_list
      rest = ::Chef::REST.new(::Chef::Config[:chef_server_url])
      !!rest.get_rest('/cookbooks')
    end

    banner 'Deleting a cookbook'
    def cookbook_delete
      rest = ::Chef::REST.new(::Chef::Config[:chef_server_url])
      !!rest.delete_rest('cookbooks/training-test/0.1.0')
    end

    banner 'Downloading a cookbook (community)'
    def cookbook_download
      rest = ::Chef::REST.new(::Chef::Config[:chef_server_url], false, false)
      rest.sign_on_redirect = false

      info = rest.get_rest('https://cookbooks.opscode.com/api/v1/cookbooks/apache2/versions/1_0_0')
      tmp = rest.get(info['file'], true)
      ::FileUtils.cp(tmp.path, File.join(Dir.pwd, 'apache2.tar.gz'))
      ::File.exist?('apache2.tar.gz')
    end

    banner 'Searching'
    def search
      search = ::Chef::Search::Query.new
      !search.search('client', '*:*').empty?
    end
  end

end
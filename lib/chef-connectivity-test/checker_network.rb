module Training
  # Networking connectivity tests
  #
  # @author Seth Vargo <sethvargo@gmail.com>
  class Networking < Checker
    require 'net/ssh'
    require 'resolv'
    require 'socket'
    require 'timeout'

    banner 'Resolving DNS for "google.com"'
    def google_dns
      !Resolv::DNS.new.getresources('google.com', Resolv::DNS::Resource::IN::A).empty?
    end

    banner 'Connecting to Google'
    def google_connect
      ping('google.com')
    end

    banner 'Resolving DNS for "aws.amazon.com"'
    def ec2_dns
      !Resolv::DNS.new.getresources('aws.amazon.com', Resolv::DNS::Resource::IN::A).empty?
    end

    banner 'Connection to EC2'
    def ec2_connect
      ping('aws.amazon.com')
    end

    banner 'Connection to CloudShare'
    def cloudshare_connect
      ping('www.cloudshare.com')
    end

    banner 'Connection to CloudShare Labs'
    def cloudshare_labs_connect
      ping('use.cloudshare.com')
    end

    banner 'Resolving DNS for "manage.opscode.com"'
    def enterprise_chef_dns
      !Resolv::DNS.new.getresources('manage.opscode.com', Resolv::DNS::Resource::IN::A).empty?
    end

    banner 'Connecting to Enterprise Chef, Hosted'
    def enterprise_chef_connect
      ping('manage.opscode.com')
    end

    banner 'Checking SSH connection'
    def ssh_connect
      !!Net::SSH.start('github.com', 'git')
    end

    private
      def ping(host, timeout = Training::TIMEOUT)
        Timeout::timeout(timeout) { TCPSocket.new(host, 80).close }
        true
      rescue Errno::ECONNREFUSED
        true
      rescue Timeout::Error, StandardError => e
        false
      end
  end

end
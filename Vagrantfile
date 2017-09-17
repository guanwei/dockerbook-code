# -*- mode: ruby -*-

# vi: set ft=ruby :

require 'yaml'
settings = YAML.load_file 'vagrant.yml'

Vagrant.configure("2") do |config|
  required_plugins = %w(vagrant-timezone vagrant-proxyconf vagrant-docker-compose)
  plugins_to_install = required_plugins.select { |plugin| not Vagrant.has_plugin? plugin }
  if not plugins_to_install.empty?
    puts "Installing plugins: #{plugins_to_install.join(' ')}"
    if system "vagrant plugin install #{plugins_to_install.join(' ')}"
      exec "vagrant #{ARGV.join(' ')}"
    else
      abort "Installation of one or more plugins has failed. Aborting."
    end
  end
 
  config.vm.box = "ubuntu/xenial64"
  config.vm.box_check_update = false
  config.vbguest.auto_update = false
  
  config.timezone.value = :host
  
  if ENV["http_proxy"]
    puts "http_proxy: " + ENV["http_proxy"]
    config.proxy.http = ENV["http_proxy"]
  end
  if ENV["https_proxy"]
    puts "https_proxy: " + ENV["https_proxy"]
    config.proxy.https = ENV["https_proxy"]
  end
  if ENV["no_proxy"]
    puts "no_proxy: " + ENV["no_proxy"]
    config.proxy.no_proxy = ENV["no_proxy"]
  end

  config.vm.define "dockerbook" do |node|
    node.vm.hostname = "dockerbook"
    node.vm.network "private_network", ip: "10.10.10.10"
    node.vm.provider "virtualbox" do |v|
      v.name = "dockerbook"
      v.cpus = "1"
      v.memory = "1024"
    end

    node.vm.provision "docker" do |d|
      d.post_install_provision "shell", path: "scripts/set-docker-mirror.sh"
    end

    node.vm.provision "shell", path: "scripts/provision.sh"

    node.vm.provision "docker" do |d|
      #d.build_image "/vagrant/5/sinatra/redis", args: "-t jamtur01/redis --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy"
      #d.run "redis", image: "jamtur01/redis", args: "-p 6379:6379"
      #d.build_image "/vagrant/5/sinatra", args: "-t jamtur01/sinatra --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy"
      #d.run "sinatra", image: "jamtur01/sinatra", args: "-p 4567:4567 -v /vagrant/5/sinatra/webapp_redis:/opt/webapp --link redis:db"
      #d.build_image "/vagrant/5/jenkins", args: "-t jamtur01/jenkins --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy"
      #d.run "jenkins", image: "jamtur01/jenkins", args: "-p 8080:8080 -v /data/jenkins:/var/jenkins_home -v /etc/default/docker:/etc/default/docker --privileged -e TRY_UPGRADE_IF_NO_MARKER=true"
      #d.build_image "/vagrant/6/jekyll/jekyll", args: "-t jamtur01/jekyll --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy"
      #d.run "james_blog", image: "jamtur01/jekyll", args: "-v /vagrant/6/jekyll/james_blog:/data"
      #d.build_image "/vagrant/6/jekyll/apache", args: "-t jamtur01/apache --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy"
      #d.run "apache", image: "jamtur01/apache", args: "-p 80:80 --volumes-from james_blog"
      #d.build_image "/vagrant/6/tomcat/fetcher", args: "-t jamtur01/fetcher --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy"
      #d.run "sample", image: "jamtur01/fetcher", restart: "no", cmd: "https://tomcat.apache.org/tomcat-8.0-doc/appdev/sample/sample.war"
      #d.build_image "/vagrant/6/tomcat/tomcat8", args: "-t jamtur01/tomcat8 --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy"
      #d.run "sample_app", image: "jamtur01/tomcat8", args: "-P --volumes-from sample"
      #d.build_image "/vagrant/6/node/nodejs", args: "-t jamtur01/nodejs --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy"
      #d.build_image "/vagrant/6/node/redis_base", args: "-t jamtur01/redis --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy"
      #d.build_image "/vagrant/6/node/redis_primary", args: "-t jamtur01/redis_primary --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy"
      #d.build_image "/vagrant/6/node/redis_replica", args: "-t jamtur01/redis_replica --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy"
      #d.build_image "/vagrant/6/node/logstash", args: "-t jamtur01/logstash --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy"
      #d.run "redis_primary", image: "jamtur01/redis_primary", args: "-h redis_primary --net express"
      #d.run "redis_replica1", image: "jamtur01/redis_replica", args: "-h redis_replica1 --net express"
      #d.run "redis_replica2", image: "jamtur01/redis_replica", args: "-h redis_replica2 --net express"
      #d.run "nodeapp", image: "jamtur01/nodejs", args: "-p 3000:3000 --net express"
      #d.run "logstash", image: "jamtur01/logstash", args: "--volumes-from redis_primary --volumes-from nodeapp"
      #d.build_image "/vagrant/7/composeapp", args: "-t jamtur01/composeapp --build-arg http_proxy=$http_proxy --build-arg https_proxy=$https_proxy"
      #d.build_image "/vagrant/7/consul/consul", args: "-t jamtur01/consul --build-arg http_proxy=$local_proxy --build-arg https_proxy=$local_proxy"
      #d.run "consul", image: "jamtur01/consul", args: "-p 8500:8500 -p 53:53/udp -h node1", cmd: "-server -bootstrap -ui"
    end

    node.vm.provision "shell", path: "scripts/install-docker-compose.sh"

    #node.vm.provision "docker_compose",
    #  compose_version: "1.16.1",
    #  yml: "/vagrant/7/composeapp/docker-compose.yml",
    #  rebuild: true,
    #  run: "always"

    node.vm.provision "shell", path: "scripts/bootstrap.sh"
  end
end
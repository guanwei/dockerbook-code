# -*- mode: ruby -*-

# vi: set ft=ruby :

require 'yaml'
settings = YAML.load_file 'vagrant.yml'

Vagrant.configure("2") do |config|
  required_plugins = %w( vagrant-vbguest vagrant-disksize vagrant-proxyconf vagrant-docker-compose )
  installed_plugins = 0
  required_plugins.each do |plugin|
    unless Vagrant.has_plugin?(plugin)
      system("vagrant plugin install vagrant-docker-compose")
      installed_plugins += 1
    end
  end
  if installed_plugins > 0
    puts "Dependencies installed, please try the command again."
    exit
  end
 
  config.proxy.http = ENV['http_proxy']
  config.proxy.https = ENV['https_proxy']
  config.proxy.no_proxy = ENV['no_proxy']

  #config.vm.provision "shell", path: "set-apt-mirror.sh"

  config.vm.provision "docker" do |d|
    d.post_install_provision "shell", path: "set-docker-mirror.sh"
  end

  config.vm.define "dockerbook" do |host|
    host.vm.box = "ubuntu/xenial64"
    host.vm.hostname = "dockerbook"
    #host.disksize.size = "100GB"
    host.vm.network :private_network, ip: "10.10.10.10"

    host.vm.provider "virtualbox" do |v|
      v.name = "dockerbook"
      v.memory = 1024
      v.cpus = 1
    end

    #host.vm.provision "shell", path: "provision.sh"

    host.vm.provision "docker" do |d|
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
      d.build_image "/vagrant/7/consul/consul", args: "-t jamtur01/consul --build-arg http_proxy=$local_proxy --build-arg https_proxy=$local_proxy"
      d.run "consul", image: "jamtur01/consul", args: "-p 8500:8500 -p 53:53/udp -h node1", cmd: "-server -bootstrap -ui"
    end

    #host.vm.provision :docker_compose, yml: "/vagrant/7/composeapp/docker-compose.yml", run: "always"
  end
end
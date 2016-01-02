class loja_virtual::web {
  include loja_virtual
  include mysql::client
  include loja_virtual::params

  file { $loja_virtual::params::keystore_file:
    mode => "0644",
    source => "puppet:///modules/loja_virtual/.keystore",
  }

  class { "tomcat::server":
    connectors => [$loja_virtual::params::ssl_connector],
    data_sources => {
      "jdbc/web" => $loja_virtual::params::db,
      "jdbc/secure" => $loja_virtual::params::db,
      "jdbc/storage" => $loja_virtual::params::db,
    },
    require => File[$loja_virtual::params::keystore_file],
  }

  apt::source { 'devopsnapratica':
    location => 'http://192.168.33.14/',
    architecture => 'i386',
    release => 'devopspkgs',
    repos => 'main',
    key => {
            id => 'C8AB3568AE4AEFB0D1E33A08BB8281D1758D9AC8',
            source => 'http://192.168.33.14/devopspkgs.gpg'
           },
  }

  package { "devopsnapratica":
    ensure => "latest",
    notify => Service["tomcat7"],
  }
}

class java::sdk8 {
  require java::repo

  exec { 'accept-java8-license':
    command => "/bin/echo oracle-java8-installer \
			shared/accepted-oracle-license-v1-1 \
			select true | /usr/bin/debconf-set-selections",
    unless => "/usr/bin/dpkg -l | grep oracle-java8-installer",
  }

  package { 'oracle-java8-installer':
    ensure => installed,
    require => [
                Exec['accept-java8-license'],
                Class['apt::update'],
    ],
  }
}

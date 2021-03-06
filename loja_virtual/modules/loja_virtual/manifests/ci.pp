class loja_virtual::ci {
  include loja_virtual
  include java::sdk8
  include git::git
  include maven::maven
  include jenkins::jenkins
  include loja_virtual::params

# Garante que o maven seja instalado antes do sdk e este antes do jenkins
  Class['maven::maven'] -> Class['java::sdk8']
  Class['java::sdk8'] -> Class['jenkins::jenkins']

# Configura o git
  git::config { 'git-config':
    global => $loja_virtual::params::git_config_global,
  }

# Configura o jenkins
  jenkins::config { 'jenkins-config':
    value => $loja_virtual::params::jenkins_config,
  }

# Instala os plugins do jenkins
  jenkins::plugins { 'jenkins-plugins':
    plugins => $loja_virtual::params::jenkins_plugins,
  }

# Atrela a instalacao do maven no jenkins
  file { '/var/lib/jenkins/hudson.tasks.Maven.xml':
    mode => '0644',
    owner => 'jenkins',
    group => 'jenkins',
    source => 'puppet:///modules/loja_virtual/hudson.tasks.Maven.xml',
    require => Package['jenkins'],
    notify => Service['jenkins'],
  }

# Cria e configura o job para o build da loja_virtual
  $job_structure = [
    '/var/lib/jenkins/jobs/',
    '/var/lib/jenkins/jobs/loja-virtual-devops',
    '/var/lib/jenkins/jobs/loja-virtual-puppet',
    '/var/lib/jenkins/jobs/loja-virtual-deploy-prod',
  ]

  $repo_dir = '/var/lib/apt/repo' # repositorio reprepro para os .deb
  $repo_name = 'devopspkgs' # nome do repositorio de releases desta app
  $project_repository_url = 'https://github.com/fernandoluizjr/DemoSite'
  $repository_poll_interval = '* * * * *'
  $maven_goal = 'clean install -DskipTests=true'
  $archive_artifacts = 'site/target/*.war'

  file { $job_structure:
    ensure => 'directory',
    owner => 'jenkins',
    group => 'jenkins',
    require => Package['jenkins'],
  }

  file { "${job_structure[1]}/config.xml":
    mode => '0644',
    owner => 'jenkins',
    group => 'jenkins',
    content => template('loja_virtual/config.xml'),
    require => File[$job_structure],
    notify => Service['jenkins'],
  }

  file { "${job_structure[2]}/config.xml":
    mode => '0644',
    owner => 'jenkins',
    group => 'jenkins',
    content => template('loja_virtual/config-puppet.xml'),
    require => File[$job_structure],
    notify => Service['jenkins'],
  }

  file { "${job_structure[3]}/config.xml":
    mode => '0644',
    owner => 'jenkins',
    group => 'jenkins',
    content => template('loja_virtual/config-deploy.xml'),
    require => File[$job_structure],
    notify => Service['jenkins'],
  }

# Cria um repositorio de pacotes para os releases da loja_virtual
  class { 'loja_virtual::repo':
    baserepodir => $repo_dir,
    reponame => $repo_name,
  }
}

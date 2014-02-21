class shark (
    $master,
    $hive_compatible_version = $::shark::defaults::hive_compatible_version,
    $hadoop_version = $::shark::defaults::hadoop_version,
    $spark_version = $::shark::defaults::spark_version,
    $spark_worker_memory = $::shark::defaults::spark_worker_memory,
    $shark_version = $::shark::defaults::shark_version,
    $scala_version = $::shark::defaults::scala_version,
    $java_home     = $::shark::defaults::java_home,
) inherits shark::defaults {

    

    package { ['wget', 'tar']:
        ensure => installed,
    }

    file { '/opt/fetch_requirements.sh':
        content => template('shark/fetch_requirements.sh.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0744',
        require => [
            Package['wget'],
            Package['tar'],
        ],
    }
    
    exec { 'fetch_requirements':
        command => '/opt/fetch_requirements.sh',
        user => 'root',
        creates => "/opt/scala-${scala_version}",
        require => File['/opt/fetch_requirements.sh'],
    }

    file {"/opt/shark-${shark_version}":
        ensure  => directory,
        recurse => true,
        owner   => 'root',
        group   => 'root',
        mode    => '0744',
        source  => "puppet:///modules/shark/shark-${shark_version}",
    }

    file {"/opt/hive-${hive_compatible_version}-shark-${shark_version}":
        ensure  => directory,
        recurse => true,
        owner   => 'root',
        group   => 'root',
        mode    => '0744',
        source  => "puppet:///modules/shark/hive-${hive_compatible_version}-shark-${shark_version}",
    }
    

    file {"/opt/shark-${shark_version}/conf/shark-env.sh":
        content => template('shark/shark-env.sh.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0744',
        require => File["/opt/shark-${shark_version}"],
    }

    file {"/opt/hive-${hive_compatible_version}-shark-${shark_version}/conf/hive-site.xml":
        content  => template('shark/hive-site.xml.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => File["/opt/hive-${hive_compatible_version}-shark-${shark_version}"],
    }

}

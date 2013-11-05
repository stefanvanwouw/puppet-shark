class shark (
    $master,
    $slaves,
    $hive_compatible_version = $::shark::defaults::hive_compatible_version,
    $hadoop_version = $::shark::defaults::hadoop_version,
    $spark_version = $::shark::defaults::spark_version,
    $spark_worker_memory = $::shark::defaults::spark_worker_memory,
    $shark_version = $::shark::defaults::shark_version,
    $scala_version = $::shark::defaults::scala_version,
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
        creates => "/opt/shark-${shark_version}-bin-${hadoop_version}",
        require => File['/opt/fetch_requirements.sh'],
    }
    
    file {"/opt/spark-${spark_version}/conf/slaves":
        content => template('shark/slaves.erb'),
        require => Exec['fetch_requirements'],
    }

    file {"/opt/spark-${spark_version}/conf/spark-env.sh":
        content => template('shark/spark-env.sh.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0744',
        require => Exec['fetch_requirements'],
    }
    file {"/opt/shark-${shark_version}-bin-${hadoop_version}/shark-${shark_version}/conf/shark-env.sh":
        content => template('shark/shark-env.sh.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0744',
        require => Exec['fetch_requirements'],
    }

    file {"/opt/shark-${shark_version}-bin-${hadoop_version}/hive-${hive_compatible_version}-shark-${shark_version}-bin/conf/hive-site.xml":
        source  => '/etc/hive/conf/hive-site.xml',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Exec['fetch_requirements'],
    }

}

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
        creates => "/opt/shark-${shark_version}-bin-${hadoop_version}",
        require => File['/opt/fetch_requirements.sh'],
    }

    file {'/opt/shark-0.8.0-bin-cdh4':
        ensure  => directory,
        recurse => true,
        owner   => 'root',
        group   => 'root',
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
        content  => template('shark/hive-site.xml.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Exec['fetch_requirements'],
    }

    # The shipped custom patched hive 0.9 does not have mysql drivers, copy them from our hive 0.12 version.
    #file {"/opt/shark-${shark_version}-bin-${hadoop_version}/hive-${hive_compatible_version}-shark-${shark_version}-bin/lib/libmysql-java.jar":
    #    source  => '/usr/lib/hive/lib/libmysql-java.jar',
    #    owner   => 'root',
    #    group   => 'root',
    #    mode    => '0644',
    #    require => Exec['fetch_requirements'],
    #}
    


}

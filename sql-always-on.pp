## site.pp ##

# This file (/etc/puppetlabs/puppet/manifests/site.pp) is the main entry point
# used when an agent connects to a master and asks for an updated configuration.
#
# Global objects like filebuckets and resource defaults should go in this file,
# as should the default node definition. (The default node can be omitted
# if you use the console and don't define any other nodes in site.pp. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.)

## Active Configurations ##

# Disable filebucket by default for all File resources:
File { backup => false }

# DEFAULT NODE
# Node definitions in this file are merged with node data from the console. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.

# The default node definition matches any node lacking a more specific node
# definition. If there are no other nodes in this file, classes declared here
# will be included in every node's catalog, *in addition* to any classes
# specified in the console for that node.

node default {}
# node default {

#   $sql_iso_base_url     = 'http://int-resources.ops.puppetlabs.net/QA_resources/microsoft_sql/iso'
#   $sql_iso_filename     = 'en_sql_server_2017_standard_x64_dvd_11294407.iso'

#   $windows_iso_base_url = 'http://int-resources.ops.puppetlabs.net/ISO/Windows/2016'
#   $windows_iso_filename = 'win-2016-14393.0.160808-1702.RS1_Release_srvmedia_SERVER_OEMRET_X64FRE_EN-US.iso'

#   $iso_download_folder  = 'c:/users/bhurt/Downloads'

#   $domain_name          = 'bhdctesting'
#   $username             = 'bhurt'
#   $sql_service_account  = 'sqlservice'
#   $sql_service_password = 'password1!'

#   $local_group_name     = 'DBAdmins'

#   pget {'Download SQL ISO':
#     source => "${sql_iso_base_url}/${sql_iso_filename}",
#     target => $iso_download_folder
#   }

#   pget {'WindowsISO':
#     source => "${windows_iso_base_url}/${windows_iso_filename}",
#     target => $iso_download_folder,
#   }

#   mount_iso {"${iso_download_folder}/${sql_iso_filename}":
#     drive_letter => 'H',
#     require      => Pget['Download SQL ISO'],
#     before       => Sqlserver_instance['MSSQLSERVER']
#   }

#   mount_iso {"${iso_download_folder}/${windows_iso_filename}":
#     drive_letter => 'I',
#     require      => Pget['WindowsISO'],
#     before       => Sqlserver_instance['MSSQLSERVER']
#   }

#   # sqlserver_instance{ 'MSSQLSERVER':
#   #     ensure                 => present,
#   #     features               => ['SQLEngine'],
#   #     source                 => 'H:/',
#   #     windows_feature_source => 'I:/sources',
#   #     sql_sysadmin_accounts  => ['Administrator',"${domain_name}\\${username}"],
#   #     sql_svc_account        => "${domain_name}\\${sql_service_account}",
#   #     sql_svc_password       => $sql_service_password
#   # }

#   package {'sql-server-management-studio':
#     ensure   => present,
#     provider => 'chocolatey'
#   }

#   package {'conemu':
#     ensure   => present,
#     provider => 'chocolatey'
#   }
# }

node 'qycldls5vef4t5t.bhdctesting.com' {
  package {'sql-server-management-studio':
    ensure   => present,
    provider => 'chocolatey'
  }

  $sql_iso_base_url     = 'http://int-resources.ops.puppetlabs.net/QA_resources/microsoft_sql/iso'
  $sql_iso_filename     = 'en_sql_server_2017_standard_x64_dvd_11294407.iso'

  $windows_iso_base_url = 'http://int-resources.ops.puppetlabs.net/ISO/Windows/2016'
  $windows_iso_filename = 'win-2016-14393.0.160808-1702.RS1_Release_srvmedia_SERVER_OEMRET_X64FRE_EN-US.iso'

  $iso_download_folder  = 'c:/users/bhurt/Downloads'

  $domain_name          = 'bhdctesting'
  $username             = 'bhurt'
  $sql_service_account  = 'sqlservice'
  $sql_service_password = 'password1!'

  $local_group_name     = 'DBAdmins'
  # Primary Node

  pget {'Download SQL ISO':
    source => "${sql_iso_base_url}/${sql_iso_filename}",
    target => $iso_download_folder
  }

  pget {'WindowsISO':
    source => "${windows_iso_base_url}/${windows_iso_filename}",
    target => $iso_download_folder,
  }

  mount_iso {"${iso_download_folder}/${sql_iso_filename}":
    drive_letter => 'H',
    require      => Pget['Download SQL ISO'],
  }

  mount_iso {"${iso_download_folder}/${windows_iso_filename}":
    drive_letter => 'I',
    require      => Pget['WindowsISO'],
  }

  class{'sqlserveralwayson':
    setup_svc_username                 => "${domain_name}\\${username}",
    setup_svc_password                 => $sql_service_password,
    setupdir                           => 'H:\\',
    sa_password                        => 'P@ssw0rd',
    sqlservicecredential_username      => $sql_service_account,
    sqlservicecredential_password      => $sql_service_password,
    sqlagentservicecredential_username => $sql_service_account,
    sqlagentservicecredential_password => $sql_service_password,
    sqladministratoraccounts           => ["${domain_name}\\${sql_service_account}", "${domain_name}\\${username}"],
    clusterName                        => 'CLDB01',
    clusterIP                          => '10.16.125.60',
    fileShareWitness                   => '\\\\10.16.123.60\\quorum',
    listenerIP                         => '10.16.125.61/255.255.255.0',
    role                               => 'primary',
    require                            => [
      Mount_iso["${iso_download_folder}/${sql_iso_filename}"],
    ]
  }
}

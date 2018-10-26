/* Modules to install
cd into 'c:\programdata\puppetlabs\code\environments\production\modules'
git clone https://github.com/puppetlabs/puppetlabs-sqlserver sqlserver
puppet module install cyberious-pget
puppet module install puppetlabs-chocolatey
puppet module install puppetlabs-mount_iso

This manifest assumes you are in a domain environment with a domain user and service account.
*/


$sql_iso_base_url = 'http://int-resources.ops.puppetlabs.net/QA_resources/microsoft_sql/iso'
$sql_iso_filename = 'en_sql_server_2017_standard_x64_dvd_11294407.iso'

$windows_iso_base_url = 'http://int-resources.ops.puppetlabs.net/ISO/Windows/2016'
$windows_iso_filename = 'win-2016-14393.0.160808-1702.RS1_Release_srvmedia_SERVER_OEMRET_X64FRE_EN-US.iso'

$iso_download_folder = 'c:/users/bhurt/Downloads'

$domain_name = 'bhdctesting'
$username    = 'bhurt'
$sql_service_account = 'sqlservice'
$sql_service_password = 'password1!'

$local_group_name = 'DBAdmins'

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
  before       => Sqlserver_instance['MSSQLSERVER']
}

mount_iso {"${iso_download_folder}/${windows_iso_filename}":
  drive_letter => 'I',
  require      => Pget['WindowsISO'],
  before       => Sqlserver_instance['MSSQLSERVER']
}

sqlserver_instance{ 'MSSQLSERVER':
    ensure                 => present,
    features               => ['SQLEngine'],
    source                 => 'H:/',
    windows_feature_source => 'I:/sources',
    sql_sysadmin_accounts  => ['Administrator',"${domain_name}\\${username}"],
    sql_svc_account        => "${domain_name}\\${sql_service_account}",
    sql_svc_password       => $sql_service_password
}

package {'sql-server-management-studio':
  ensure   => present,
  provider => 'chocolatey'
}

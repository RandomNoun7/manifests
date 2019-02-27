/* Modules to install
cd into 'c:\programdata\puppetlabs\code\environments\production\modules'
git clone https://github.com/puppetlabs/puppetlabs-sqlserver sqlserver
puppet module install cyberious-pget
puppet module install puppetlabs-chocolatey
puppet module install puppetlabs-mount_iso

This manifest assumes you are in a domain environment with a domain user and service account.
*/

include chocolatey

$sql_iso_base_url = 'https://artifactory.delivery.puppetlabs.net/artifactory/generic__iso/iso/SQLServer'
$sql_iso_filename = 'SQLServer-2019-CTP2-x64-ENU.iso'

$windows_iso_base_url = 'https://artifactory.delivery.puppetlabs.net/artifactory/generic__iso/iso/windows'
$windows_iso_filename = 'en_windows_server_2016_updated_feb_2018_x64_dvd_11636692.iso'

$iso_download_folder = 'c:/users/administrator/Downloads'

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
    sql_sysadmin_accounts  => ['Administrator'],
    sql_svc_account        => "${$::hostname}\\Administrator",
    sql_svc_password       => 'Qu@lity!'
}

sqlserver_instance{ 'dev_instance':
    ensure                 => present,
    features               => ['SQLEngine'],
    source                 => 'H:/',
    windows_feature_source => 'I:/sources',
    sql_sysadmin_accounts  => ['Administrator'],
    sql_svc_account        => "${$::hostname}\\Administrator",
    sql_svc_password       => 'Qu@lity!',
    require                => [
      Mount_iso["${iso_download_folder}/${windows_iso_filename}"],
      Mount_iso["${iso_download_folder}/${sql_iso_filename}"]
    ]
}

package {'sql-server-management-studio':
  ensure   => present,
  provider => 'chocolatey',
  require  => Sqlserver_instance['MSSQLSERVER']
}

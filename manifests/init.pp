# == Class: common
#
# This class is applied to *ALL* nodes
#
# === Copyright
#
# Copyright 2013 GH Solutions, LLC
#
class common (
  $users         = undef,
  $groups        = undef,
  $root_password = '$1$cI5K51$dexSpdv6346YReZcK2H1k.', # puppet
  $dp_server     = '',
  $dp_server_ip  = '',
  $is_pci        = false,
) {

  include dnsclient
  include ftpclient
  include hosts
  include inittab
  include mailaliases
  include mcollective::role
  include motd
  include nagios
  include network
  include nsswitch
  include ntp
  include pam
  include puppet::agent
  include psacct
  include rsyslog
  include selinux
  include sendmail
  include ssh
  include utils
  include vim
  include wget
  include sudo
  include standardconfig

  # Include logrhythm on servers in PCI zone.
  if $is_pci == true {
    include logrhythm
  }

  # only allow supported OS's
  case $::osfamily {
    'redhat': {
      include redhat
    }
    default: {
      fail("We only support RedHat based OS's and your osfamily is ${::osfamily}")
    }
  }

  # Configure the Firewall and remove any rules not managed by us
  resources { "firewall":
    purge => true
  }
  Firewall {
    before  => Class['my_fw::post'],
    require => Class['my_fw::pre'],
  }
  class { ['my_fw::pre', 'my_fw::post']: }
  class { 'firewall': }

  # include modules depending on if we are virtual or not
  case $::is_virtual {
    'true': {
      include virtual
    }
    'false': {
      include physical
    }
    default: {
      fail("The fact, is_virtual, must be true or false and is ${::is_virtual}. This is likely a facter bug")
    }
  }


  if $dp_server == '' {
    case $::ipaddress {
      /^192\.168\.254\.[\d.]+$/: {
        $real_dp_server_ip = "192.168.252.201"
        $real_dp_server = "isms5.herffjones.hj-int"
      }
      default: {
        $real_dp_server_ip = "192.168.10.93"
        $real_dp_server = "inxx76.herffjones.hj-int"
      }
    }
  } else {
    $real_dp_server_ip = $dp_server_ip
    $real_dp_server = $dp_server
  }
  class { 'dataprotector':
    cm_ip   => $real_dp_server_ip,
    cm_name => $real_dp_server,
  }

  # removes root's mail spool every day at noon
  nukemail::user { 'root':
    hour   => '12',
    minute => '0',
  }

  # Allow Unix Admins to have sudo access
  sudo::conf { 'sudo_unixadmins':
    content  => '%unixadmins ALL=(ALL) NOPASSWD: ALL',
  }

  # Allow access for the sshuser
  sudo::conf { 'sudo_sshuser':
    content => 'Defaults:sshuser       !requiretty
sshuser         ALL=(ALL) NOPASSWD: /usr/local/bin/system_healthcheck, /usr/local/bin/mountchecker, /usr/local/bin/gluster_check, /sbin/service'
  }

  # Create any resources defined in hiera
  hiera_resources('resources')

  # basic filesystem requirements
  file { [ '/opt/hj',
            '/x01',
            '/x01/backup',
          ]:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  # SSH Key for ssgsvn.herffjones.hj-int
  #@@sshkey { 'ssgsvn.herffjones.hj-int':
  #    ensure => 'present',
  #    type   => 'rsa',
  #    key    => 'AAAAB3NzaC1yc2EAAAABIwAAAQEArm8ij1MFfI3yZLo+5l8GlY82i5nBODa9332XgonV5J9FlxLL3Xqs82+EsYbncZhEF1TEF/gB/uXGc62rbkyOGIfJR6fKk2mA+Ix7f6LuowSwrRHvLgDY+lLnUMZPuEpsX0AdJvyFBHYZkoq9wd0DP2exXX9ZMZ7iRmBQBrrpDLrbCEiCOi9n/wMgxsJVUvuXyMF6URBn3BnxPYTQnL0Kh8so2AvwbH2w8ulKQ+QXzX6P+Xf6fPg4BszKLPFPkwFWLrO5rhiORWLzkVFnTrlSimco+KMExfpG4GzRFVSJzFfPDSQVByfoveiTFA5+UMwAEyNWhlFtwJBpa29k4K6OBw==',
  #}

  #Get a list of allowed users and groups on the system
  $allowed_users=hiera_array("pam::allowed_users", undef)
  #Get a hash of all users in hiera
  $allusers=hiera(users)
  #Parse the allowed user list to create hash of local users
  $local_users=local_users($allowed_users,$allusers)

  if $local_users != undef {
    # Create virtual user resources
    create_resources("@common::mkuser",$local_users)
    # Collect all virtual users
    Common::Mkuser <| |>
  }

  if $groups != undef {

    # Create virtual group resources
    create_resources("@group",$common::groups)

    # Collect all virtual groups
    Group <| |>
  }
}

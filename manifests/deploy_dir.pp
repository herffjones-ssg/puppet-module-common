class common::deploy_dir (
  $deploy_path="/x01/deploy",
  $deploy_user="deployuser",
) {
  file { "hj_deploy_dir":
    path   => $deploy_path,
    ensure => directory,
    owner  => $deploy_user,
    group  => $deploy_user,
    mode   => '0755',
  }
}

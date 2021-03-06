# == Define: cinder::backend::nfs
#
# === Parameters
#
# [*volume_backend_name*]
#   (optional) Allows for the volume_backend_name to be separate of $name.
#   Defaults to: $name
#
# [*nfs_servers*]
#   (Required) Description
#   Defaults to '[]'
#
# [*nfs_mount_attempts*]
#   (optional) The number of attempts to mount nfs shares before raising an
#   error. At least one attempt will be made to mount an nfs share, regardless
#   of the value specified.
#   Defaults to $::os_service_default
#
# [*nfs_mount_options*]
#   (Optional) Mount options passed to the nfs client.
#   Defaults to $::os_service_default
#
# [*nfs_disk_util*]
#   (Optional) TODO
#   Defaults to $::os_service_default
#
# [*nfs_sparsed_volumes*]
#   (Optional) Create volumes as sparsed files which take no space.
#   If set to False volume is created as regular file.
#   In such case volume creation takes a lot of time.
#   Defaults to $::os_service_default
#
# [*nfs_mount_point_base*]
#   (Optional) Base dir containing mount points for nfs shares.
#   Defaults to $::os_service_default
#
# [*nfs_shares_config*]
#   (Optional) File with the list of available nfs shares.
#   Defaults to '/etc/cinder/shares.conf'.
#
# [*nfs_used_ratio*]
#   (Optional) Percent of ACTUAL usage of the underlying volume before no new
#   volumes can be allocated to the volume destination.
#   Defaults to $::os_service_default
#
# [*nfs_oversub_ratio*]
#   (Optional) This will compare the allocated to available space on the volume
#   destination. If the ratio exceeds this number, the destination will no
#   longer be valid.
#   Defaults to $::os_service_default
#
# [*extra_options*]
#   (optional) Hash of extra options to pass to the backend stanza
#   Defaults to: {}
#   Example :
#     { 'nfs_backend/param1' => { 'value' => value1 } }
#
define cinder::backend::nfs (
  $volume_backend_name  = $name,
  $nfs_servers          = [],
  $nfs_mount_attempts   = $::os_service_default,
  $nfs_mount_options    = $::os_service_default,
  $nfs_disk_util        = $::os_service_default,
  $nfs_sparsed_volumes  = $::os_service_default,
  $nfs_mount_point_base = $::os_service_default,
  $nfs_shares_config    = '/etc/cinder/shares.conf',
  $nfs_used_ratio       = $::os_service_default,
  $nfs_oversub_ratio    = $::os_service_default,
  $extra_options        = {},
) {

  file {$nfs_shares_config:
    content => join($nfs_servers, "\n"),
    require => Package['cinder'],
    notify  => Service['cinder-volume']
  }

  cinder_config {
    "${name}/volume_backend_name":  value => $volume_backend_name;
    "${name}/volume_driver":        value =>
      'cinder.volume.drivers.nfs.NfsDriver';
    "${name}/nfs_shares_config":    value => $nfs_shares_config;
    "${name}/nfs_mount_attempts":   value => $nfs_mount_attempts;
    "${name}/nfs_mount_options":    value => $nfs_mount_options;
    "${name}/nfs_disk_util":        value => $nfs_disk_util;
    "${name}/nfs_sparsed_volumes":  value => $nfs_sparsed_volumes;
    "${name}/nfs_mount_point_base": value => $nfs_mount_point_base;
    "${name}/nfs_used_ratio":       value => $nfs_used_ratio;
    "${name}/nfs_oversub_ratio":    value => $nfs_oversub_ratio;
  }

  create_resources('cinder_config', $extra_options)

}

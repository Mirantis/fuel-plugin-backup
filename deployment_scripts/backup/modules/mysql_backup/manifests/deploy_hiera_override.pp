notice('MODULAR: deploy_hiera_override.pp')

$backup_plugin = hiera('backup')
$settings_hash = parseyaml($backup_plugin["backup_additional_config"])

###########################################################################

$calculated_content = inline_template('
<%= @settings_hash.to_yaml.to_s.gsub(/^\s{2}/, "").gsub(/--- \n/, "") %>
')

###################
file {'/etc/hiera/override':
  ensure  => directory,
} ->
file { '/etc/hiera/override/common.yaml':
  ensure  => file,
  content => "${calculated_content}\n",
}

package {'ruby-deep-merge':
  ensure  => 'installed',
}

file_line {'hiera.yaml':
  path  => '/etc/hiera.yaml',
  line  => ':merge_behavior: deeper',
}

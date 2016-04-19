notice('fuel-plugin-nsxv: gem-install.pp')

# ruby gem package must be pre installed before puppet module used
package { 'ruby-rbvmomi':
  ensure => latest,
}

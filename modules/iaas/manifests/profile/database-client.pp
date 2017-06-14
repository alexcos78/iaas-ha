#Installing a mysql client if DB is an external service
class iaas::profile::database-client(
) {
## Install MySQL client
  class { 'mysql::client':
  }  -> anchor { 'database-service': }
}

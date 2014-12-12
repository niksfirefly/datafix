## Description
    This generates a migration to upgrade the old datafix tables.

## Example

    rails generate datafix:upgrade

This will create:

    db/migrate/YYYYMMDDhhmmss_upgrade_datafix_tables.rb

To run it, execute:

    rake db:migrate


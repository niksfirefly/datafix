## Description
    This generates a migration to upgrade the old datafix tables.

## Example

    rails generate datafix:upgrade

This will create:

    db/migrate/YYYYMMDDhhmmss_create_datafix_statuses.rb
    db/migrate/YYYYMMDDhhmmss_update_datafix_statuses.rb
    db/migrate/YYYYMMDDhhmmss_rename_datafix_log_to_datafix_logs.rb

To run it, execute:

    rake db:migrate


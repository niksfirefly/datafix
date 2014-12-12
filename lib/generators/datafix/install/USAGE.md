## Description
    This generates a migration to create the datafix\_log table necessary for the datafix tasks and specs

## Example

    rails generate datafix:install

This will create:

    db/migrate/YYYYMMDDhhmmss_create_datafix_log.rb
    db/migrate/YYYYMMDDhhmmss_create_datafix_statuses.rb
    db/migrate/YYYYMMDDhhmmss_update_datafix_statuses.rb
    db/migrate/YYYYMMDDhhmmss_rename_datafix_log_to_datafix_logs.rb

To run it, execute:

    rake db:migrate

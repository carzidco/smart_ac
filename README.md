# BE-Charlie-Cordoba-smartac
BE PoC exercise for Charlie Cordoba

## Run the app locally
 
- `bundle install`
- `rake db:migrate`
- `shotgun`

## Architecture

The application was built using Ruby and Sinatra for the HTTP requests, Active Record as ORM, SQLite as Database.

Using libraries like bootstrap for the UI part and some js useful libraries.
### gems

Using bcrypt for the basic authentication and keeping a session for logged in requests
Rake for running the migrations
Shotgun as a rails server for spinning up the application

## Manifest

This application is intended to bring a great solution for Smart AC devices.

It offers for the version 1.0.0, the following features

- Self-authentication for any device from API and Web
- Send sensor as a single element or in a bulk of sensors with different values
- Nice and friendly WEB Admin interface with authentication, different dashboard, many useful CRUDS in order to provide another way to create data from WEB
- Listing out Devices for Web and API
- Having a real-time interface alert system for alarms, when any sensors is at risk. Furthermore the feature to display only alarms and check if one or more are handled by the administrator.

## Future functionality / Pending

- Adding graphs for having a better visibility and tracking down in a human readable fashion to identify and create metric from results
- Refactor and optimize some logic, I'd rather to have services and mixins for several parts instead of duplicating code
- Adding rspecs and coverage for the majority of the application
- Adding the private invite link
- Adding reset password, maybe not using email, something like a question and a personal code could work

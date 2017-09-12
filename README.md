# Sensi
API Wrapper for Emersion Sensi WiFi Thermostats.

**This gem is currently in development. Expect API breaking changes on each release.**

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sensi'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install sensi

## Usage

Connect to a thermostat with the device's email and password.
```ruby
>thermostat = Sensi::Thermostat.new('joe@example.com', 'joespassword')
>thermostat.connect
```
Get system information
```ruby
>thermostat.system_modes
=>["Heat","Cool","Off","Aux","Auto"]
```


Get system settings; what should the HVAC do?
```ruby
>thermostat.system_mode
=>"Heat"
>thermostat.system_temperature type: :heat
=>71
>thermostat.system_temperature type: :cool
=>77

# general check if system is on or off
>thermostat.system_on?
=>true
>thermostat.system_off?
=>false

# convenience methods for system mode checks, only one of these should be true at a time
>thermostat.system_heat_on?
=>true
>thermostat.system_cool_on?
=>false
>thermostat.system_aux_on?
=>false
>thermostat.system_auto_on?

# system fan
>thermostat.system_fan_on?
=>true
```

Get system state; what is the HVAC doing now?
```ruby
>thermostat.active?
=>true
>thermostat.active_mode
=>"Heat"
>thermostat.active_time
=>"00:04:27" # hh:mm:ss

>thermostat.temperature
=>71
>thermostat.temperature(:C)
=>21
thermostat.humidity
=>51



```

Adjust settings
```ruby
# turn heat on and set to 70F
>thermostat.set(mode: :heat, temp: 70)
=>true

# set system to cool
>thermostat.set(mode: :cool, temp: 77)
=>true

# temperature scale defaults to Fahrenheit, pass the scale argument :C for Celius.
>thermostat.set(mode: cool, temp: 22, scale: :C)
=>true

# turn the fan on
>thermostat.set(fan: :on)
=>true

# turn fan off
>thermostat.set(fan: :auto)
=>true
```

Disconnect when you're done.

```ruby
thermostat.disconnect
```

## To Do
* Documentation
* View/Modify Schedules

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kirbs-/sensi. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the GNU General Public License v2.0.





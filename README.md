![OneSwap Logo Color](https://github.com/OpenNebula/one-swap/assets/92747003/a770a3e2-2774-4682-ab36-c18d6e75f442)

Please see all instructions in the [Wiki](https://github.com/OpenNebula/one-swap/wiki)

## Web Interface

A simple web interface is available using Sinatra. Install dependencies and run the application from the `web` directory:

```bash
bundle install --gemfile web/Gemfile
ruby web/app.rb
```

The app listens on `http://localhost:4567` by default. Use the forms to convert or import VMs and images.

# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "jquery", to: "https://code.jquery.com/jquery-3.1.1.min.js"
pin "semantic-ui", to: "https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.4.1/semantic.min.js"
pin "chartkick", to: "chartkick.js"
pin "Chart.bundle", to: "Chart.bundle.js"

# Enable private class fields
pin "@babel/plugin-proposal-private-methods", to: "https://ga.jspm.io/npm:@babel/plugin-proposal-private-methods@7.18.6/lib/index.js"
pin "@babel/plugin-proposal-class-properties", to: "https://ga.jspm.io/npm:@babel/plugin-proposal-class-properties@7.18.6/lib/index.js"

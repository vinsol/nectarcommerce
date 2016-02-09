- Add in layout/app.html.eex to access bootstrap js
  - `<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>`
  - `<script src="http://getbootstrap.com/dist/js/bootstrap.min.js"></script>`
- Add in layout/_login_nav_bar.html.eex nav partial
```html
<li role="presentation" class="dropdown">
  <%= link "OptionType", to: "#",  class: "dropdown-toggle", "aria-expanded": "false", "data-toggle": "dropdown" %>
  <ul class="dropdown-menu">
    <li><%= link "OptionType", to: admin_option_type_path(@conn, :index) %></li>
  </ul>
</li>
```

create_file "app/views/layouts/application.html.erb", <<~ERB
  <!DOCTYPE html>
  <html>
  <head>
    <title>MyApp</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag "application", media: "all" %>
    <%= javascript_importmap_tags %>
  </head>
  <body class="hold-transition sidebar-mini layout-fixed">
    <div class="wrapper">
      <%= render 'layouts/header' %>
      <%= render 'layouts/sidebar' %>
      <div class="content-wrapper">
        <section class="content pt-3 px-3">
          <%= yield %>
        </section>
      </div>
      <%= render 'layouts/footer' %>
    </div>
  </body>
  </html>
ERB

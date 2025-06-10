create_file "app/views/layouts/_header.html.erb", <<~ERB
  <nav class="main-header navbar navbar-expand navbar-white navbar-light">
    <ul class="navbar-nav">
      <li class="nav-item">
        <a class="nav-link" data-widget="pushmenu" href="#" role="button"><i class="fas fa-bars"></i></a>
      </li>
    </ul>
    <ul class="navbar-nav ml-auto">
      <li class="nav-item">
        <%= link_to "Logout", destroy_user_session_path, method: :delete, class: "nav-link" if user_signed_in? %>
      </li>
    </ul>
  </nav>
ERB

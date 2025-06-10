create_file "app/views/layouts/_sidebar.html.erb", <<~ERB
  <aside class="main-sidebar sidebar-dark-primary elevation-4">
    <a href="/" class="brand-link">
      <span class="brand-text font-weight-light">MyApp</span>
    </a>
    <div class="sidebar">
      <nav class="mt-2">
        <ul class="nav nav-pills nav-sidebar flex-column" data-widget="treeview" role="menu">
          <li class="nav-item">
            <%= link_to "Home", root_path, class: "nav-link" %>
          </li>
        </ul>
      </nav>
    </div>
  </aside>
ERB

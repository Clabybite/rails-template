create_file "app/views/layouts/_footer.html.erb", <<~ERB
  <footer class="main-footer text-sm">
    <div class="float-right d-none d-sm-inline">
      Anything you want
    </div>
    <strong>&copy; <%= Date.today.year %> MyApp.</strong> All rights reserved.
  </footer>
ERB

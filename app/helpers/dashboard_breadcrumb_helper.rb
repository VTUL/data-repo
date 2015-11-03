module DashboardBreadcrumbHelper
  @@dashboard_groups = {
    "generic_files" => :upload,
    "batch" => :describe,
    "my/files" => :describe,
    "my/highlights" => :describe,
    "my/shares" => :describe,
    "batch_edits" => :describe,
    "my/collections" => :organize,
    "collections" => :organize,
    "publishables" => :publish
  }

  def current_dashboard_tab?(sym)
    @@dashboard_groups[params[:controller]] == sym
  end
end

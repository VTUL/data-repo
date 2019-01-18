class MyCollectionEditForm < MyCollectionPresenter
  include HydraEditor::Form
  include HydraEditor::Form::Permissions

  self.terms += [:citation]  

  self.required_fields = [:title]
end

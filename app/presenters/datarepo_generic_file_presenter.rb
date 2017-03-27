class DatarepoGenericFilePresenter < Sufia::GenericFilePresenter
  self.terms += [:provenance]
  self.terms -= [:publisher]
end

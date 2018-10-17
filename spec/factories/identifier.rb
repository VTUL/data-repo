FactoryGirl.define do
  factory :identifier, :class => Ezid::Identifier do
    id "doi:10.5072/fk2-mock-doi"
    target "http://test.host"
  end
end

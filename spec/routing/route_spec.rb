require 'spec_helper'

RSpec.describe 'Routes', type: :routing do
  describe 'Collections' do
    it 'routes to ldap_search' do
      expect(get: '/collections/ldap_search?label=creator&name=name').to route_to(controller: 'collections', action: 'ldap_search', label: 'creator', name: 'name')
    end
  end
end

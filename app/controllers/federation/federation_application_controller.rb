module Federation
  class FederationApplicationController < ApplicationController
    private

    def policy_scope(scope, policy_scope_class: nil)
      scope = [:federation, scope] unless policy_scope_class
      super(scope, policy_scope_class: policy_scope_class)
    end

    def authorize(record, query = nil, policy_class: nil)
      record = [:federation, record] unless policy_class
      super(record, query, policy_class: policy_class)
    end
  end
end

